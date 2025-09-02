import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/message_provider.dart';
import '../providers/location_provider.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/task_screen.dart';
import '../screens/ai_bot_control_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../widgets/quick_send_widget.dart';
import '../widgets/message_bubble_overlay.dart';
import '../config/ai_bot_config.dart';
import '../services/ai_geographic_bot_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  Marker? _userLocationMarker;
  double _currentRadius = 1000.0; // 基礎範圍1公里，將根據用戶權限動態更新
  GoogleMapController? _mapController;
  final List<MessageBubbleOverlay> _bubbleOverlays = [];
  final GlobalKey _mapKey = GlobalKey();
  Timer? _bubbleRotationTimer;
  int _currentTopBubbleIndex = 0;

  // 獲取用戶的實際範圍權限（基礎+獎勵）
  double _getUserTotalRange() {
    final taskProvider = context.read<TaskProvider>();
    const baseRangeMeters = 1000.0; // 基礎1公里
    final bonusRange = taskProvider.bonusRangeMeters;
    return baseRangeMeters + bonusRange;
  }



  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(25.0330, 121.5654), // Default location: Taipei 101
    zoom: 15.0, // 調整為適合查看附近訊息的縮放級別，顯示街道和建築細節
  );

  // 根據用戶範圍計算適合的縮放級別（進一步最小化到用戶範圍）
  double _getInitialZoomForRadius(double radius) {
    // 進一步最小化地圖範圍，讓用戶範圍圓圈更緊密地顯示

    // 更緊密的顯示範圍，讓用戶範圍圓圈剛好可見
    double displayRadius = radius * 1.1; // 減少放大倍數，讓地圖更小

    // 提高所有縮放級別，讓地圖顯示範圍更小
    if (displayRadius >= 1200) return 14.5; // 1公里範圍進一步縮小
    if (displayRadius >= 900) return 15.0; // 750米範圍進一步縮小
    if (displayRadius >= 600) return 15.5; // 500米範圍進一步縮小
    if (displayRadius >= 360) return 16.0; // 300米範圍進一步縮小
    if (displayRadius >= 240) return 16.5; // 200米範圍進一步縮小
    if (displayRadius >= 120) return 17.0; // 100米範圍進一步縮小
    if (displayRadius >= 60) return 17.5; // 50米範圍進一步縮小
    return 18.0; // 最小範圍進一步縮小
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  // 計算最小縮放級別（顯示用戶範圍的2倍區域，這是最大可放大的限制）
  double _getMinZoomLevel() {
    // 根據用戶範圍計算最小縮放級別
    // 範圍越大，縮放級別越小（顯示更大區域）
    double maxViewRadius = _currentRadius * 2; // 最大可視範圍為用戶範圍的2倍

    // 根據範圍計算縮放級別，確保不超過用戶範圍的2倍放大
    if (maxViewRadius >= 2000) return 11.0; // 1公里範圍的2倍 = 2公里
    if (maxViewRadius >= 1500) return 11.5;
    if (maxViewRadius >= 1000) return 12.0;
    if (maxViewRadius >= 750) return 12.5;
    if (maxViewRadius >= 500) return 13.0;
    if (maxViewRadius >= 250) return 13.5;
    return 14.0;
  }

  // 計算最大縮放級別
  double _getMaxZoomLevel() {
    return 18.0; // 允許放大到街道級別
  }

  // 更新縮放限制
  void _updateZoomLimits() {
    if (_mapController != null) {
      // 當用戶範圍改變時，重新設定縮放限制
      // 注意：Google Maps 不支援動態更改 minMaxZoomPreference
      // 所以我們需要在相機移動時檢查縮放級別
    }
  }

  // 檢查縮放限制 - 確保不超過用戶範圍的二倍
  void _checkZoomLimits(CameraPosition position) {
    double minZoom = _getMinZoomLevel(); // 最小縮放級別（最大顯示範圍）
    double maxZoom = _getMaxZoomLevel(); // 最大縮放級別

    if (position.zoom < minZoom) {
      // 如果縮放級別太小（顯示範圍超過用戶範圍的2倍），強制回到限制內
      Future.delayed(const Duration(milliseconds: 100), () {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: position.target,
              zoom: minZoom,
            ),
          ),
        );
      });
    } else if (position.zoom > maxZoom) {
      // 如果縮放級別太大，限制到最大縮放級別
      Future.delayed(const Duration(milliseconds: 100), () {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: position.target,
              zoom: maxZoom,
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _bubbleRotationTimer?.cancel();
    _stopBubbleRotation();
    super.dispose();
  }

  void _initializeProviders() {
    final locationProvider = context.read<LocationProvider>();
    final messageProvider = context.read<MessageProvider>();
    final taskProvider = context.read<TaskProvider>();

    // 初始化時更新用戶的實際範圍權限
    _currentRadius = _getUserTotalRange();

    // 監聽TaskProvider變化，當用戶權限更新時重新計算範圍
    taskProvider.addListener(() {
      final newRadius = _getUserTotalRange();
      if (newRadius != _currentRadius) {
        _currentRadius = newRadius;
        // 如果有位置信息，立即更新地圖範圍
        if (locationProvider.currentPosition != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateUserLocationAndRadius(locationProvider);
          });
        }
      }
    });

    locationProvider.addListener(() {
      if (locationProvider.currentPosition != null) {
        // 每次位置更新時都使用最新的用戶權限範圍
        _currentRadius = _getUserTotalRange();
        messageProvider.updateUserLocation(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude,
          radius: _currentRadius,
        );
        // 使用 addPostFrameCallback 來避免在 build 過程中調用 setState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateUserLocationAndRadius(locationProvider);
        });
      }
    });

    messageProvider.addListener(() {
      // 使用 addPostFrameCallback 來避免在 build 過程中調用 setState
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _updateMarkers(
            messageProvider.messages, context.read<LocationProvider>());
      });
    });

    locationProvider.getCurrentLocation().then((_) {
      if (locationProvider.currentPosition != null) {
        _goToCurrentLocation(locationProvider.currentPosition!);
        // 啟動 AI 機器人自動生成訊息
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startAIBotService(locationProvider.currentPosition!);
        });
      }
    });
  }

  // 啟動 AI 機器人服務
  void _startAIBotService(dynamic position) {
    try {
      final aiBotService = AIGeographicBotService();
      
      // 設置用戶位置
      aiBotService.updateUserLocation(
        position.latitude,
        position.longitude,
      );
      
      // 配置回調函數，將生成的訊息添加到地圖
      aiBotService.setOnMessageGenerated((content, lat, lng, radius, duration) {
        final messageProvider = context.read<MessageProvider>();
        
        // 創建機器人訊息
        messageProvider.sendMessage(
          content: content,
          latitude: lat,
          longitude: lng,
          radius: radius,
          duration: duration,
          isAnonymous: true,
        );
      });
      
      // 啟動機器人服務
      aiBotService.startService();
      
      // 立即生成初始訊息，讓用戶感覺有活躍度
      if (AIBotConfig.autoStartOnAppLaunch) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final initialCount = AIBotConfig.initialMessageMin + 
            (DateTime.now().millisecond % (AIBotConfig.initialMessageMax - AIBotConfig.initialMessageMin + 1));
          
          for (int i = 0; i < initialCount; i++) {
            Timer(Duration(milliseconds: i * AIBotConfig.initialMessageInterval), () {
              aiBotService.generateMessageNow();
            });
          }
        });
      }
      
      print('🤖 AI 機器人服務已啟動，將自動生成訊息');
    } catch (e) {
      print('❌ 啟動 AI 機器人服務失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer2<LocationProvider, MessageProvider>(
        builder: (context, locationProvider, messageProvider, child) {
          return Stack(
            children: [
              Stack(
                children: [
                  GoogleMap(
                    key: _mapKey,
                    mapType: MapType.normal,
                    initialCameraPosition: _kInitialPosition,
                    minMaxZoomPreference: MinMaxZoomPreference(
                      _getMinZoomLevel(), // 限制最小縮放（最大顯示範圍為用戶範圍的2倍）
                      _getMaxZoomLevel(), // 限制最大縮放到街道級別
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                      }
                      _mapController = controller;
                      // 設定縮放限制
                      _updateZoomLimits();
                      // 設定美觀的地圖樣式，保留路名顯示
                      // 注意：setMapStyle 已被棄用，使用 GoogleMap.style 屬性
                      // controller.setMapStyle('''[{
                      //   "featureType": "poi",
                      //   "elementType": "labels",
                      //   "stylers": [{"visibility": "off"}]
                      // },
                      // {
                      //   "featureType": "administrative",
                      //   "elementType": "labels",
                      //   "stylers": [{"visibility": "simplified"}]
                      // },
                      // {
                      //   "featureType": "transit",
                      //   "elementType": "labels",
                      //   "stylers": [{"visibility": "off"}]
                      // },
                      // {
                      //   "featureType": "water",
                      //   "elementType": "geometry",
                      //   "stylers": [
                      //     {"color": "#a3d8f7"}
                      //   ]
                      // },
                      // {
                      //   "featureType": "landscape",
                      //   "elementType": "geometry",
                      //   "stylers": [
                      //     {"color": "#f5f5f5"}
                      //   ]
                      // },
                      // {
                      //   "featureType": "road.highway",
                      //   "elementType": "geometry.fill",
                      //   "stylers": [
                      //     {"color": "#ffffff"}
                      //   ]
                      // },
                      // {
                      //   "featureType": "road",
                      //   "elementType": "geometry",
                      //   "stylers": [
                      //     {"color": "#ffffff"}
                      //   ]
                      // },
                      // {
                      //   "featureType": "road",
                      //   "elementType": "labels.text.fill",
                      //   "stylers": [
                      //     {"color": "#666666"}
                      //   ]
                      // },
                      // {
                      //   "featureType": "road",
                      //   "elementType": "labels.text.stroke",
                      //   "stylers": [
                      //     {"color": "#ffffff"},
                      //     {"weight": 2}
                      //   ]
                      // },
                      // {
                      //   "featureType": "transit",
                      //   "stylers": [{"visibility": "off"}]
                      // },
                      // {
                      //   "featureType": "administrative",
                      //   "elementType": "geometry.stroke",
                      //   "stylers": [
                      //     {"color": "#efefe"},
                      //     {"weight": 1}
                      //   ]
                      // },
                      // {
                      //   "featureType": "poi",
                      //   "stylers": [{"visibility": "off"}]
                      // }
                      // ]''');
                    },
                    markers: _getAllMarkers(),
                    circles: _circles,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    // 隱藏Google標誌和版權資訊
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    buildingsEnabled: true,
                    liteModeEnabled: false,
                    indoorViewEnabled: false,
                    trafficEnabled: false,
                    onCameraMove: (CameraPosition position) {
                      // 地圖移動時更新泡泡位置
                      _updateBubblePositions();
                      // 檢查縮放限制
                      _checkZoomLimits(position);
                    },
                    onCameraIdle: () {
                      // 地圖停止移動時更新泡泡位置
                      _updateBubblePositions();
                    },
                  ),
                  ..._bubbleOverlays,
                ],
              ),
              _buildTopBar(),
              _buildStatusIndicators(locationProvider, messageProvider),
              _buildBottomWidgets(locationProvider),
              // 添加美觀的覆蓋層遮擋底部版權信息
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.backgroundColor.withOpacity(0.5),
                        AppColors.backgroundColor,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF667eea).withOpacity(0.95),
              const Color(0xFF764ba2).withOpacity(0.95),
              const Color(0xFFf093fb).withOpacity(0.95),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/app_logo.svg',
                  width: 36,
                  height: 36,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // App名稱和標語
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.tagline,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // 中間：用戶權限顯示（兩排）
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final bonusDuration = taskProvider.bonusDurationMinutes;
                final bonusRange = taskProvider.bonusRangeMeters;

                // 基礎設定：1小時 = 60分鐘，1公里 = 1000米
                const baseDurationMinutes = 60;
                const baseRangeMeters = 1000.0;

                // 總計 = 基礎 + 獎勵
                final totalDurationMinutes =
                    baseDurationMinutes + bonusDuration;
                final totalRangeMeters = baseRangeMeters + bonusRange;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 第一排：時長權限
                    SizedBox(
                      width: 80, // 固定寬度確保一致
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${totalDurationMinutes ~/ 60}h${totalDurationMinutes % 60 > 0 ? '${totalDurationMinutes % 60}m' : ''}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // 第二排：距離權限
                    SizedBox(
                      width: 80, // 固定寬度確保一致
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${(totalRangeMeters / 1000).toStringAsFixed(1)}km',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            // 右側按鈕區域
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 登入按鈕
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return _buildTopBarButton(
                      icon: authProvider.isSignedIn
                          ? Icons.account_circle
                          : Icons.login,
                      onTap: () {
                        if (authProvider.isSignedIn) {
                          _showUserMenu(context, authProvider);
                        } else {
                          _showLoginOptions(context, authProvider);
                        }
                      },
                      isActive: authProvider.isSignedIn,
                    );
                  },
                ),
                const SizedBox(width: 8),
                // 任務中心按鈕
                Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    final claimableCount = taskProvider.claimableTasks.length;

                    return _buildTopBarButton(
                      icon: Icons.task_alt,
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.25,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.2,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: const TaskScreen(),
                              ),
                            ),
                          ),
                        );
                      },
                      badge: claimableCount > 0 ? claimableCount : null,
                    );
                  },
                ),
                const SizedBox(width: 8),
                // AI 機器人按鈕
                _buildTopBarButton(
                  icon: Icons.smart_toy,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIBotControlScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                // 設定按鈕
                _buildTopBarButton(
                  icon: Icons.tune_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicators(LocationProvider lp, MessageProvider mp) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 90,
      left: 16,
      right: 16,
      child: Column(
        children: [
          if (lp.isLoading) _buildStatusIndicator('正在獲取位置...'),
          if (lp.errorMessage != null)
            _buildErrorIndicator(
                lp.errorMessage!, () => lp.getCurrentLocation()),
          if (mp.isLoading) _buildStatusIndicator('正在發送訊息...'),
          if (mp.errorMessage != null)
            _buildErrorIndicator(mp.errorMessage!, () => mp.clearError()),
        ],
      ),
    );
  }

  Widget _buildBottomWidgets(LocationProvider locationProvider) {
    return Stack(
      children: [
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 16,
          right: 16,
          child: QuickSendWidget(onSend: _handleSendMessage),
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 200,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.secondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.primaryColor,
                  blurRadius: 15,
                  offset: Offset(0, 6),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                if (locationProvider.currentPosition != null) {
                  _goToCurrentLocation(locationProvider.currentPosition!);
                } else {
                  locationProvider.getCurrentLocation();
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Set<Marker> _getAllMarkers() {
    final allMarkers = <Marker>{};
    if (_userLocationMarker != null) {
      allMarkers.add(_userLocationMarker!);
    }
    allMarkers.addAll(_markers);
    return allMarkers;
  }

  void _updateUserLocationAndRadius(LocationProvider locationProvider) {
    if (locationProvider.currentPosition != null) {
      final userPosition = LatLng(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
      );

      // 更新用戶位置標記，使用小小的位置點
      final newUserMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: userPosition,
        infoWindow: const InfoWindow(),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        zIndex: 2, // 確保用戶位置標記顯示在最上層
        flat: true,
        anchor: const Offset(0.5, 0.5),
      );

      // 更新範圍圓圈
      final newCircle = Circle(
        circleId: const CircleId('user_radius'),
        center: userPosition,
        radius: _currentRadius,
        fillColor: AppColors.primaryColor.withOpacity(0.1),
        strokeColor: AppColors.primaryColor,
        strokeWidth: 2,
      );

      setState(() {
        _userLocationMarker = newUserMarker;
        _circles.clear();
        _circles.add(newCircle);
        // 確保用戶位置標記顯示在地圖上
        _markers.clear();
        _markers.add(_userLocationMarker!);
      });

      // 調整地圖縮放到最佳視角以最大化顯示用戶範圍
      _adjustMapViewToShowRange(userPosition);
    }
  }

  // 調整地圖視角以最大化顯示用戶範圍
  Future<void> _adjustMapViewToShowRange(LatLng center) async {
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;

      // 計算最佳縮放級別
      final optimalZoom = _getInitialZoomForRadius(_currentRadius);

      final newPosition = CameraPosition(
        target: center,
        zoom: optimalZoom,
      );

      // 平滑動畫到最佳視角
      controller.animateCamera(
        CameraUpdate.newCameraPosition(newPosition),
        // 使用較慢的動畫讓用戶看到縮放過程
      );
    }
  }

  Future<void> _updateMarkers(
      List<Message> messages, LocationProvider locationProvider) async {
    if (locationProvider.currentPosition == null) {
      setState(() {
        _markers.clear();
        _bubbleOverlays.clear();
      });
      return;
    }

    final userPosition = locationProvider.currentPosition!;
    final messageProvider = context.read<MessageProvider>();

    // 只顯示在用戶範圍內且在訊息發送者設定範圍內的訊息
    final messagesInRange = messages.where((message) {
      // 用戶自己發送的訊息始終可見
      final isUserMessage = message.senderId == messageProvider.currentUserId;
      if (isUserMessage) return true;

      // 計算用戶與訊息的距離
      final distance = _calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        message.latitude,
        message.longitude,
      );
      // 訊息只有在用戶範圍內且在訊息發送者設定的範圍內才可見
      return distance <= _currentRadius && distance <= message.radius;
    }).toList();

    // 更新訊息泡泡覆蓋層
    await _updateMessageBubbles(messagesInRange);

    // 清空所有訊息標記，只保留用戶位置標記
    setState(() {
      _markers.clear();
    });
  }

  List<Message> _currentMessages = [];

  Future<void> _updateMessageBubbles(List<Message> messages) async {
    if (_mapController == null) return;

    // 如果訊息列表改變，重置頂層泡泡索引
    if (_currentMessages.length != messages.length) {
      _currentTopBubbleIndex = 0;
    }

    _currentMessages = messages;
    await _updateBubblePositions();
  }

  Future<void> _updateBubblePositions() async {
    if (_mapController == null || _currentMessages.isEmpty) return;

    final bubbles = <MessageBubbleOverlay>[];

    // 重新排序訊息，讓當前頂層泡泡排在最後（最上層）
    final reorderedMessages = <Message>[];
    for (int i = 0; i < _currentMessages.length; i++) {
      if (i != _currentTopBubbleIndex) {
        reorderedMessages.add(_currentMessages[i]);
      }
    }
    // 將頂層泡泡添加到最後
    if (_currentTopBubbleIndex < _currentMessages.length) {
      reorderedMessages.add(_currentMessages[_currentTopBubbleIndex]);
    }

    for (int i = 0; i < reorderedMessages.length; i++) {
      final message = reorderedMessages[i];
      try {
        final screenCoordinate = await _mapController!.getScreenCoordinate(
          LatLng(message.latitude, message.longitude),
        );

        // 最後一個（頂層）泡泡的zIndex為1，其他為0
        final zIndex = i == reorderedMessages.length - 1 ? 1 : 0;

        bubbles.add(
          MessageBubbleOverlay(
            content: message.content,
            left: screenCoordinate.x.toDouble(),
            top: screenCoordinate.y.toDouble(),
            zIndex: zIndex,
            expiresAt: message.expiresAt,
            bubbleColor: _getBubbleColor(message),
            gender: message.gender,
            onTap: () => _showMessageBubble(message),
          ),
        );
      } catch (e) {
        // 如果轉換失敗，跳過這個訊息
        continue;
      }
    }

    if (mounted) {
      setState(() {
        _bubbleOverlays.clear();
        _bubbleOverlays.addAll(bubbles);
      });
    }

    // 啟動泡泡輪播定時器
    _startBubbleRotation();
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // 地球半徑（米）
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  void _startBubbleRotation() {
    // 如果已有定時器在運行，先取消
    _bubbleRotationTimer?.cancel();

    // 只有當有多個泡泡時才啟動輪播
    if (_currentMessages.length <= 1) return;

    _bubbleRotationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || _currentMessages.isEmpty) {
        timer.cancel();
        return;
      }

      // 切換到下一個泡泡作為頂層
      _currentTopBubbleIndex =
          (_currentTopBubbleIndex + 1) % _currentMessages.length;

      // 更新泡泡顯示
      _updateBubblePositions();
    });
  }

  void _stopBubbleRotation() {
    _bubbleRotationTimer?.cancel();
    _bubbleRotationTimer = null;
  }

  Color _getBubbleColor(Message message) {
    // 如果訊息有固定的泡泡顏色，使用該顏色
    if (message.bubbleColor != null) {
      return message.bubbleColor!;
    }

    // 用戶訊息根據性別決定顏色
    switch (message.gender) {
      case Gender.male:
        return const Color(0xFF9C27B0); // 紫色
      case Gender.female:
        return const Color(0xFFE91E63); // 粉紅色
      default:
        return AppColors.primaryColor; // 預設顏色
    }
  }

  void _handleSendMessage(
      String message, double radius, Duration duration, bool isAnonymous) {
    final locationProvider = context.read<LocationProvider>();
    final messageProvider = context.read<MessageProvider>();

    if (locationProvider.currentPosition == null) {
      _showSnackBar('請先獲取您的位置資訊', isError: true);
      return;
    }

    // 更新當前範圍
    setState(() {
      _currentRadius = radius;
    });

    // 更新機器人服務的用戶範圍
    messageProvider.updateUserLocation(
      locationProvider.currentPosition!.latitude,
      locationProvider.currentPosition!.longitude,
      radius: radius,
    );

    messageProvider
        .sendMessage(
      content: message,
      latitude: locationProvider.currentPosition!.latitude,
      longitude: locationProvider.currentPosition!.longitude,
      radius: radius,
      duration: duration,
      isAnonymous: isAnonymous,
    )
        .then((message) {
      if (messageProvider.errorMessage == null) {
        _showSnackBar('訊息已發送！將在 ${duration.inMinutes} 分鐘後消失');
        // 立即顯示訊息泡泡，確保用戶能立即看到自己的訊息
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showMessageBubble(message);
          }
        });
      }
    });
  }

  Future<void> _goToCurrentLocation(dynamic position) async {
    final GoogleMapController controller = await _controller.future;

    // 計算最佳縮放級別以最大化顯示用戶範圍
    final optimalZoom = _getInitialZoomForRadius(_currentRadius);

    final newPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: optimalZoom,
    );

    // 平滑動畫到新位置
    await controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));

    // 更新範圍圓圈以確保正確顯示
    _updateCircles(LatLng(position.latitude, position.longitude));
  }

  // 更新範圍圓圈顯示
  void _updateCircles(LatLng center) {
    setState(() {
      _circles.clear();
      _circles.add(
        Circle(
          circleId: const CircleId('user_range'),
          center: center,
          radius: _currentRadius,
          fillColor: AppColors.primaryColor.withOpacity(0.1),
          strokeColor: AppColors.primaryColor.withOpacity(0.5),
          strokeWidth: 2,
        ),
      );
    });
  }

  void _showSnackBar(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? AppColors.errorColor : AppColors.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }



  void _showMessageBubble(Message message) {
    if (!mounted) return;

    // 記錄觀看
    final messageProvider = context.read<MessageProvider>();
    messageProvider.viewMessage(message.id);

    // 計算剩餘時間
    final now = DateTime.now();
    final remaining = message.expiresAt.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final remainingText = hours > 0 ? '$hours小時$minutes分鐘' : '$minutes分鐘';

    // 格式化發送時間
    final createdTime = message.createdAt;
    final timeText =
        '${createdTime.month}/${createdTime.day} ${createdTime.hour.toString().padLeft(2, '0')}:${createdTime.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 280),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 發送者資訊
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 性別圖標
                    Icon(
                      message.gender == Gender.male
                          ? Icons.male
                          : message.gender == Gender.female
                              ? Icons.female
                              : Icons.person,
                      color: message.gender == Gender.male
                          ? Colors.blue[200]
                          : message.gender == Gender.female
                              ? Colors.pink[200]
                              : Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    // 發送者名字
                    Text(
                      message.senderName ?? '匿名用戶',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 訊息內容
              Expanded(
                child: Center(
                  child: Consumer<MessageProvider>(
                    builder: (context, messageProvider, child) {
                      return Text(
                        messageProvider.getMessageDisplayContent(message),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 資訊區域
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 觀看數
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility,
                            color: Colors.white70, size: 14),
                        const SizedBox(height: 2),
                        Text(
                          '${message.viewCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // 點讚數
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.thumb_up,
                            color: Colors.white70, size: 14),
                        const SizedBox(height: 2),
                        Text(
                          '${message.likeCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // 剩餘時間
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer,
                            color: Colors.white70, size: 14),
                        const SizedBox(height: 2),
                        Text(
                          remainingText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 發送時間
              Text(
                timeText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 12),

              // 關閉按鈕
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '關閉',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator(String message, VoidCallback onRetry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorColor),
          const SizedBox(width: 12),
          Expanded(
              child: Text(message,
                  style: const TextStyle(color: AppColors.errorColor))),
          TextButton(onPressed: onRetry, child: const Text('重試')),
        ],
      ),
    );
  }

  // 顯示登入選項
  void _showLoginOptions(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('登入選項'),
        content: const Text('選擇登入方式或以訪客身份繼續使用'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 以訪客身份繼續，不做任何操作
            },
            child: const Text('訪客模式'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // 檢查是否使用佔位符Client ID
              if (_isPlaceholderClientId()) {
                _showConfigurationDialog(context);
                return;
              }

              final success = await authProvider.signInWithGoogle();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('登入成功！')),
                );
              }
            },
            child: const Text('Google登入'),
          ),
        ],
      ),
    );
  }

  // 顯示用戶選單
  void _showUserMenu(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('歡迎，${authProvider.userDisplayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authProvider.user?.email != null)
              Text('Email: ${authProvider.user!.email}'),
            const SizedBox(height: 8),
            const Text('您已成功登入'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已登出')),
                );
              }
            },
            child: const Text('登出'),
          ),
        ],
      ),
    );
  }

  // 檢查是否為佔位符Client ID
  bool _isPlaceholderClientId() {
    return true; // 目前總是返回true，因為我們使用的是佔位符
  }

  // 顯示配置提示對話框
  void _showConfigurationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Google登入配置'),
          content: const Text(
            'Google登入功能需要配置有效的Client ID。\n\n'
            '請聯繫開發者完成配置，或繼續使用訪客模式。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('了解'),
            ),
          ],
        );
      },
    );
  }

  // 統一的頂部欄位按鈕樣式
  Widget _buildTopBarButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    int? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(isActive ? 0.3 : 0.2),
              Colors.white.withOpacity(isActive ? 0.2 : 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(isActive ? 0.4 : 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            if (badge != null && badge > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
