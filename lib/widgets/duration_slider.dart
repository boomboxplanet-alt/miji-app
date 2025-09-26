import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class DurationSlider extends StatefulWidget {
  final Duration initialDuration;
  final ValueChanged<Duration> onChanged;

  const DurationSlider({
    super.key,
    required this.initialDuration,
    required this.onChanged,
  });

  @override
  State<DurationSlider> createState() => _DurationSliderState();
}

class _DurationSliderState extends State<DurationSlider> {
  late double _sliderValue;

  // 預設時效選項（分鐘）
  final List<int> _durationOptions = [
    1, // 1分鐘
    5, // 5分鐘
    10, // 10分鐘
    30, // 30分鐘
    60, // 1小時
    120, // 2小時
    180, // 3小時
    360, // 6小時
    720, // 12小時
    1440, // 24小時
  ];

  @override
  void initState() {
    super.initState();
    _initializeSliderValue();
  }

  void _initializeSliderValue() {
    final initialMinutes = widget.initialDuration.inMinutes;

    // 找到最接近的選項索引
    int closestIndex = 0;
    int minDifference = (initialMinutes - _durationOptions[0]).abs();

    for (int i = 1; i < _durationOptions.length; i++) {
      int difference = (initialMinutes - _durationOptions[i]).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestIndex = i;
      }
    }

    _sliderValue = closestIndex.toDouble();
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes 分鐘';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours 小時';
      } else {
        return '$hours 小時 $remainingMinutes 分鐘';
      }
    } else {
      final days = minutes ~/ 1440;
      final remainingHours = (minutes % 1440) ~/ 60;
      if (remainingHours == 0) {
        return '$days 天';
      } else {
        return '$days 天 $remainingHours 小時';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMinutes = _durationOptions[_sliderValue.round()];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 標題
          const Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: AppColors.primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '訊息時效',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 當前選擇的時效顯示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.1),
                  AppColors.secondaryColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(currentMinutes),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 滑動條
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryColor,
              inactiveTrackColor: AppColors.primaryColor.withValues(alpha: 0.3),
              thumbColor: AppColors.primaryColor,
              overlayColor: AppColors.primaryColor.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 20,
              ),
              trackHeight: 4,
            ),
            child: Slider(
              value: _sliderValue,
              min: 0,
              max: (_durationOptions.length - 1).toDouble(),
              divisions: _durationOptions.length - 1,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });

                final selectedMinutes = _durationOptions[value.round()];
                widget.onChanged(Duration(minutes: selectedMinutes));
              },
            ),
          ),

          const SizedBox(height: 8),

          // 時效選項標籤
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _durationOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final minutes = entry.value;
              final isSelected = index == _sliderValue.round();

              return Expanded(
                child: Text(
                  _getShortLabel(minutes),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // 說明文字
          const Text(
            '拖動滑桿選擇訊息的存在時間',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getShortLabel(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else if (minutes < 1440) {
      return '${minutes ~/ 60}h';
    } else {
      return '${minutes ~/ 1440}d';
    }
  }
}
