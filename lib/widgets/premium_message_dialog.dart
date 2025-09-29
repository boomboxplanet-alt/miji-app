import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class PremiumMessageDialog extends StatefulWidget {
  final Function(
    double radius,
    Duration duration,
    bool isAnonymous,
    String message,
  )
  onSend;
  final VoidCallback onCancel;

  const PremiumMessageDialog({
    super.key,
    required this.onSend,
    required this.onCancel,
  });

  @override
  State<PremiumMessageDialog> createState() => _PremiumMessageDialogState();
}

class _PremiumMessageDialogState extends State<PremiumMessageDialog>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  double _selectedTime = 1.0; // 小時
  double _selectedDistance = 1.0; // 公里
  bool _isAnonymous = true;
  final TextEditingController _messageController = TextEditingController();

  double _maxTimeHours = 1.0;
  double _maxDistanceKm = 1.0;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUserLimits();
    });
  }

  void _updateUserLimits() {
    final taskProvider = context.read<TaskProvider>();
    setState(() {
      _maxTimeHours =
          (60 + taskProvider.bonusDurationMinutes) / 60.0; // 基礎1小時 + 獎勵
      _maxDistanceKm =
          (1000 + taskProvider.bonusRangeMeters) / 1000.0; // 基礎1km + 獎勵

      // 確保初始值在範圍內
      _selectedTime = math.min(_selectedTime, _maxTimeHours);
      _selectedDistance = math.min(_selectedDistance, _maxDistanceKm);

      // 確保最小值不為0，避免除以零或顯示不佳
      if (_maxTimeHours < 0.1) _maxTimeHours = 0.1;
      if (_maxDistanceKm < 0.1) _maxDistanceKm = 0.1;
      if (_selectedTime < 0.1) _selectedTime = 0.1;
      if (_selectedDistance < 0.1) _selectedDistance = 0.1;
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              width: math.min(MediaQuery.of(context).size.width * 0.9, 500),
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
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF00BFFF).withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: const Color(0xFF00BFFF).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 標題
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Text(
                          'MIJI 秘跡',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            shadows: [
                              BoxShadow(
                                color: const Color(
                                  0xFF00BFFF,
                                ).withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '發送訊息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 時間、匿名開關、距離選擇模組
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 左側：時間選擇模組
                      Expanded(child: _buildTimeSelectionModule()),
                      const SizedBox(width: 16),
                      // 中央：匿名開關
                      Expanded(child: _buildAnonymousToggle()),
                      const SizedBox(width: 16),
                      // 右側：距離選擇模組
                      Expanded(child: _buildDistanceSelectionModule()),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 訊息輸入欄位
                  _buildMessageInput(),

                  const SizedBox(height: 24),

                  // 發送和取消按鈕
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelectionModule() {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                painter: SemiCircleDialPainter(
                  value: _selectedTime,
                  maxValue: _maxTimeHours,
                  dialColor: const Color(0xFF8B5CF6), // 紫色調
                  glowAnimationValue: _glowAnimation.value,
                ),
                child: Container(),
              ),
              Positioned(
                bottom: 20,
                child: Text(
                  '${_selectedTime.toStringAsFixed(1)} h',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '持續時間',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _selectedTime,
          min: 0.1,
          max: _maxTimeHours,
          divisions: (_maxTimeHours * 10).toInt(),
          onChanged: (newValue) {
            setState(() {
              _selectedTime = newValue;
            });
          },
          activeColor: const Color(0xFF8B5CF6),
          inactiveColor: Colors.white.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildDistanceSelectionModule() {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                painter: SemiCircleDialPainter(
                  value: _selectedDistance,
                  maxValue: _maxDistanceKm,
                  dialColor: const Color(0xFF06B6D4), // 青色調
                  glowAnimationValue: _glowAnimation.value,
                ),
                child: Container(),
              ),
              Positioned(
                bottom: 20,
                child: Text(
                  '${_selectedDistance.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '距離範圍',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _selectedDistance,
          min: 0.1,
          max: _maxDistanceKm,
          divisions: (_maxDistanceKm * 10).toInt(),
          onChanged: (newValue) {
            setState(() {
              _selectedDistance = newValue;
            });
          },
          activeColor: const Color(0xFF06B6D4),
          inactiveColor: Colors.white.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildAnonymousToggle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ANONYMOUS',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isAnonymous = !_isAnonymous;
            });
          },
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isAnonymous
                        ? [
                            const Color(0xFF00BFFF).withValues(alpha: 0.8),
                            const Color(0xFF00BFFF).withValues(alpha: 0.6),
                          ]
                        : [
                            Colors.grey.withValues(alpha: 0.6),
                            Colors.grey.withValues(alpha: 0.4),
                          ],
                  ),
                  border: Border.all(
                    color: const Color(
                      0xFF00BFFF,
                    ).withValues(alpha: 0.4 + (0.3 * _glowAnimation.value)),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isAnonymous
                          ? const Color(0xFF00BFFF).withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15 + (10 * _glowAnimation.value),
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: _isAnonymous
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: _isAnonymous ? null : 4,
                      right: _isAnonymous ? 4 : null,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      height: 100,
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
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: _messageController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '輸入您的訊息內容...',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            text: '取消',
            color: Colors.grey,
            onPressed: widget.onCancel,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            text: '發送',
            color: const Color(0xFF00BFFF),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                final duration = Duration(
                  hours: _selectedTime.toInt(),
                  minutes: ((_selectedTime % 1) * 60).toInt(),
                );
                widget.onSend(
                  _selectedDistance * 1000,
                  duration,
                  _isAnonymous,
                  _messageController.text,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            height: 56,
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
              border: Border.all(
                color: color.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(
                    alpha: 0.3 + (0.2 * _glowAnimation.value),
                  ),
                  blurRadius: 15 + (10 * _glowAnimation.value),
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SemiCircleDialPainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color dialColor;
  final double glowAnimationValue;

  SemiCircleDialPainter({
    required this.value,
    required this.maxValue,
    required this.dialColor,
    required this.glowAnimationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8); // 中心點位置
    final radius = (size.width / 2) - 20; // 軌道半徑

    // 繪製深藍色背景軌道（圓形）
    final trackPaint = Paint()
      ..color = const Color(0xFF1A1A2E).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // 從180度開始
      math.pi, // 到360度結束
      false,
      trackPaint,
    );

    // 繪製當前值進度（紫色/青色）
    final normalizedValue = (value / maxValue).clamp(0.0, 1.0);
    final progressAngle = math.pi + (normalizedValue * math.pi);

    final progressPaint = Paint()
      ..color = dialColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      normalizedValue * math.pi,
      false,
      progressPaint,
    );

    // 繪製軌道上的指示器圓點（白色）
    final indicatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final indicatorCenter = Offset(
      center.dx + radius * math.cos(progressAngle),
      center.dy + radius * math.sin(progressAngle),
    );

    canvas.drawCircle(indicatorCenter, 8, indicatorPaint);

    // 繪製中央圓形指示器（白色）
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is SemiCircleDialPainter &&
        (oldDelegate.value != value ||
            oldDelegate.glowAnimationValue != glowAnimationValue);
  }
}
