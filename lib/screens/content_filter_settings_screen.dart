import 'package:flutter/material.dart';

/// 內容過濾設定頁面
class ContentFilterSettingsScreen extends StatefulWidget {
  const ContentFilterSettingsScreen({super.key});

  @override
  State<ContentFilterSettingsScreen> createState() =>
      _ContentFilterSettingsScreenState();
}

class _ContentFilterSettingsScreenState
    extends State<ContentFilterSettingsScreen> {
  bool _enableContentFilter = true;
  bool _enableSensitiveWordFilter = true;
  bool _enableSpamFilter = true;
  bool _enableReportSystem = true;
  bool _autoHideSuspiciousContent = false;
  double _filterSensitivity = 2.0; // 1=寬鬆, 2=標準, 3=嚴格

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '內容過濾設定',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionCard(
              title: '基本設定',
              icon: Icons.security,
              children: [
                _buildSwitchTile(
                  title: '啟用內容過濾',
                  subtitle: '自動檢測和過濾不當內容',
                  value: _enableContentFilter,
                  onChanged: (value) {
                    setState(() {
                      _enableContentFilter = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: '敏感詞過濾',
                  subtitle: '過濾包含敏感詞彙的內容',
                  value: _enableSensitiveWordFilter,
                  onChanged: _enableContentFilter
                      ? (value) {
                          setState(() {
                            _enableSensitiveWordFilter = value;
                          });
                        }
                      : null,
                ),
                _buildSwitchTile(
                  title: '垃圾訊息過濾',
                  subtitle: '過濾重複、無意義的垃圾內容',
                  value: _enableSpamFilter,
                  onChanged: _enableContentFilter
                      ? (value) {
                          setState(() {
                            _enableSpamFilter = value;
                          });
                        }
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              title: '過濾級別',
              icon: Icons.tune,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '過濾敏感度：${_getFilterLevelText()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _filterSensitivity,
                          min: 1.0,
                          max: 3.0,
                          divisions: 2,
                          onChanged: _enableContentFilter
                              ? (value) {
                                  setState(() {
                                    _filterSensitivity = value;
                                  });
                                }
                              : null,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '寬鬆',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '標準',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '嚴格',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              title: '社區功能',
              icon: Icons.people,
              children: [
                _buildSwitchTile(
                  title: '啟用舉報系統',
                  subtitle: '允許用戶舉報不當內容',
                  value: _enableReportSystem,
                  onChanged: (value) {
                    setState(() {
                      _enableReportSystem = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: '自動隱藏可疑內容',
                  subtitle: '自動隱藏被多次舉報的內容',
                  value: _autoHideSuspiciousContent,
                  onChanged: _enableReportSystem
                      ? (value) {
                          setState(() {
                            _autoHideSuspiciousContent = value;
                          });
                        }
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              title: '說明',
              icon: Icons.info_outline,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoItem(
                        '寬鬆模式',
                        '只過濾明顯的違法內容，允許更多表達自由',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        '標準模式',
                        '平衡內容自由和社區安全，推薦設定',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        '嚴格模式',
                        '嚴格過濾所有可能不當的內容，適合家庭使用',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 保存按鈕
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '保存設定',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.white.withOpacity(0.5);
      }),
      activeTrackColor: Colors.white.withOpacity(0.5),
      inactiveThumbColor: Colors.white.withOpacity(0.5),
      inactiveTrackColor: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getFilterLevelText() {
    switch (_filterSensitivity.round()) {
      case 1:
        return '寬鬆';
      case 2:
        return '標準';
      case 3:
        return '嚴格';
      default:
        return '標準';
    }
  }

  void _saveSettings() {
    // 這裡應該保存設定到本地存儲或服務器
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('設定已保存'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
