import 'package:flutter/material.dart';
import 'dart:async';
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
  final bool isBotMessage; // 添加機器人訊息標識

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
    this.isBotMessage = false, // 默認為非機器人訊息
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
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
    
    // 機器人訊息沒有彈性縮放動畫，直接設置為1.0
    if (widget.isBotMessage) {
      _scaleController.value = 1.0;
    } else {
      _scaleController.forward();
    }
    
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
                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: 160,
                        minWidth: 100,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.bubbleColor.withOpacity(isTopLayer ? 1.0 : 0.8),
                            widget.bubbleColor.withOpacity(isTopLayer ? 0.8 : 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isTopLayer 
                                ? widget.bubbleColor.withOpacity(0.4)
                                : Colors.black.withOpacity(0.2),
                            blurRadius: isTopLayer ? 12 : 6,
                            offset: Offset(0, isTopLayer ? 4 : 2),
                          ),
                        ],
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
                          const SizedBox(height: 2),
                          // 性別和時間資訊（始終顯示）
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getGenderIcon(),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.timer,
                                color: Colors.white70,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _formatRemainingTime(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
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