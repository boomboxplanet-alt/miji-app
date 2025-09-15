import 'package:flutter/material.dart';

class ReliableIcon extends StatelessWidget {
  final IconType iconType;
  final double size;
  final Color color;
  final Color? backgroundColor;

  const ReliableIcon({
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
              borderRadius: BorderRadius.circular(size * 0.15),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            )
          : null,
      child: Center(
        child: Text(
          _getIconSymbol(),
          style: TextStyle(
            color: color,
            fontSize: size * 0.7,
            fontWeight: FontWeight.w600,
            fontFamily: 'Arial, sans-serif', // 確保字體支持
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getIconSymbol() {
    switch (iconType) {
      case IconType.login:
        return '👤'; // 用戶圖示
      case IconType.account:
        return '👥'; // 帳戶圖示
      case IconType.task:
        return '✓'; // 任務完成圖示
      case IconType.ai:
        return '🤖'; // AI機器人圖示
      case IconType.settings:
        return '⚙️'; // 設定圖示
      case IconType.time:
        return '⏰'; // 時間圖示
      case IconType.location:
        return '📍'; // 位置圖示
      case IconType.send:
        return '➤'; // 發送箭頭
      case IconType.bubble:
        return '💬'; // 對話框圖示
      case IconType.menu:
        return '☰'; // 菜單圖示
      case IconType.close:
        return '✕'; // 關閉圖示
      case IconType.check:
        return '✓'; // 勾選圖示
      case IconType.star:
        return '★'; // 星星圖示
      case IconType.heart:
        return '♥'; // 愛心圖示
      case IconType.home:
        return '🏠'; // 房子圖示
      case IconType.search:
        return '🔍'; // 搜索圖示
      case IconType.notification:
        return '🔔'; // 通知圖示
      case IconType.profile:
        return '👤'; // 個人資料圖示
    }
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
