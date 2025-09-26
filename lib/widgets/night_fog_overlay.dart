import 'dart:math';
import 'package:flutter/widgets.dart';

/// 夜間「星光夜霧探索風格」覆蓋層。
/// - 漸層：深紫(#2D1A4F) → 柔霧灰(#3F3F5F) → 暖米白(#F7F2E9)
/// - 微量星點與柔光暈
class NightFogOverlay extends StatelessWidget {
  const NightFogOverlay(
      {super.key, this.opacity = 0.18, this.starDensity = 0.8});

  final double opacity; // 整體透明度
  final double starDensity; // 星點密度 0~1

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _NightFogPainter(opacity: opacity, starDensity: starDensity),
        size: Size.infinite,
      ),
    );
  }
}

class _NightFogPainter extends CustomPainter {
  _NightFogPainter({required this.opacity, required this.starDensity});

  final double opacity;
  final double starDensity;

  @override
  void paint(Canvas canvas, Size size) {
    // 背景漸層
    final rect = Offset.zero & size;
    final gradient = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF2D1A4F), // 深紫
          Color(0xFF3F3F5F), // 柔霧灰
          Color(0xFFF7F2E9), // 暖米白
        ],
        stops: [0.0, 0.58, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..blendMode = BlendMode.srcOver
      ..color = const Color(0xFFFFFFFF).withValues(alpha: opacity);
    canvas.drawRect(rect, gradient);

    // 柔光暈（大面積、低透明）
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40)
      ..color = const Color(0xFFA58BD9).withValues(alpha: 0.10);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.3),
        size.shortestSide * 0.28, glowPaint);
    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.7),
        size.shortestSide * 0.22,
        glowPaint..color = const Color(0xFFF0D9C8).withValues(alpha: 0.10));

    // 星點
    final rng = Random(42); // 固定種子，避免每幀抖動
    final int starCount = (120 * starDensity).toInt();
    for (int i = 0; i < starCount; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final r = 0.5 + rng.nextDouble() * 1.2; // 半徑 0.5~1.7
      final alpha = 0.35 + rng.nextDouble() * 0.45; // 透明度
      final color = const Color(0xFFF7F2E9).withValues(alpha: alpha * opacity);
      final starPaint = Paint()..color = color;
      canvas.drawCircle(Offset(dx, dy), r, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NightFogPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.starDensity != starDensity;
  }
}
