import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BubbleColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const BubbleColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<BubbleColorPicker> createState() => _BubbleColorPickerState();
}

class _BubbleColorPickerState extends State<BubbleColorPicker> {
  late Color _selectedColor;
  
  // 預設顏色選項
  final List<Color> _colorOptions = [
    AppColors.primaryColor,      // 紫色
    AppColors.secondaryColor,    // 粉紅色
    AppColors.accentColor,       // 橙色
    Colors.blue,                 // 藍色
    Colors.green,                // 綠色
    Colors.red,                  // 紅色
    Colors.teal,                 // 青色
    Colors.indigo,               // 靛色
    Colors.amber,                // 琥珀色
    Colors.deepPurple,           // 深紫色
    Colors.cyan,                 // 青藍色
    Colors.lime,                 // 萊姆色
    Colors.pink,                 // 粉色
    Colors.brown,                // 棕色
    Colors.grey,                 // 灰色
    Colors.blueGrey,             // 藍灰色
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                Icons.palette,
                color: AppColors.primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '泡泡顏色',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 當前選擇的顏色預覽
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _selectedColor,
                  _selectedColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '預覽泡泡顏色',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 顏色選擇網格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _colorOptions.length,
            itemBuilder: (context, index) {
              final color = _colorOptions[index];
              final isSelected = color.value == _selectedColor.value;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  widget.onColorChanged(color);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // 說明文字
          const Text(
            '選擇您喜歡的泡泡顏色',
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
}