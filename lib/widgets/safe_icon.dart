import 'package:flutter/material.dart';

class SafeIcon extends StatelessWidget {
  final IconType iconType;
  final double size;
  final Color color;
  final Color? backgroundColor;

  const SafeIcon({
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
              borderRadius: BorderRadius.circular(size * 0.2),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            )
          : null,
      child: Center(
        child: Text(
          _getIconText(),
          style: TextStyle(
            color: color,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            height: 1.0,
            fontFamily: 'monospace', // 使用等寬字體確保一致性
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getIconText() {
    switch (iconType) {
      case IconType.login:
        return 'L';
      case IconType.account:
        return 'A';
      case IconType.task:
        return 'T';
      case IconType.ai:
        return 'AI';
      case IconType.settings:
        return 'S';
      case IconType.time:
        return 'T';
      case IconType.location:
        return 'L';
      case IconType.send:
        return '→';
      case IconType.bubble:
        return 'B';
      case IconType.menu:
        return '≡';
      case IconType.close:
        return '×';
      case IconType.check:
        return '✓';
      case IconType.star:
        return '★';
      case IconType.heart:
        return '♥';
      case IconType.home:
        return 'H';
      case IconType.search:
        return '?';
      case IconType.notification:
        return 'N';
      case IconType.profile:
        return 'P';
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
