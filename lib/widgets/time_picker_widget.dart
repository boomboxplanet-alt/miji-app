import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TimePickerWidget extends StatefulWidget {
  final int initialHours;
  final int initialMinutes;
  final ValueChanged<Duration> onTimeChanged;

  const TimePickerWidget({
    super.key,
    required this.initialHours,
    required this.initialMinutes,
    required this.onTimeChanged,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late int _selectedHours;
  late int _selectedMinutes;
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.initialHours;
    _selectedMinutes = widget.initialMinutes;
    // 確保最小值為1分鐘
    if (_selectedHours == 0 && _selectedMinutes == 0) {
      _selectedMinutes = 1;
    }
    _hoursController = FixedExtentScrollController(initialItem: _selectedHours);
    _minutesController =
        FixedExtentScrollController(initialItem: _selectedMinutes ~/ 5);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final duration = Duration(hours: _selectedHours, minutes: _selectedMinutes);
    widget.onTimeChanged(duration);
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(
        maxWidth: 320,
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 標題
          const Text(
            '銷毀時間',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // 蘋果風格時間選擇器
          SizedBox(
            height: 180,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  pickerTextStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 小時選擇器
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _hoursController,
                      itemExtent: 32,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedHours = index;
                          // 如果小時和分鐘都是0，設為最小值1分鐘
                          if (_selectedHours == 0 && _selectedMinutes == 0) {
                            _selectedMinutes = 1;
                          }
                        });
                        _updateTime();
                      },
                      children: List.generate(7, (index) {
                        return Center(
                          child: Text(
                            '$index',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // 小時標籤
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '小時',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ),

                  // 分鐘選擇器
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _minutesController,
                      itemExtent: 32,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMinutes = index * 5; // 5分鐘間隔
                          // 如果小時和分鐘都是0，設為最小值1分鐘
                          if (_selectedHours == 0 && _selectedMinutes == 0) {
                            _selectedMinutes = 1;
                          }
                        });
                        _updateTime();
                      },
                      children: List.generate(12, (index) {
                        final minutes = index * 5;
                        return Center(
                          child: Text(
                            '$minutes',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // 分鐘標籤
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '分鐘',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
