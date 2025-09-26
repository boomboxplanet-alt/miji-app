import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:ui' as ui;
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
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent, // 透明背景，讓地圖顯示
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            margin: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    // 深藍漸層背景
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0A0A1A).withValues(alpha: 0.95),
                        const Color(0xFF1A1A2E).withValues(alpha: 0.95),
                        const Color(0xFF16213E).withValues(alpha: 0.95),
                        const Color(0xFF0F3460).withValues(alpha: 0.95),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF00BFFF).withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      // 外層陰影
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                      // 霓虹發光效果
                      BoxShadow(
                        color: const Color(0xFF00BFFF).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                      // 內層高光
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 標題區域
                      _buildHeader(context),

                      // 設定內容
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          children: [
                            _buildSectionTitle('隱私設定'),
                            _buildSettingCard([
                              _buildSwitchTile(
                                '匿名模式',
                                '發送訊息時不顯示個人資訊',
                                Icons.visibility_off,
                                _anonymousMode,
                                (value) =>
                                    setState(() => _anonymousMode = value),
                              ),
                              const Divider(height: 1),
                              _buildSwitchTile(
                                '位置服務',
                                '始終允許獲取位置資訊',
                                Icons.location_on,
                                _locationAlwaysOn,
                                (value) =>
                                    setState(() => _locationAlwaysOn = value),
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildSectionTitle('智能助手'),
                            Consumer<MessageProvider>(
                              builder: (context, messageProvider, child) {
                                return _buildSettingCard([
                                  _buildSwitchTile(
                                    'AI機器人',
                                    '自動生成有趣的留言，讓社區更活躍',
                                    Icons.smart_toy,
                                    messageProvider.isBotEnabled,
                                    (value) =>
                                        messageProvider.setBotEnabled(value),
                                  ),
                                  const Divider(height: 1),
                                  _buildListTile(
                                    'AI訊息語言',
                                    '選擇AI生成訊息的語言偏好',
                                    Icons.language,
                                    () => _showLanguageDialog(),
                                  ),
                                  const Divider(height: 1),
                                  _buildActionTile(
                                    '立即生成留言',
                                    '手動觸發AI生成一條留言',
                                    Icons.psychology,
                                    '生成',
                                    messageProvider.isBotEnabled
                                        ? () {
                                            messageProvider
                                                .generateBotMessageNow();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text('AI留言已生成！'),
                                                backgroundColor:
                                                    AppColors.accentColor,
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                ]);
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSectionTitle('通知設定'),
                            _buildSettingCard([
                              _buildSwitchTile(
                                '推送通知',
                                '接收附近新訊息的通知',
                                Icons.notifications,
                                _notificationsEnabled,
                                (value) => setState(
                                  () => _notificationsEnabled = value,
                                ),
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildSectionTitle('預設設定'),
                            _buildSettingCard([
                              _buildSliderTile(
                                '預設範圍',
                                '${_defaultRadius.toInt()} 米',
                                Icons.radar,
                                _defaultRadius,
                                AppConstants.minRadius,
                                AppConstants.maxRadius,
                                (value) =>
                                    setState(() => _defaultRadius = value),
                              ),
                              const Divider(height: 1),
                              _buildDropdownTile(
                                '預設時效',
                                AppConstants
                                    .durationLabels[_defaultDurationIndex],
                                Icons.timer,
                                _defaultDurationIndex,
                                AppConstants.durationLabels,
                                (value) => setState(
                                  () => _defaultDurationIndex = value,
                                ),
                              ),
                            ]),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 16),
                            _buildDangerZone(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 關閉按鈕
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                    const Color(0xFF3B82F6).withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF00BFFF).withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 標題
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF8B5CF6),
                            const Color(0xFF3B82F6),
                            const Color(0xFF06B6D4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF8B5CF6,
                            ).withValues(alpha: 0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'MIJI 秘跡',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '設定中心',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00BFFF).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFF00BFFF).withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 0),
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
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 圖標
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                  const Color(0xFF3B82F6).withValues(alpha: 0.8),
                  const Color(0xFF06B6D4).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00BFFF).withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),

          const SizedBox(width: 12),

          // 文字內容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),

          // 開關
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF00BFFF),
              activeTrackColor: const Color(0xFF00BFFF).withValues(alpha: 0.3),
              inactiveThumbColor: Colors.white.withValues(alpha: 0.8),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 圖標
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                  const Color(0xFF3B82F6).withValues(alpha: 0.8),
                  const Color(0xFF06B6D4).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00BFFF).withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),

          const SizedBox(width: 12),

          // 文字內容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),

          // 箭頭
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    String actionText,
    VoidCallback? onAction,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 圖標
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                  const Color(0xFF3B82F6).withValues(alpha: 0.8),
                  const Color(0xFF06B6D4).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00BFFF).withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),

          const SizedBox(width: 12),

          // 文字內容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),

          // 動作按鈕
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: onAction != null
                      ? [
                          const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                          const Color(0xFF3B82F6).withValues(alpha: 0.8),
                        ]
                      : [
                          Colors.grey.withValues(alpha: 0.3),
                          Colors.grey.withValues(alpha: 0.3),
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: onAction != null
                      ? const Color(0xFF00BFFF).withValues(alpha: 0.5)
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: onAction != null
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  color: onAction != null ? Colors.white : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 圖標
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                      const Color(0xFF3B82F6).withValues(alpha: 0.8),
                      const Color(0xFF06B6D4).withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00BFFF).withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),

              const SizedBox(width: 12),

              // 文字內容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 滑動條
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00BFFF),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              thumbColor: const Color(0xFF00BFFF),
              overlayColor: const Color(0xFF00BFFF).withValues(alpha: 0.2),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    int value,
    List<String> options,
    ValueChanged<int> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 圖標
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                  const Color(0xFF3B82F6).withValues(alpha: 0.8),
                  const Color(0xFF06B6D4).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00BFFF).withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),

          const SizedBox(width: 12),

          // 文字內容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),

          // 下拉選單
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                  const Color(0xFF3B82F6).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00BFFF).withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<int>(
              value: value,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              underline: Container(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16,
              ),
              items: options.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 圖標
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                  const Color(0xFF3B82F6).withValues(alpha: 0.8),
                  const Color(0xFF06B6D4).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00BFFF).withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),

          const SizedBox(width: 12),

          // 文字內容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),

          // 箭頭或版本號
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B6B).withValues(alpha: 0.15),
            const Color(0xFFFF8E53).withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF6B6B).withValues(alpha: 0.8),
                        const Color(0xFFFF8E53).withValues(alpha: 0.8),
                        const Color(0xFFFFD93D).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),

                const SizedBox(width: 8),

                const Expanded(
                  child: Text(
                    '危險區域',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              '以下操作將永久刪除您的數據，請謹慎操作',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.1,
              ),
            ),

            const SizedBox(height: 8),

            // 清除數據按鈕
            GestureDetector(
              onTap: () => _showClearDataDialog(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF6B6B).withValues(alpha: 0.8),
                      const Color(0xFFFF8E53).withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '清除所有數據',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI訊息語言'),
        content: const Text('選擇AI生成訊息的語言偏好'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
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
        content: const Text('這裡是隱私政策內容...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
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
        content: const Text('這裡是使用條款內容...'),
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
        title: const Text('清除所有數據'),
        content: const Text('此操作將永久刪除所有數據，無法恢復。確定要繼續嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 執行清除數據的邏輯
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}
