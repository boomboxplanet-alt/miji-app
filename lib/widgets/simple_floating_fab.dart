import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SimpleFloatingFAB extends StatefulWidget {
  final Function(String message, double radius, Duration duration, bool isAnonymous, [String? customSenderName]) onSend;
  final Function(bool isExpanded)? onExpansionChanged;
  
  const SimpleFloatingFAB({
    super.key,
    required this.onSend,
    this.onExpansionChanged,
  });

  @override
  State<SimpleFloatingFAB> createState() => _SimpleFloatingFABState();
}

class _SimpleFloatingFABState extends State<SimpleFloatingFAB> {
  bool _isExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isAnonymous = true;
  double _radius = 100.0;
  Duration _destroyDuration = const Duration(hours: 1);

  @override
  void dispose() {
    _messageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    // 通知父組件選單狀態變化
    widget.onExpansionChanged?.call(_isExpanded);
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    
    widget.onSend(
      message,
      _radius,
      _destroyDuration,
      _isAnonymous,
      null, // 不再需要自定義名稱
    );
    
    _messageController.clear();
    _toggleExpanded();
  }

  Widget _buildSettingButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onPanStart: (_) {}, // 攔截滑動手勢，防止穿透到地圖
      onPanUpdate: (_) {},
      onPanEnd: (_) {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primaryColor.withOpacity(0.8),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDistanceSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '發送距離',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${_radius.toInt()}米',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Slider(
              value: _radius,
              min: 50,
              max: 1000,
              divisions: 19,
              activeColor: AppColors.primaryColor,
              inactiveColor: Colors.white.withOpacity(0.3),
              onChanged: (value) {
                setState(() {
                  _radius = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildQuickDistanceButton(50, '50米'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickDistanceButton(100, '100米'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickDistanceButton(500, '500米'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickDistanceButton(1000, '1公里'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDistanceButton(double distance, String label) {
    final isSelected = _radius == distance;
    return GestureDetector(
      onTap: () {
        setState(() {
          _radius = distance;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 展開的面板
        if (_isExpanded)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: _buildExpandedPanel(),
            ),
          ),
        
        // 主浮動按鈕
        Positioned(
          bottom: 30,
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
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _toggleExpanded,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(
                _isExpanded ? Icons.close : Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedPanel() {
    return AbsorbPointer(
      absorbing: false, // 允許內部交互，但阻止事件穿透
      child: GestureDetector(
        onTap: () {}, // 攔截點擊事件，防止穿透到地圖
        onPanStart: (_) {}, // 攔截滑動手勢開始事件
        onPanUpdate: (_) {}, // 攔截滑動手勢更新事件
        onPanEnd: (_) {}, // 攔截滑動手勢結束事件
        child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.98),
              const Color(0xFF16213E).withOpacity(0.95),
              const Color(0xFF0F3460).withOpacity(0.92),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 8,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 距離和時間選項
            Row(
              children: [
                Expanded(
                  child: _buildSettingButton(
                    icon: Icons.location_on_outlined,
                    label: '${_radius.toInt()}米',
                    onTap: _showDistanceSettings,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSettingButton(
                    icon: Icons.timer_outlined,
                    label: '${_destroyDuration.inHours}小時',
                    onTap: _showDurationSettings,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _toggleExpanded,
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 匿名選項
            GestureDetector(
              onTap: () => setState(() => _isAnonymous = !_isAnonymous),
              onPanStart: (_) {}, // 攔截滑動手勢，防止穿透到地圖
              onPanUpdate: (_) {},
              onPanEnd: (_) {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _isAnonymous ? AppColors.primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isAnonymous ? AppColors.primaryColor.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _isAnonymous ? AppColors.primaryColor.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isAnonymous ? Icons.visibility_off : Icons.visibility,
                        color: _isAnonymous ? AppColors.primaryColor : Colors.white70,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isAnonymous ? '匿名發送' : '顯示姓名',
                      style: TextStyle(
                        color: _isAnonymous ? AppColors.primaryColor : Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            
            // 訊息輸入
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 3,
                maxLength: 200,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '說點什麼... (最多200字節)',
                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryColor.withOpacity(0.7),
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 發送按鈕
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onPanStart: (_) {}, // 攔截滑動手勢，防止穿透到地圖
                  onPanUpdate: (_) {},
                  onPanEnd: (_) {},
                  child: InkWell(
                    onTap: _messageController.text.trim().isNotEmpty ? _sendMessage : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '發送訊息',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }

  void _showDurationSettings() {
    final durations = [
      const Duration(minutes: 30),
      const Duration(hours: 1),
      const Duration(hours: 2),
      const Duration(hours: 6),
      const Duration(hours: 12),
      const Duration(days: 1),
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '持續時間',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...durations.map((duration) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: _destroyDuration == duration 
                    ? AppColors.primaryColor.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _destroyDuration == duration 
                      ? AppColors.primaryColor.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ListTile(
                title: Text(
                  duration.inHours >= 1 
                      ? '${duration.inHours}小時'
                      : '${duration.inMinutes}分鐘',
                  style: TextStyle(
                    color: _destroyDuration == duration ? AppColors.primaryColor : Colors.white,
                    fontWeight: _destroyDuration == duration ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                leading: Radio<Duration>(
                  value: duration,
                  groupValue: _destroyDuration,
                  activeColor: AppColors.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _destroyDuration = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _destroyDuration = duration;
                  });
                  Navigator.pop(context);
                },
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
