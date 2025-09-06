import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/location_provider.dart';
import '../providers/message_provider.dart';
import '../providers/task_provider.dart';
import '../services/ai_geographic_bot_service.dart';
import '../widgets/quick_send_widget.dart';
import 'settings_screen.dart';
import 'task_screen.dart';
import 'ai_bot_control_screen.dart';

class ChatMapScreen extends StatefulWidget {
  const ChatMapScreen({super.key});

  @override
  State<ChatMapScreen> createState() => _ChatMapScreenState();
}

class _ChatMapScreenState extends State<ChatMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final List<Widget> _bubbleOverlays = [];
  final AIGeographicBotService _aiBotService = AIGeographicBotService();
  double _currentRadius = 1000.0;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
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
        if (locationProvider.currentPosition != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateUserLocationAndRadius(locationProvider);
          });
        }
      }
    });

    // 監聽LocationProvider變化
    locationProvider.addListener(() {
      if (locationProvider.currentPosition != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateUserLocationAndRadius(locationProvider);
        });
      }
    });

    // 監聽MessageProvider變化
    messageProvider.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _updateMarkers(messageProvider.messages, locationProvider);
      });
    });

    // 獲取位置
    locationProvider.getCurrentLocation().then((_) {
      if (locationProvider.currentPosition != null) {
        _goToCurrentLocation(locationProvider.currentPosition!);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startAIBotService(locationProvider.currentPosition!);
        });
      }
    });
  }

  void _startAIBotService(dynamic position) {
    try {
      _aiBotService.updateUserLocation(position.latitude, position.longitude);
      _aiBotService.updateUserRadius(_currentRadius);
      _aiBotService.setOnMessageGenerated((content, lat, lng, radius, duration) {
        final messageProvider = context.read<MessageProvider>();
        messageProvider.sendMessage(
          content: content,
          latitude: lat,
          longitude: lng,
          radius: radius,
          duration: duration,
          isAnonymous: true,
        );
      });
      _aiBotService.startService();
    } catch (e) {
      print('AI機器人服務啟動失敗: $e');
    }
  }

  double _getUserTotalRange() {
    final taskProvider = context.read<TaskProvider>();
    const baseRange = 1000.0;
    final bonusRange = taskProvider.bonusRangeMeters;
    return baseRange + bonusRange;
  }

  void _updateUserLocationAndRadius(LocationProvider locationProvider) {
    if (_mapController != null && locationProvider.currentPosition != null) {
      final position = locationProvider.currentPosition!;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  Future<void> _updateMarkers(List<dynamic> messages, LocationProvider locationProvider) async {
    if (_mapController == null) return;

    final Set<Marker> newMarkers = {};
    final List<Widget> newBubbleOverlays = [];

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final position = LatLng(message.latitude, message.longitude);
      
      newMarkers.add(
        Marker(
          markerId: MarkerId('message_$i'),
          position: position,
          infoWindow: InfoWindow(
            title: message.content,
            snippet: '半徑: ${message.radius.toStringAsFixed(0)}m',
          ),
        ),
      );

      // 簡化版本，不使用 MessageBubbleOverlay
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
      _bubbleOverlays.clear();
      _bubbleOverlays.addAll(newBubbleOverlays);
    });
  }

  void _goToCurrentLocation(Position position) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8F0), // 淺粉色背景
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Stack(
            children: [
              // 地圖背景
              Container(
                width: double.infinity,
                height: double.infinity,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    print('GoogleMap created successfully');
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(22.1987, 113.5439), // 澳門
                    zoom: 16.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  liteModeEnabled: false,
                  indoorViewEnabled: false,
                  trafficEnabled: false,
                  onCameraMove: (CameraPosition position) {
                    _updateBubblePositions();
                  },
                  onCameraIdle: () {
                    _updateBubblePositions();
                  },
                ),
              ),
              
              // 聊天界面覆蓋層
              _buildChatOverlay(locationProvider),
              
              // 功能按鈕
              _buildFunctionButtons(),
              
              // 位置權限請求提示
              if (locationProvider.isLoading && locationProvider.currentPosition == null)
                _buildLocationPermissionPrompt(locationProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatOverlay(LocationProvider locationProvider) {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 聊天標題
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8B4D1), // 淺紫色
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFE8B4D1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '秘跡 Miji',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showSettings(context),
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // 聊天內容區域
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Consumer<MessageProvider>(
                  builder: (context, messageProvider, child) {
                    if (messageProvider.messages.isEmpty) {
                      return const Center(
                        child: Text(
                          '還沒有訊息，開始探索吧！',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: messageProvider.messages.length,
                      itemBuilder: (context, index) {
                        final message = messageProvider.messages[index];
                        return _buildMessageBubble(message, index);
                      },
                    );
                  },
                ),
              ),
            ),
            
            // 輸入區域
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: QuickSendWidget(
              onSend: (content, latitude, duration, isAnonymous, customSenderName) {
                final messageProvider = context.read<MessageProvider>();
                final locationProvider = context.read<LocationProvider>();
                
                if (locationProvider.currentPosition != null) {
                  messageProvider.sendMessage(
                    content: content,
                    latitude: locationProvider.currentPosition!.latitude,
                    longitude: locationProvider.currentPosition!.longitude,
                    radius: 1000.0,
                    duration: duration,
                    isAnonymous: isAnonymous,
                    customSenderName: customSenderName,
                  );
                }
              },
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message, int index) {
    final isFromAI = message.isFromAI ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isFromAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isFromAI) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE8B4D1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromAI ? const Color(0xFFE8B4D1) : const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (!isFromAI) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFunctionButtons() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        children: [
          // 任務按鈕
          FloatingActionButton(
            onPressed: () => _showTaskCenter(context),
            backgroundColor: const Color(0xFFE8B4D1),
            child: const Icon(Icons.task_alt, color: Colors.white),
          ),
          const SizedBox(height: 12),
          
          // AI 機器人按鈕
          FloatingActionButton(
            onPressed: () => _showAIBotControl(context),
            backgroundColor: const Color(0xFF4A90E2),
            child: const Icon(Icons.smart_toy, color: Colors.white),
          ),
          const SizedBox(height: 12),
          
          // 位置按鈕
          FloatingActionButton(
            onPressed: () => _goToCurrentLocation(context.read<LocationProvider>().currentPosition!),
            backgroundColor: const Color(0xFF50C878),
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPermissionPrompt(LocationProvider locationProvider) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              '正在請求位置權限',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '請允許應用訪問您的位置，以便提供更好的服務',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (locationProvider.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  locationProvider.errorMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _updateBubblePositions() {
    // 更新泡泡位置邏輯
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _showTaskCenter(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
          vertical: MediaQuery.of(context).size.height * 0.1,
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
  }

  void _showAIBotControl(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AIBotControlScreen(),
      ),
    );
  }
}
