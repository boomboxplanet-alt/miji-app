import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final double? currentZoom;
  final double? minZoom;
  final double? maxZoom;

  const ZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    this.currentZoom,
    this.minZoom,
    this.maxZoom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 放大按鈕
          _buildZoomButton(
            icon: Icons.add,
            onPressed: _canZoomIn() ? onZoomIn : null,
            isEnabled: _canZoomIn(),
          ),
          // 分隔線
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primaryColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // 縮小按鈕
          _buildZoomButton(
            icon: Icons.remove,
            onPressed: _canZoomOut() ? onZoomOut : null,
            isEnabled: _canZoomOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isEnabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor.withValues(alpha: 0.1),
                      AppColors.secondaryColor.withValues(alpha: 0.1),
                    ],
                  )
                : null,
          ),
          child: Icon(
            icon,
            color:
                isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.3),
            size: 20,
          ),
        ),
      ),
    );
  }

  bool _canZoomIn() {
    if (currentZoom == null || maxZoom == null) return true;
    return currentZoom! < maxZoom!;
  }

  bool _canZoomOut() {
    if (currentZoom == null || minZoom == null) return true;
    return currentZoom! > minZoom!;
  }
}
