import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomIcon extends StatelessWidget {
  final IconType iconType;
  final double size;
  final Color color;
  final Color? backgroundColor;

  const CustomIcon({
    super.key,
    required this.iconType,
    this.size = 18,
    this.color = Colors.white,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(size * 0.1),
            )
          : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: _IconPainter(
          iconType: iconType,
          color: color,
        ),
      ),
    );
  }
}

enum IconType {
  login,
  account,
  task,
  ai,
  settings,
  time,
  location,
  send,
  bubble,
  menu,
  close,
  check,
  star,
  heart,
  home,
  search,
  notification,
  profile,
}

class _IconPainter extends CustomPainter {
  final IconType iconType;
  final Color color;

  _IconPainter({
    required this.iconType,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    switch (iconType) {
      case IconType.login:
        _drawLoginIcon(canvas, center, radius, paint);
        break;
      case IconType.account:
        _drawAccountIcon(canvas, center, radius, paint);
        break;
      case IconType.task:
        _drawTaskIcon(canvas, center, radius, paint);
        break;
      case IconType.ai:
        _drawAIIcon(canvas, center, radius, paint);
        break;
      case IconType.settings:
        _drawSettingsIcon(canvas, center, radius, paint);
        break;
      case IconType.time:
        _drawTimeIcon(canvas, center, radius, paint);
        break;
      case IconType.location:
        _drawLocationIcon(canvas, center, radius, paint);
        break;
      case IconType.send:
        _drawSendIcon(canvas, center, radius, paint);
        break;
      case IconType.bubble:
        _drawBubbleIcon(canvas, center, radius, paint);
        break;
      case IconType.menu:
        _drawMenuIcon(canvas, center, radius, paint);
        break;
      case IconType.close:
        _drawCloseIcon(canvas, center, radius, paint);
        break;
      case IconType.check:
        _drawCheckIcon(canvas, center, radius, paint);
        break;
      case IconType.star:
        _drawStarIcon(canvas, center, radius, paint);
        break;
      case IconType.heart:
        _drawHeartIcon(canvas, center, radius, paint);
        break;
      case IconType.home:
        _drawHomeIcon(canvas, center, radius, paint);
        break;
      case IconType.search:
        _drawSearchIcon(canvas, center, radius, paint);
        break;
      case IconType.notification:
        _drawNotificationIcon(canvas, center, radius, paint);
        break;
      case IconType.profile:
        _drawProfileIcon(canvas, center, radius, paint);
        break;
    }
  }

  void _drawLoginIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製簡單的人形圖示
    canvas.drawCircle(Offset(center.dx, center.dy - radius * 0.3), radius * 0.3, paint);
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.4), radius * 0.5, paint);
  }

  void _drawAccountIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製用戶圖示
    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset(center.dx, center.dy - radius * 0.2), radius: radius * 0.4));
    path.addOval(Rect.fromCircle(center: Offset(center.dx, center.dy + radius * 0.5), radius: radius * 0.7));
    canvas.drawPath(path, paint);
  }

  void _drawTaskIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製任務清單圖示
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: radius * 1.6, height: radius * 1.2),
      Radius.circular(radius * 0.2),
    );
    canvas.drawRRect(rect, paint);
    
    // 繪製勾選標記
    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final checkPath = Path();
    checkPath.moveTo(center.dx - radius * 0.3, center.dy);
    checkPath.lineTo(center.dx - radius * 0.1, center.dy + radius * 0.2);
    checkPath.lineTo(center.dx + radius * 0.3, center.dy - radius * 0.2);
    canvas.drawPath(checkPath, checkPaint);
  }

  void _drawAIIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製AI機器人圖示
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: radius * 1.4, height: radius * 1.0),
      Radius.circular(radius * 0.3),
    );
    canvas.drawRRect(rect, paint);
    
    // 繪製眼睛
    canvas.drawCircle(Offset(center.dx - radius * 0.3, center.dy - radius * 0.2), radius * 0.15, paint);
    canvas.drawCircle(Offset(center.dx + radius * 0.3, center.dy - radius * 0.2), radius * 0.15, paint);
  }

  void _drawSettingsIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製齒輪圖示
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * (3.14159 / 4);
      final x = center.dx + radius * 0.8 * cos(angle);
      final y = center.dy + radius * 0.8 * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    
    // 繪製中心圓
    canvas.drawCircle(center, radius * 0.3, paint);
  }

  void _drawTimeIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製時鐘圖示
    canvas.drawCircle(center, radius, paint);
    
    // 繪製指針
    final handPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // 時針
    canvas.drawLine(center, Offset(center.dx, center.dy - radius * 0.4), handPaint);
    // 分針
    canvas.drawLine(center, Offset(center.dx + radius * 0.3, center.dy), handPaint);
  }

  void _drawLocationIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製位置圖示
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx - radius * 0.6, center.dy + radius * 0.2);
    path.lineTo(center.dx + radius * 0.6, center.dy + radius * 0.2);
    path.close();
    canvas.drawPath(path, paint);
    
    // 繪製中心點
    canvas.drawCircle(center, radius * 0.3, paint);
  }

  void _drawSendIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製發送圖示
    final path = Path();
    path.moveTo(center.dx - radius * 0.5, center.dy - radius * 0.3);
    path.lineTo(center.dx + radius * 0.5, center.dy);
    path.lineTo(center.dx - radius * 0.5, center.dy + radius * 0.3);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawBubbleIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製泡泡圖示
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: radius * 1.4, height: radius * 1.0),
      Radius.circular(radius * 0.5),
    );
    canvas.drawRRect(rect, paint);
    
    // 繪製小尾巴
    final tailPath = Path();
    tailPath.moveTo(center.dx + radius * 0.3, center.dy + radius * 0.2);
    tailPath.lineTo(center.dx + radius * 0.6, center.dy + radius * 0.4);
    tailPath.lineTo(center.dx + radius * 0.1, center.dy + radius * 0.4);
    tailPath.close();
    canvas.drawPath(tailPath, paint);
  }

  void _drawMenuIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製菜單圖示
    for (int i = 0; i < 3; i++) {
      final y = center.dy - radius * 0.4 + i * radius * 0.4;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(center.dx, y), width: radius * 1.2, height: radius * 0.15),
        paint,
      );
    }
  }

  void _drawCloseIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製關閉圖示
    final closePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.5),
      closePaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5),
      closePaint,
    );
  }

  void _drawCheckIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製勾選圖示
    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final checkPath = Path();
    checkPath.moveTo(center.dx - radius * 0.4, center.dy);
    checkPath.lineTo(center.dx - radius * 0.1, center.dy + radius * 0.3);
    checkPath.lineTo(center.dx + radius * 0.4, center.dy - radius * 0.3);
    canvas.drawPath(checkPath, checkPaint);
  }

  void _drawStarIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製星星圖示
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = i * (3.14159 * 2 / 5) - 3.14159 / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeartIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製愛心圖示
    final path = Path();
    path.moveTo(center.dx, center.dy + radius * 0.3);
    path.cubicTo(
      center.dx - radius * 0.5, center.dy - radius * 0.2,
      center.dx - radius * 0.8, center.dy - radius * 0.2,
      center.dx - radius * 0.8, center.dy + radius * 0.1,
    );
    path.cubicTo(
      center.dx - radius * 0.8, center.dy + radius * 0.4,
      center.dx, center.dy + radius * 0.7,
      center.dx, center.dy + radius * 0.7,
    );
    path.cubicTo(
      center.dx, center.dy + radius * 0.7,
      center.dx + radius * 0.8, center.dy + radius * 0.4,
      center.dx + radius * 0.8, center.dy + radius * 0.1,
    );
    path.cubicTo(
      center.dx + radius * 0.8, center.dy - radius * 0.2,
      center.dx + radius * 0.5, center.dy - radius * 0.2,
      center.dx, center.dy + radius * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  void _drawHomeIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製房子圖示
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx - radius * 0.8, center.dy - radius * 0.2);
    path.lineTo(center.dx - radius * 0.8, center.dy + radius * 0.6);
    path.lineTo(center.dx + radius * 0.8, center.dy + radius * 0.6);
    path.lineTo(center.dx + radius * 0.8, center.dy - radius * 0.2);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSearchIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製搜索圖示
    canvas.drawCircle(center, radius * 0.6, paint);
    
    final searchPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final searchPath = Path();
    searchPath.moveTo(center.dx + radius * 0.4, center.dy + radius * 0.4);
    searchPath.lineTo(center.dx + radius * 0.8, center.dy + radius * 0.8);
    canvas.drawPath(searchPath, searchPaint);
  }

  void _drawNotificationIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製通知圖示
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx - radius * 0.6, center.dy - radius * 0.3);
    path.lineTo(center.dx - radius * 0.6, center.dy + radius * 0.4);
    path.lineTo(center.dx + radius * 0.6, center.dy + radius * 0.4);
    path.lineTo(center.dx + radius * 0.6, center.dy - radius * 0.3);
    path.close();
    canvas.drawPath(path, paint);
    
    // 繪製鈴鐺
    canvas.drawCircle(center, radius * 0.2, paint);
  }

  void _drawProfileIcon(Canvas canvas, Offset center, double radius, Paint paint) {
    // 繪製個人資料圖示
    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset(center.dx, center.dy - radius * 0.3), radius: radius * 0.4));
    path.addOval(Rect.fromCircle(center: Offset(center.dx, center.dy + radius * 0.4), radius: radius * 0.6));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 數學函數
double cos(double angle) => math.cos(angle);
double sin(double angle) => math.sin(angle);
