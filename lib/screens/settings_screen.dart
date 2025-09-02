import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/message_provider.dart';
import '../providers/location_provider.dart';
import '../services/enhanced_ai_service.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationAlwaysOn = false;
  bool _anonymousMode = true;
  double _defaultRadius = AppConstants.defaultRadius;
  int _defaultDurationIndex = 2; // 1小時

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667eea).withOpacity(0.95),
                const Color(0xFF764ba2).withOpacity(0.95),
                const Color(0xFFf093fb).withOpacity(0.95),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: AppBar(
            title: const Text(
              '設定',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('隱私設定'),
          _buildSettingCard([
            _buildSwitchTile(
              '匿名模式',
              '發送訊息時不顯示個人資訊',
              Icons.visibility_off,
              _anonymousMode,
              (value) => setState(() => _anonymousMode = value),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              '位置服務',
              '始終允許獲取位置資訊',
              Icons.location_on,
              _locationAlwaysOn,
              (value) => setState(() => _locationAlwaysOn = value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('智能助手'),
          Consumer<MessageProvider>(
            builder: (context, messageProvider, child) {
              return _buildSettingCard([
                _buildSwitchTile(
                  'AI機器人',
                  '自動生成有趣的留言，讓社區更活躍',
                  Icons.smart_toy,
                  messageProvider.isBotEnabled,
                  (value) => messageProvider.setBotEnabled(value),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language, color: Color(0xFF2D3748)),
                  title: const Text(
                    'AI訊息語言',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  subtitle: const Text(
                    '選擇AI生成訊息的語言偏好',
                    style: TextStyle(color: Color(0xFF718096)),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Color(0xFF718096)),
                  onTap: () => _showLanguageDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.psychology, color: Color(0xFF2D3748)),
                  title: const Text(
                    '立即生成留言',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  subtitle: const Text(
                    '手動觸發AI生成一條留言',
                    style: TextStyle(color: Color(0xFF718096)),
                  ),
                  trailing: ElevatedButton(
                    onPressed: messageProvider.isBotEnabled
                        ? () {
                            messageProvider.generateBotMessageNow();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('AI留言已生成！'),
                                backgroundColor: AppColors.accentColor,
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('生成'),
                  ),
                ),
              ]);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('通知設定'),
          _buildSettingCard([
            _buildSwitchTile(
              '推送通知',
              '接收附近新訊息的通知',
              Icons.notifications,
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('預設設定'),
          _buildSettingCard([
            _buildSliderTile(
              '預設範圍',
              '${_defaultRadius.toInt()} 米',
              Icons.radar,
              _defaultRadius,
              AppConstants.minRadius,
              AppConstants.maxRadius,
              (value) => setState(() => _defaultRadius = value),
            ),
            const Divider(height: 1),
            _buildDropdownTile(
              '預設時效',
              AppConstants.durationLabels[_defaultDurationIndex],
              Icons.timer,
              _defaultDurationIndex,
              AppConstants.durationLabels,
              (value) => setState(() => _defaultDurationIndex = value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('關於'),
          _buildSettingCard([
            _buildInfoTile(
              '版本資訊',
              '1.0.0',
              Icons.info_outline,
            ),
            const Divider(height: 1),
            _buildInfoTile(
              '隱私政策',
              '查看隱私政策',
              Icons.privacy_tip,
              onTap: () => _showPrivacyPolicy(),
            ),
            const Divider(height: 1),
            _buildInfoTile(
              '使用條款',
              '查看使用條款',
              Icons.description,
              onTap: () => _showTermsOfService(),
            ),
          ]),
          const SizedBox(height: 32),
          _buildDangerZone(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748), // 深灰色，更容易看見
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
          stops: const [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2D3748)), // 深灰色圖標
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748), // 深灰色標題
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF718096)), // 中等灰色副標題
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryColor;
          }
          return AppColors.primaryColor.withOpacity(0.5);
        }),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String value,
    IconData icon,
    double currentValue,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryColor,
              thumbColor: AppColors.primaryColor,
              overlayColor: AppColors.primaryColor.withOpacity(0.2),
            ),
            child: Slider(
              value: currentValue,
              min: min,
              max: max,
              divisions: ((max - min) / 50).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    IconData icon,
    int currentIndex,
    List<String> options,
    ValueChanged<int> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: DropdownButton<int>(
        value: currentIndex,
        underline: const SizedBox(),
        items: options.asMap().entries.map((entry) {
          return DropdownMenuItem<int>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: (int? newIndex) {
          if (newIndex != null) {
            onChanged(newIndex);
          }
        },
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ListTile(
            leading:
                const Icon(Icons.delete_forever, color: AppColors.errorColor),
            title: const Text(
              '清除所有資料',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.errorColor,
              ),
            ),
            subtitle: const Text(
              '刪除所有本地儲存的訊息和設定',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            onTap: () => _showClearDataDialog(),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隱私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '秘跡 Miji 致力於保護您的隱私。我們不會收集、儲存或分享您的個人資訊。所有訊息都是匿名的，並會在設定的時間後自動刪除。\n\n'
            '位置資訊僅用於確定訊息的地理範圍，不會被永久儲存或用於其他目的。\n\n'
            '我們使用本地儲存來暫時保存您的設定和訊息，這些資料不會上傳到我們的伺服器。',
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667eea).withOpacity(0.9),
                  const Color(0xFF764ba2).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '確定',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用條款'),
        content: const SingleChildScrollView(
          child: Text(
            '歡迎使用秘跡 Miji！\n\n'
            '1. 請勿發送違法、有害或不當內容\n'
            '2. 尊重他人隱私和權利\n'
            '3. 不得濫用本服務進行騷擾或垃圾訊息\n'
            '4. 我們保留刪除不當內容的權利\n'
            '5. 使用本服務即表示同意這些條款\n\n'
            '違反使用條款可能導致服務被暫停或終止。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除所有資料'),
        content: const Text('此操作將刪除所有本地儲存的訊息和設定，且無法復原。確定要繼續嗎？'),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.7),
                  Colors.grey.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '取消',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.9),
                  Colors.redAccent.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearAllData();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '確定刪除',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllData() async {
    try {
      // 清除MessageProvider中的訊息
      final messageProvider = context.read<MessageProvider>();
      messageProvider.clearAllMessages();

      // 清除LocationProvider中的位置資訊
      final locationProvider = context.read<LocationProvider>();
      locationProvider.clearLocationData();

      // 清除Hive本地資料庫
      await Hive.deleteFromDisk();

      // 重新初始化Hive
      await Hive.initFlutter();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('所有資料已清除'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('清除資料失敗: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  void _showLanguageDialog() {
    final aiService = EnhancedAIService();
    final options = aiService.getLanguageOptions();
    final currentPreference = aiService.languagePreference;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.language, color: AppColors.primaryColor),
            SizedBox(width: 8),
            Text('選擇AI訊息語言'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              subtitle: _getLanguageDescription(entry.key),
              value: entry.key,
              groupValue: currentPreference,
              onChanged: (value) {
                if (value != null) {
                  aiService.setLanguagePreference(value);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已設定為：${entry.value}'),
                      backgroundColor: AppColors.accentColor,
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.7),
                  Colors.grey.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '取消',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _getLanguageDescription(String key) {
    switch (key) {
      case 'auto':
        return const Text(
          '根據手機系統語言自動選擇',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        );
      case 'zh':
        return const Text(
          '始終使用中文生成訊息',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        );
      case 'local':
        return const Text(
          '使用當地語言生成訊息',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        );
      default:
        return null;
    }
  }
}
