import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/message_provider.dart';
import '../providers/location_provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/map_styles.dart';
import '../widgets/quick_send_widget.dart';
import '../widgets/message_bubble_overlay.dart';
import '../widgets/night_fog_overlay.dart';
import '../widgets/futuristic_bottom_nav.dart';
import '../widgets/premium_message_dialog.dart';
// 移除自定義圖示import，使用原始Material Design圖示
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
  final Set<Circle> _circles = {}; // 用户范围圆
  Marker? _userLocationMarker;
  BitmapDescriptor? _cachedUserPinIcon;
  double _currentRadius = 1000.0; // 基礎範圍1公里，將根據用戶權限動態更新
  GoogleMapController? _mapController;
  final List<MessageBubbleOverlay> _bubbleOverlays = [];
  final GlobalKey _mapKey = GlobalKey();
  Timer? _bubbleRotationTimer;
  int _currentTopBubbleIndex = 0;
  double _currentZoom = 15.0; // 追蹤當前縮放級別

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
      _prepareUserPinIcon();
    });
  }

  // 獲取用戶的實際範圍權限（基礎+獎勵）
  double _getUserTotalRange() {
    final taskProvider = context.read<TaskProvider>();
    const baseRangeMeters = 1000.0; // 基礎1公里
    final bonusRange = taskProvider.bonusRangeMeters;
    return baseRangeMeters + bonusRange;
  }

  // 移除固定的初始位置，改为动态获取用户位置

  // 根據用戶範圍計算適合的縮放級別（放大20%顯示範圍）
  double _getInitialZoomForRadius(double radius) {
    // 顯示用戶範圍圓的120%，放大20%
    double displayRadius = radius * 1.2; // 用戶範圍的120%

    // 根據用戶範圍計算縮放級別，使用較小的縮放值來顯示更大範圍
    if (displayRadius >= 5000) return 12.0; // 5公里範圍
    if (displayRadius >= 4000) return 12.5; // 4公里範圍
    if (displayRadius >= 3000) return 13.0; // 3公里範圍
    if (displayRadius >= 2500) return 13.5; // 2.5公里範圍
    if (displayRadius >= 2000) return 14.0; // 2公里範圍
    if (displayRadius >= 1500) return 14.5; // 1.5公里範圍
    if (displayRadius >= 1000) return 15.0; // 1公里範圍
    if (displayRadius >= 750) return 15.5; // 750米範圍
    if (displayRadius >= 500) return 16.0; // 500米範圍
    return 16.5; // 最小範圍
  }

  // 計算最小縮放級別（設定最大可視範圍為3公里）
  double _getMinZoomLevel() {
    // 設定最大可視範圍為3公里（3000米）
    const double maxViewRadius = 3000.0; // 3公里

    // 根據3公里範圍計算最小縮放級別
    return 12.0; // 3公里範圍對應的縮放級別
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

  // 檢查縮放限制 - 完全禁用，允許自由縮放和拖動
  void _checkZoomLimits(CameraPosition position) {
    // 完全禁用縮放限制檢查，允許用戶自由縮放和拖動地圖
    // 不再強制地圖回到用戶中心
    return;
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
          messageProvider.messages,
          context.read<LocationProvider>(),
        );
      });
    });

    // 立即获取用户位置并设置地图
    locationProvider.getCurrentLocation().then((_) {
      if (locationProvider.currentPosition != null) {
        // 等待地图控制器准备就绪后再设置位置
        _waitForMapControllerAndSetPosition(locationProvider.currentPosition!);
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
      aiBotService.updateUserLocation(position.latitude, position.longitude);

      // 設置用戶範圍（基礎範圍 + 獎勵範圍）
      final userRadius = _getUserTotalRange();
      aiBotService.updateUserRadius(userRadius);

      // 配置回調函數，將生成的訊息添加到地圖
      aiBotService.setOnMessageGenerated((content, lat, lng, radius, duration) {
        final messageProvider = context.read<MessageProvider>();

        // 直接添加機器人訊息，不通過 sendMessage 方法
        messageProvider.addBotMessage(content, lat, lng, radius, duration);
      });

      // 啟動機器人服務
      aiBotService.startService();

      // 立即生成初始訊息，讓用戶感覺有活躍度
      if (AIBotConfig.autoStartOnAppLaunch) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final initialCount = AIBotConfig.initialMessageMin +
              (DateTime.now().millisecond %
                  (AIBotConfig.initialMessageMax -
                      AIBotConfig.initialMessageMin +
                      1));

          for (int i = 0; i < initialCount; i++) {
            Timer(
              Duration(milliseconds: i * AIBotConfig.initialMessageInterval),
              () {
                aiBotService.generateMessageNow();
              },
            );
          }
        });
      }

      // 靜默啟動，不在控制台輸出任何機器人提示
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
                    style: MapStyles.forPlatform(), // 重新啟用玻璃感霓虹風格地圖樣式
                    initialCameraPosition: CameraPosition(
                      target: LatLng(0, 0), // 臨時位置，會被用戶位置覆蓋
                      zoom: 15.0, // 適合3公里範圍的初始縮放級別
                    ),
                    // 設定縮放限制，最大可視範圍為3公里
                    minMaxZoomPreference: MinMaxZoomPreference(
                      _getMinZoomLevel(),
                      _getMaxZoomLevel(),
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                      }
                      _mapController = controller;
                      // 完全移除縮放限制設定
                      // _updateZoomLimits();

                      // 如果用户位置已经获取，立即设置地图位置
                      final locationProvider = context.read<LocationProvider>();
                      if (locationProvider.currentPosition != null) {
                        _setInitialMapPosition(
                          locationProvider.currentPosition!,
                        );
                      }
                    },
                    markers: _getAllMarkers(),
                    circles: _circles,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    buildingsEnabled: false,
                    liteModeEnabled: false,
                    indoorViewEnabled: false,
                    trafficEnabled: false,
                    rotateGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    onCameraMove: (CameraPosition position) {
                      // 更新當前縮放級別
                      _currentZoom = position.zoom;
                      // 地圖移動時更新泡泡位置
                      _updateBubblePositions();
                      // 完全移除所有限制檢查，允許自由移動和縮放
                    },
                    onCameraIdle: () {
                      // 地圖停止移動時更新泡泡位置
                      _updateBubblePositions();
                    },
                  ),
                  const NightFogOverlay(opacity: 0.16, starDensity: 0.9),
                  ..._bubbleOverlays,
                ],
              ),
              _buildTopBar(),
              _buildStatusIndicators(locationProvider, messageProvider),
              // 新的未来感底部导航栏
              Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  return FuturisticBottomNav(
                    onLocationPressed: () async {
                      try {
                        // 防止重复点击
                        if (locationProvider.isLoading) {
                          return;
                        }

                        if (locationProvider.currentPosition != null) {
                          await _goToCurrentLocation(
                              locationProvider.currentPosition!);
                        } else {
                          await locationProvider.getCurrentLocation();

                          // 如果获取位置成功，移动到当前位置
                          if (locationProvider.currentPosition != null) {
                            await _goToCurrentLocation(
                                locationProvider.currentPosition!);
                          }
                        }
                      } catch (e) {
                        print('定位按钮点击错误: $e');
                      }
                    },
                    onMessagePressed: _openQuickSendSheet,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceColor.withValues(alpha: 0.15),
                AppColors.surfaceColor.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 左側：Logo + 應用名稱
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    // Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.primaryColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 應用名稱和標語
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                  color: AppColors.primaryColor
                                      .withValues(alpha: 0.6),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.tagline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // 右側：用戶權限顯示（水平排列）
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

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 時長權限
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColor.withValues(alpha: 0.2),
                              AppColors.secondaryColor.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                AppColors.primaryColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primaryColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${totalDurationMinutes ~/ 60}h${totalDurationMinutes % 60 > 0 ? '${totalDurationMinutes % 60}m' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 4,
                                    color: AppColors.primaryColor
                                        .withValues(alpha: 0.6),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 距離權限
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.secondaryColor.withValues(alpha: 0.2),
                              AppColors.primaryColor.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                AppColors.secondaryColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryColor
                                  .withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${(totalRangeMeters / 1000).toStringAsFixed(1)}km',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 4,
                                    color: AppColors.secondaryColor
                                        .withValues(alpha: 0.6),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
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
              lp.errorMessage!,
              () => lp.getCurrentLocation(),
            ),
          if (mp.errorMessage != null)
            _buildErrorIndicator(mp.errorMessage!, () => mp.clearError()),
        ],
      ),
    );
  }

  Set<Marker> _getAllMarkers() {
    final allMarkers = <Marker>{};
    allMarkers.addAll(_markers);
    // 不显示用户位置标记
    return allMarkers;
  }

  void _updateUserLocationAndRadius(LocationProvider locationProvider) {
    if (locationProvider.currentPosition != null) {
      final userPosition = LatLng(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
      );

      // 不创建用户位置标记
      setState(() {
        _userLocationMarker = null;
        _markers.clear();
      });

      // 更新范围圆
      _updateCircles(userPosition);

      // 暫時禁用自動縮放調整，允許用戶自由縮放
      // _adjustMapViewToShowRange(userPosition);
    }
  }

  // 等待地图控制器准备就绪并设置位置
  void _waitForMapControllerAndSetPosition(dynamic position) {
    if (_controller.isCompleted) {
      _setInitialMapPosition(position);
    } else {
      // 等待控制器准备就绪
      _controller.future.then((_) {
        _setInitialMapPosition(position);
      }).catchError((error) {
        print('等待地图控制器失败: $error');
        // 延迟重试
        Future.delayed(const Duration(milliseconds: 1000), () {
          _waitForMapControllerAndSetPosition(position);
        });
      });
    }
  }

  // 设置初始地图位置到用户位置
  Future<void> _setInitialMapPosition(dynamic position) async {
    // 等待地图控制器准备就绪
    if (_controller.isCompleted) {
      try {
        final GoogleMapController controller = await _controller.future;

        // 設定縮放級別為3公里範圍
        const double optimalZoom = 15.0; // 3公里範圍對應的縮放級別

        final newPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: optimalZoom, // 使用計算出的最佳縮放級別
        );

        // 立即设置位置，不使用动画
        await controller.moveCamera(
          CameraUpdate.newCameraPosition(newPosition),
        );
      } catch (e) {
        print('设置初始地图位置失败: $e');
        // 如果失败，稍后重试
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_controller.isCompleted) {
            _setInitialMapPosition(position);
          }
        });
      }
    } else {
      // 如果控制器还没准备好，稍后重试
      Future.delayed(const Duration(milliseconds: 300), () {
        _setInitialMapPosition(position);
      });
    }
  }

  // 調整地圖視角以最大化顯示用戶範圍
  Future<void> _adjustMapViewToShowRange(LatLng center) async {
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;

      // 設定縮放級別為3公里範圍
      const double optimalZoom = 15.0; // 3公里範圍對應的縮放級別

      final newPosition = CameraPosition(target: center, zoom: optimalZoom);

      // 平滑動畫到最佳視角
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(newPosition),
        // 使用較慢的動畫讓用戶看到縮放過程
      );
    }
  }

  Future<void> _updateMarkers(
    List<Message> messages,
    LocationProvider locationProvider,
  ) async {
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

        // 距離顯示（以目前相機中心近似使用者位置計算）
        final cameraPosition = await _mapController!.getLatLng(
          const ScreenCoordinate(x: 0, y: 0),
        );
        final distanceMeters = _calculateDistance(
          cameraPosition.latitude,
          cameraPosition.longitude,
          message.latitude,
          message.longitude,
        );
        final distanceText = distanceMeters >= 1000
            ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
            : '${distanceMeters.toStringAsFixed(0)} m';

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
            likeCount: message.likeCount,
            distanceText: distanceText,
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
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
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

  Future<void> _prepareUserPinIcon() async {
    final icon = await _createUserPinIcon(size: 80);
    if (mounted) {
      setState(() {
        _cachedUserPinIcon = icon;
        // 立即用新圖示替換既有的用戶標記
        if (_userLocationMarker != null) {
          _userLocationMarker = _userLocationMarker!.copyWith(
            iconParam: _cachedUserPinIcon,
          );
        }
      });
    }
  }

  Future<BitmapDescriptor> _createUserPinIcon({double size = 72}) async {
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final double canvasSize = size * devicePixelRatio;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, canvasSize, canvasSize),
    );

    final center = Offset(canvasSize / 2, canvasSize / 2);
    final radius = canvasSize * 0.28;

    // 外圍未來主義霓虹光暈
    final glowPaint = Paint()
      ..color = AppColors.primaryColor.withValues(alpha: 0.7) // 使用新的霓虹藍
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22); // 更強的光暈效果
    canvas.drawCircle(center, radius * 1.4, glowPaint);

    // 內部底圓（半透明白）
    final basePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.95);
    canvas.drawCircle(center, radius, basePaint);

    // 外框：未來主義霓虹藍
    final borderPaint = Paint()
      ..color = AppColors.secondaryColor // 使用亮霓虹藍
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.25; // 稍微加粗邊框
    canvas.drawCircle(
      center,
      radius - borderPaint.strokeWidth / 2,
      borderPaint,
    );

    // 中央白色星型
    final starPath = Path();
    const int points = 5;
    final double outerR = radius * 0.58;
    final double innerR = outerR * 0.48;
    for (int i = 0; i < points * 2; i++) {
      final double isOuter = i.isEven ? outerR : innerR;
      final double angle = (math.pi / points) * i - math.pi / 2;
      final Offset pos = Offset(
        center.dx + isOuter * math.cos(angle),
        center.dy + isOuter * math.sin(angle),
      );
      if (i == 0) {
        starPath.moveTo(pos.dx, pos.dy);
      } else {
        starPath.lineTo(pos.dx, pos.dy);
      }
    }
    starPath.close();
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(starPath, starPaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(canvasSize.toInt(), canvasSize.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
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
    String message,
    double radius,
    Duration duration,
    bool isAnonymous, [
    String? customSenderName,
  ]) {
    final locationProvider = context.read<LocationProvider>();
    final messageProvider = context.read<MessageProvider>();

    if (locationProvider.currentPosition == null) {
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
      customSenderName: customSenderName,
    )
        .then((message) {
      if (messageProvider.errorMessage == null) {
        // 訊息發送成功，不顯示任何提示
      }
    });
  }

  Future<void> _goToCurrentLocation(dynamic position) async {
    try {
      // 等待地图控制器准备就绪，添加超时处理
      final GoogleMapController controller = await _controller.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('地图控制器初始化超时');
        },
      );

      // 只移動到用戶位置，不改變縮放級別
      final newPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        // 不設置 zoom，保持當前縮放級別
      );

      // 平滑動畫到新位置
      await controller
          .animateCamera(CameraUpdate.newCameraPosition(newPosition));

      // 更新范围圆
      _updateCircles(LatLng(position.latitude, position.longitude));
    } catch (e) {
      print('定位到当前位置失败: $e');
      // 如果地图控制器还没准备好，延迟重试
      if (e.toString().contains('超时') ||
          e.toString().contains('not completed')) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _goToCurrentLocation(position);
      } else {
        rethrow;
      }
    }
  }

  // 更新用户范围圆
  void _updateCircles(LatLng center) {
    setState(() {
      _circles.clear();
      _circles.add(
        Circle(
          circleId: const CircleId('user_range'),
          center: center,
          radius: _currentRadius,
          fillColor: AppColors.primaryColor.withValues(
            alpha: 0.08,
          ), // 未來主義霓虹藍填充
          strokeColor: AppColors.primaryColor.withValues(alpha: 0.6), // 發光邊框
          strokeWidth: 3, // 更粗的邊框以增強發光效果
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
                color: Colors.black.withValues(alpha: 0.2),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 觀看數
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: Colors.white70,
                          size: 14,
                        ),
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
                        const Icon(
                          Icons.thumb_up,
                          color: Colors.white70,
                          size: 14,
                        ),
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
                        const Icon(
                          Icons.timer,
                          color: Colors.white70,
                          size: 14,
                        ),
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
                style: const TextStyle(color: Colors.white70, fontSize: 11),
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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
        color: AppColors.surfaceColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
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
        color: AppColors.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.errorColor),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('重試')),
        ],
      ),
    );
  }

  // 顯示登入選項

  // 顯示配置提示對話框

  // 開啟新的未來感訊息發送介面
  // 顯示高端訊息發送對話框
  void _openQuickSendSheet() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PremiumMessageDialog(
        onSend: (radius, duration, isAnonymous, message) {
          // 關閉對話框
          Navigator.of(context).pop();

          // 處理發送訊息
          _handleSendMessage(message, radius, duration, isAnonymous);
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // 顯示訊息輸入對話框
  void _showMessageInputDialog(
    double radius,
    Duration duration,
    bool isAnonymous,
  ) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 300),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0A1A).withValues(alpha: 0.95),
                const Color(0xFF1A1A2E).withValues(alpha: 0.95),
                const Color(0xFF16213E).withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00BFFF).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFF00BFFF).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題
              Text(
                '發送訊息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // 參數顯示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildParameterCard(
                    icon: Icons.access_time_rounded,
                    label: '持續時間',
                    value: '${duration.inHours}h',
                    color: const Color(0xFF8B5CF6),
                  ),
                  _buildParameterCard(
                    icon: Icons.straighten_rounded,
                    label: '距離範圍',
                    value: '${(radius / 1000).toStringAsFixed(1)}km',
                    color: const Color(0xFF06B6D4),
                  ),
                  _buildParameterCard(
                    icon: Icons.person_rounded,
                    label: '發送方式',
                    value: isAnonymous ? '匿名' : '實名',
                    color: const Color(0xFF00BFFF),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 訊息輸入框
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00BFFF).withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: '輸入您的訊息...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 按鈕
              Row(
                children: [
                  Expanded(
                    child: _buildDialogButton(
                      text: '取消',
                      color: Colors.grey,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDialogButton(
                      text: '發送',
                      color: const Color(0xFF00BFFF),
                      onPressed: () {
                        if (messageController.text.isNotEmpty) {
                          Navigator.of(context).pop();
                          _handleSendMessage(
                            messageController.text,
                            radius,
                            duration,
                            isAnonymous,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// 已移除天空漸層繪製
