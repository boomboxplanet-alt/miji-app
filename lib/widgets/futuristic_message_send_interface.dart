import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class FuturisticMessageSendInterface extends StatefulWidget {
  final Function(double radius, Duration duration, bool isAnonymous) onSend;
  final VoidCallback? onCancel;

  const FuturisticMessageSendInterface({
    super.key,
    required this.onSend,
    this.onCancel,
  });

  @override
  State<FuturisticMessageSendInterface> createState() =>
      _FuturisticMessageSendInterfaceState();
}

class _FuturisticMessageSendInterfaceState
    extends State<FuturisticMessageSendInterface>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // 狀態變數 - 根據用戶上限設定範圍
  double _selectedTime = 1.0; // 小時
  double _selectedDistance = 1.0; // 公里
  bool _isAnonymous = true;
  String _messageText = '';

  // 用戶上限
  double _maxTimeHours = 24.0;
  double _maxDistanceKm = 10.0;

  @override
  void initState() {
    super.initState();

    // 發光動畫控制器
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 初始化用戶上限
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUserLimits();
    });
  }

  void _updateUserLimits() {
    final taskProvider = context.read<TaskProvider>();
    setState(() {
      // 使用基礎限制加上獎勵
      _maxTimeHours =
          (60 + taskProvider.bonusDurationMinutes) / 60.0; // 基礎1小時 + 獎勵
      _maxDistanceKm =
          (1000 + taskProvider.bonusRangeMeters) / 1000.0; // 基礎1km + 獎勵
      // 確保初始值在範圍內
      _selectedTime = math.min(_selectedTime, _maxTimeHours);
      _selectedDistance = math.min(_selectedDistance, _maxDistanceKm);
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            // 深藍漸層背景
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0A0A1A).withValues(alpha: 0.95),
                const Color(0xFF1A1A2E).withValues(alpha: 0.95),
                const Color(0xFF16213E).withValues(alpha: 0.95),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 標題
                Text(
                  '發送訊息',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 32),

                // 主要控制區域 - 時間、匿名開關、距離
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 左側：時間選擇模組
                    _buildTimeSelectionModule(),

                    // 中央：匿名開關
                    _buildAnonymousToggle(),

                    // 右側：距離選擇模組
                    _buildDistanceSelectionModule(),
                  ],
                ),

                const SizedBox(height: 32),

                // 訊息輸入欄位
                _buildMessageInput(),

                const SizedBox(height: 24),

                // 操作按鈕
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelectionModule() {
    return Column(
      children: [
        // 半圓形滑動刻度盤
        GestureDetector(
          onPanUpdate: (details) {
            _handleTimePan(details);
          },
          onTapDown: (details) {
            _handleTimeTap(details);
          },
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: SemiCircleDialPainter(
                  value: _selectedTime,
                  maxValue: _maxTimeHours,
                  dialColor: const Color(0xFF8B5CF6), // 紫色調
                  glowAnimationValue: _glowAnimation.value,
                ),
                child: Container(
                  width: 120,
                  height: 70,
                  alignment: Alignment.center,
                  child: Text(
                    '${_selectedTime.toStringAsFixed(1)} h',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // 時間卡片
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Text(
            '${_selectedTime.toStringAsFixed(1)} h',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceSelectionModule() {
    return Column(
      children: [
        // 半圓形滑動刻度盤
        GestureDetector(
          onPanUpdate: (details) {
            _handleDistancePan(details);
          },
          onTapDown: (details) {
            _handleDistanceTap(details);
          },
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: SemiCircleDialPainter(
                  value: _selectedDistance,
                  maxValue: _maxDistanceKm,
                  dialColor: const Color(0xFF06B6D4), // 青色調
                  glowAnimationValue: _glowAnimation.value,
                ),
                child: Container(
                  width: 120,
                  height: 70,
                  alignment: Alignment.center,
                  child: Text(
                    '${_selectedDistance.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // 距離卡片
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF06B6D4).withValues(alpha: 0.3),
                const Color(0xFF06B6D4).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Text(
            '${_selectedDistance.toStringAsFixed(1)} km',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymousToggle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ANONYMOUS 標籤
        Text(
          'ANONYMOUS',
          style: TextStyle(
            color: const Color(0xFF00BFFF).withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        // 開關按鈕
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
                  children: [
                    // 滑塊
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: _isAnonymous ? 76 : 4,
                      top: 4,
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
        onChanged: (value) {
          setState(() {
            _messageText = value;
          });
        },
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // 取消按鈕
        Expanded(
          child: _buildActionButton(
            text: '取消',
            color: Colors.grey,
            onPressed: widget.onCancel,
          ),
        ),
        const SizedBox(width: 16),
        // 發送按鈕
        Expanded(
          child: _buildActionButton(
            text: '發送',
            color: const Color(0xFF00BFFF),
            onPressed: _messageText.isNotEmpty ? _handleSend : null,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
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
                colors: onPressed != null
                    ? [
                        color.withValues(alpha: 0.8),
                        color.withValues(alpha: 0.6),
                      ]
                    : [
                        Colors.grey.withValues(alpha: 0.3),
                        Colors.grey.withValues(alpha: 0.2),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.6),
                width: 1.0,
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

  void _handleSend() {
    final duration = Duration(
      hours: _selectedTime.toInt(),
      minutes: ((_selectedTime % 1) * 60).toInt(),
    );
    widget.onSend(_selectedDistance * 1000, duration, _isAnonymous);
  }

  // 時間滑動處理
  void _handleTimePan(DragUpdateDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    final localPosition = box.globalToLocal(details.globalPosition);
    final center = Offset(120 / 2, 70 - 8); // 與繪製邏輯一致
    final angle = _calculateAngle(localPosition, center);
    
    if (angle >= math.pi && angle <= 2 * math.pi) {
      final normalizedAngle = (angle - math.pi) / math.pi; // 0 to 1
      final newValue = normalizedAngle * _maxTimeHours;
      setState(() {
        _selectedTime = math.max(0.1, math.min(_maxTimeHours, newValue));
      });
    }
  }

  void _handleTimeTap(TapDownDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    final localPosition = box.globalToLocal(details.globalPosition);
    final center = Offset(120 / 2, 70 - 8); // 與繪製邏輯一致
    final angle = _calculateAngle(localPosition, center);
    
    if (angle >= math.pi && angle <= 2 * math.pi) {
      final normalizedAngle = (angle - math.pi) / math.pi;
      final newValue = normalizedAngle * _maxTimeHours;
      setState(() {
        _selectedTime = math.max(0.1, math.min(_maxTimeHours, newValue));
      });
    }
  }

  // 距離滑動處理
  void _handleDistancePan(DragUpdateDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    final localPosition = box.globalToLocal(details.globalPosition);
    final center = Offset(120 / 2, 70 - 8); // 與繪製邏輯一致
    final angle = _calculateAngle(localPosition, center);
    
    if (angle >= math.pi && angle <= 2 * math.pi) {
      final normalizedAngle = (angle - math.pi) / math.pi;
      final newValue = normalizedAngle * _maxDistanceKm;
      setState(() {
        _selectedDistance = math.max(0.1, math.min(_maxDistanceKm, newValue));
      });
    }
  }

  void _handleDistanceTap(TapDownDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    final localPosition = box.globalToLocal(details.globalPosition);
    final center = Offset(120 / 2, 70 - 8); // 與繪製邏輯一致
    final angle = _calculateAngle(localPosition, center);
    
    if (angle >= math.pi && angle <= 2 * math.pi) {
      final normalizedAngle = (angle - math.pi) / math.pi;
      final newValue = normalizedAngle * _maxDistanceKm;
      setState(() {
        _selectedDistance = math.max(0.1, math.min(_maxDistanceKm, newValue));
      });
    }
  }

  // 計算角度
  double _calculateAngle(Offset point, Offset center) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final angle = math.atan2(dy, dx);
    
    // 調整角度到 0-2π 範圍，並確保在半圓範圍內
    if (angle < 0) return angle + 2 * math.pi;
    return angle;
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

    // 繪製當前值進度（紫色）
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
