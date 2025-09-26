import 'package:flutter/material.dart';

class SimpleIcon extends StatelessWidget {
  final IconType iconType;
  final double size;
  final Color color;

  const SimpleIcon({
    super.key,
    required this.iconType,
    this.size = 18,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.1),
      ),
      child: Center(
        child: Text(
          _getIconText(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
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
        return '⏰';
      case IconType.location:
        return '📍';
      case IconType.send:
        return '➤';
      case IconType.bubble:
        return '💬';
      case IconType.menu:
        return '☰';
      case IconType.close:
        return '✕';
      case IconType.check:
        return '✓';
      case IconType.star:
        return '★';
      case IconType.heart:
        return '♥';
      case IconType.home:
        return '🏠';
      case IconType.search:
        return '🔍';
      case IconType.notification:
        return '🔔';
      case IconType.profile:
        return '👤';
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
