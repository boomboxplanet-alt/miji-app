import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import '../models/message.dart';

class MessageBubbleOverlay extends StatefulWidget {
  final String content;
  final double left;
  final double top;
  final VoidCallback? onTap;
  final int zIndex;
  final DateTime expiresAt;
  final Color bubbleColor;
  final Gender gender;
  final int likeCount;
  final String distanceText;

  const MessageBubbleOverlay({
    super.key,
    required this.content,
    required this.left,
    required this.top,
    this.onTap,
    this.zIndex = 0,
    required this.expiresAt,
    required this.bubbleColor,
    required this.gender,
    required this.likeCount,
    required this.distanceText,
  });

  @override
  State<MessageBubbleOverlay> createState() => _MessageBubbleOverlayState();
}

class _MessageBubbleOverlayState extends State<MessageBubbleOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isVisible = true;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
    _scaleController.forward();
    
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
      
      // 時間到了，直接開始淡出動畫（移除倒數功能）
      if (_remainingTime.inSeconds <= 0) {
        _startFadeOutAnimation();
        timer.cancel();
      }
    });
  }
  

  
  void _startFadeOutAnimation() {
    _fadeController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    final remaining = widget.expiresAt.difference(now);
    
    if (remaining.isNegative) {
      // 訊息已過期
      return;
    }
    
    setState(() {
      _remainingTime = remaining;
    });
  }



  String _formatRemainingTime() {
    if (_remainingTime.inHours > 0) {
      final hours = _remainingTime.inHours;
      final minutes = _remainingTime.inMinutes % 60;
      if (minutes > 0) {
        return '$hours小時$minutes分';
      } else {
        return '$hours小時';
      }
    } else if (_remainingTime.inMinutes > 0) {
      return '${_remainingTime.inMinutes}分';
    } else {
      return '${_remainingTime.inSeconds}秒';
    }
  }

  Widget _getGenderIcon() {
    switch (widget.gender) {
      case Gender.male:
        return const Icon(
          Icons.male,
          color: Colors.white70,
          size: 12,
        );
      case Gender.female:
        return const Icon(
          Icons.female,
          color: Colors.white70,
          size: 12,
        );
      default:
        return const Icon(
          Icons.person,
          color: Colors.white70,
          size: 12,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    final isTopLayer = widget.zIndex > 0;
    
    return Positioned(
      left: widget.left - 75, // 調整位置使泡泡居中
      top: widget.top - 40,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _pulseAnimation, 
            _scaleAnimation, 
            _fadeAnimation,
          ]),
          builder: (context, child) {
            // 正常泡泡顯示（移除倒數和爆炸動畫）
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value * _pulseAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 240,
                    minWidth: 110,
                  ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF8A7CCF).withOpacity(0.42), // 紫藍更明顯
                            const Color(0xFFF29EDB).withOpacity(0.34), // 粉色更明顯
                          ],
                          stops: [0.1, 0.9],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(0.28), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      foregroundDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.35),
                            Colors.white.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 訊息內容（可能被截斷）
                          Text(
                            widget.content,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // 計量列：喜歡數、距離、時間（自適應防溢出）
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 2,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Icon(Icons.favorite, size: 12, color: Colors.white70),
                                const SizedBox(width: 1),
                                Text('${widget.likeCount}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                const SizedBox(width: 4),
                                const Icon(Icons.place, size: 12, color: Colors.white70),
                                const SizedBox(width: 1),
                                Text(widget.distanceText, style: const TextStyle(color: Colors.white70, fontSize: 10), overflow: TextOverflow.ellipsis),
                                const SizedBox(width: 4),
                                const Icon(Icons.timer, size: 12, color: Colors.white70),
                                const SizedBox(width: 1),
                                Text(_formatRemainingTime(), style: const TextStyle(color: Colors.white70, fontSize: 10), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          // 性別與型別圖示
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getGenderIcon(),
                              const SizedBox(width: 6),
                              const Icon(Icons.chat_bubble, color: Colors.white70, size: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BubbleArrowPainter extends CustomPainter {
  final Color color;

  BubbleArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2 - 8, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + 8, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}