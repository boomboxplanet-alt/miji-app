import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';
import 'duration_slider.dart';
import 'bubble_color_picker.dart';

class MessageSettingsPanel extends StatefulWidget {
  final Duration initialDuration;
  final double initialRadius;
  final Color initialBubbleColor;
  final ValueChanged<Duration> onDurationChanged;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<Color> onBubbleColorChanged;

  const MessageSettingsPanel({
    super.key,
    required this.initialDuration,
    required this.initialRadius,
    required this.initialBubbleColor,
    required this.onDurationChanged,
    required this.onRadiusChanged,
    required this.onBubbleColorChanged,
  });

  @override
  State<MessageSettingsPanel> createState() => _MessageSettingsPanelState();
}

class _MessageSettingsPanelState extends State<MessageSettingsPanel> {
  late Duration _duration;
  late double _radius;
  late Color _bubbleColor;

  // 距離選項（米）- 重新排序，將最合適的範圍放在前面
  final List<double> _radiusOptions = [
    500, // 500米 - 最合適的預設範圍
    300, // 300米
    200, // 200米
    800, // 800米
    1000, // 1000米
    100, // 100米
    50, // 50米
  ];

  @override
  void initState() {
    super.initState();
    _duration = widget.initialDuration;
    _radius = widget.initialRadius;
    _bubbleColor = widget.initialBubbleColor;
  }

  String _formatRadius(double radius) {
    if (radius >= 1000) {
      return '${(radius / 1000).toStringAsFixed(1)}km';
    } else {
      return '${radius.toInt()}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.08),
          ],
          stops: const [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題
          const Row(
            children: [
              Icon(
                Icons.settings,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '訊息設定',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 時效設定
          const Text(
            '消失時間',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          DurationSlider(
            initialDuration: _duration,
            onChanged: (duration) {
              setState(() {
                _duration = duration;
              });
              widget.onDurationChanged(duration);
            },
          ),

          const SizedBox(height: 16),

          // 距離設定
          const Text(
            '傳播距離',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 當前距離顯示
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondaryColor.withValues(alpha: 0.1),
                        AppColors.accentColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.radio_button_checked,
                        color: AppColors.secondaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatRadius(_radius),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 距離滑動條
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.secondaryColor,
                    inactiveTrackColor:
                        AppColors.secondaryColor.withValues(alpha: 0.3),
                    thumbColor: AppColors.secondaryColor,
                    overlayColor: AppColors.secondaryColor.withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _radiusOptions.indexOf(_radius).toDouble(),
                    min: 0,
                    max: (_radiusOptions.length - 1).toDouble(),
                    divisions: _radiusOptions.length - 1,
                    onChanged: (value) {
                      final newRadius = _radiusOptions[value.round()];
                      setState(() {
                        _radius = newRadius;
                      });
                      widget.onRadiusChanged(newRadius);
                    },
                  ),
                ),

                // 距離選項標籤
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _radiusOptions.map((radius) {
                    final isSelected = radius == _radius;
                    return Text(
                      _formatRadius(radius),
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? AppColors.secondaryColor
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 任務獎勵顯示
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              if (taskProvider.bonusDurationMinutes > 0 ||
                  taskProvider.bonusRangeMeters > 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '任務獎勵',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withValues(alpha: 0.1),
                            Colors.green.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.card_giftcard,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              taskProvider.getBonusDescription(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // 泡泡顏色設定
          const Text(
            '泡泡顏色',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          BubbleColorPicker(
            initialColor: _bubbleColor,
            onColorChanged: (color) {
              setState(() {
                _bubbleColor = color;
              });
              widget.onBubbleColorChanged(color);
            },
          ),
        ],
      ),
    );
  }
}
