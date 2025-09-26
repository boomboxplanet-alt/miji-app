import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/content_moderation_service.dart';
import '../providers/task_provider.dart';
// 移除自定義圖示import，使用原始Material Design圖示

class QuickSendWidget extends StatefulWidget {
  final Function(String, double, Duration, bool, String?) onSend;

  const QuickSendWidget({super.key, required this.onSend});

  @override
  State<QuickSendWidget> createState() => _QuickSendWidgetState();
}

class _QuickSendWidgetState extends State<QuickSendWidget> {
  final TextEditingController _controller = TextEditingController();
  double _radius = 1000.0; // 1公里 = 1000米，將根據用戶權限動態更新
  Duration _destroyDuration = const Duration(hours: 1); // 預設1小時，將根據用戶權限動態更新
  final bool _isAnonymous = true; // 預設僅提供匿名發送
  int _currentBytes = 0;
  static const int _maxBytes = 200;

  // 獲取用戶的實際範圍權限（基礎+獎勵）
  double _getUserTotalRange() {
    final taskProvider = context.read<TaskProvider>();
    const baseRangeMeters = 1000.0; // 基礎1公里
    final bonusRange = taskProvider.bonusRangeMeters;
    return baseRangeMeters + bonusRange;
  }

  // 獲取用戶的實際時間權限（基礎+獎勵）
  Duration _getUserTotalDuration() {
    final taskProvider = context.read<TaskProvider>();
    const baseDurationMinutes = 60; // 基礎1小時
    final bonusDuration = taskProvider.bonusDurationMinutes;
    return Duration(minutes: baseDurationMinutes + bonusDuration);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateByteCount);

    // 初始化用戶的實際權限值
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _radius = _getUserTotalRange();
          _destroyDuration = _getUserTotalDuration();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateByteCount);
    _controller.dispose();
    super.dispose();
  }

  void _updateByteCount() {
    setState(() {
      _currentBytes = _controller.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667eea).withValues(alpha: 0.82),
                const Color(0xFF764ba2).withValues(alpha: 0.82),
                const Color(0xFFf093fb).withValues(alpha: 0.82),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 頂部列：標題與匿名切換
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '快速訊息',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ChoiceChip(
                  label: const Text('匿名'),
                  selected: true,
                  onSelected: null,
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  selectedColor: Colors.white.withValues(alpha: 0.35),
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  shape: StadiumBorder(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                ),
              ],
            ),
          ),
          // 輸入框和發送按鈕區域
          Column(
            children: [
              // 輸入框和發送按鈕的行布局
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 輸入框區域
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLength: _maxBytes,
                        maxLines: null,
                        minLines: 2,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        enableInteractiveSelection: true,
                        autocorrect: true,
                        enableSuggestions: true,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: '說點什麼...（最多200字節）',
                          border: InputBorder.none,
                          counterText: '',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Icon(
                              Icons.edit_outlined,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 20,
                            ),
                          ),
                        ),
                        onChanged: (text) {
                          if (text.length > _maxBytes) {
                            _controller.text = text.substring(0, _maxBytes);
                            _controller.selection = TextSelection.fromPosition(
                              const TextPosition(offset: _maxBytes),
                            );
                          }
                          // 觸發重繪以更新按鈕可用狀態
                          setState(() {});
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 右側操作區（等寬等高）
                  SizedBox(
                    width: 112,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildActionButton(
                          icon: Icons.bubble_chart,
                          label: '泡泡設置',
                          onTap: () => _showSettingsBottomSheet(context),
                          primary: false,
                        ),
                        const SizedBox(height: 8),
                        _buildActionButton(
                          icon: Icons.send,
                          label: '發送',
                          onTap: _controller.text.trim().isEmpty
                              ? null
                              : () => _handleSendMessage(),
                          primary: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 字節計數顯示
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$_currentBytes/$_maxBytes 字節',
                      style: TextStyle(
                        color: _currentBytes > _maxBytes * 0.8
                            ? Colors.orange.withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 標題欄
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '訊息設定',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // 快選設定區域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // 基本設定區域
                    _buildSettingCard(
                      title: '基本設定',
                      icon: Icons.settings,
                      children: [
                        // 匿名設定
                        _buildSwitchTile(
                          title: '匿名發送',
                          subtitle: '已固定匿名模式',
                          icon: Icons.visibility_off,
                          value: true,
                          onChanged: (_) {},
                        ),
                        // 移除名稱輸入，等待後續登入系統提供
                        const Divider(color: Colors.white24, height: 1),
                        // 銷毀時間設定
                        _buildInfoTile(
                          title: '銷毀時間',
                          subtitle: '當前: ${_formatDestroyTime()}',
                          icon: Icons.schedule,
                          onTap: () => _showTimeSelector(),
                        ),
                        const Divider(color: Colors.white24, height: 1),
                        // 傳播範圍設定
                        _buildInfoTile(
                          title: '傳播範圍',
                          subtitle: '當前: ${_formatRange(_radius)}',
                          icon: Icons.radar,
                          onTap: () => _showRangeSelector(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 外觀設定區域
                    _buildSettingCard(
                      title: '外觀設定',
                      icon: Icons.palette,
                      children: [
                        _buildColorSelector(),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // AI助手區域
                    _buildSettingCard(
                      title: 'AI助手',
                      icon: Icons.auto_awesome,
                      children: [
                        _buildAIButtons(),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setDestroyTime(Duration duration) {
    setState(() {
      // 確保設定的時間不超過用戶的權限上限
      final maxDuration = _getUserTotalDuration();
      if (duration.inMinutes <= maxDuration.inMinutes) {
        _destroyDuration = duration;
      } else {
        _destroyDuration = maxDuration;
        // 顯示提示訊息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('設定時間超過權限上限，已調整為最大可用時間：${_formatDuration(maxDuration)}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
    Navigator.pop(context);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '$hours小時$minutes分鐘' : '$hours小時';
    } else {
      return '$minutes分鐘';
    }
  }

  // 動態生成基於用戶權限的時間選項
  List<Widget> _buildTimeOptions() {
    final maxDuration = _getUserTotalDuration();
    final maxMinutes = maxDuration.inMinutes;

    List<Widget> options = [];

    // 基礎選項（如果在權限範圍內）
    final baseOptions = [
      {'minutes': 1, 'label': '1分'},
      {'minutes': 5, 'label': '5分'},
      {'minutes': 10, 'label': '10分'},
      {'minutes': 30, 'label': '30分'},
      {'minutes': 60, 'label': '1時'},
      {'minutes': 120, 'label': '2時'},
      {'minutes': 180, 'label': '3時'},
      {'minutes': 360, 'label': '6時'},
      {'minutes': 720, 'label': '12時'},
      {'minutes': 1440, 'label': '1天'},
    ];

    // 添加在權限範圍內的選項
    for (final option in baseOptions) {
      final minutes = option['minutes'] as int;
      if (minutes <= maxMinutes) {
        final label = option['label'] as String;
        final duration = Duration(minutes: minutes);
        options.add(
          _buildQuickSelectButton(
            label,
            () => _setDestroyTime(duration),
            _destroyDuration.inMinutes == minutes,
          ),
        );
      }
    }

    // 如果用戶權限不是標準選項，添加最大權限選項
    if (!baseOptions
        .any((option) => (option['minutes'] as int) == maxMinutes)) {
      final maxLabel = _formatDestroyTime(maxDuration);
      options.add(
        _buildQuickSelectButton(
          '最大 ($maxLabel)',
          () => _setDestroyTime(maxDuration),
          _destroyDuration.inMinutes == maxMinutes,
        ),
      );
    }

    return options;
  }

  // 格式化時間顯示
  String _formatDestroyTime([Duration? duration]) {
    final d = duration ?? _destroyDuration;
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;

    if (hours >= 24) {
      final days = hours ~/ 24;
      final remainingHours = hours % 24;
      if (remainingHours > 0) {
        return '$days天$remainingHours時';
      } else {
        return '$days天';
      }
    } else if (hours > 0) {
      if (minutes > 0) {
        return '$hours時$minutes分';
      } else {
        return '$hours時';
      }
    } else {
      return '$minutes分';
    }
  }

  // 動態生成基於用戶權限的範圍選項
  List<Widget> _buildRangeOptions() {
    final maxRange = _getUserTotalRange();

    List<Widget> options = [];

    // 基礎選項（如果在權限範圍內）
    final baseOptions = [
      {'meters': 50.0, 'label': '50m'},
      {'meters': 100.0, 'label': '100m'},
      {'meters': 200.0, 'label': '200m'},
      {'meters': 300.0, 'label': '300m'},
      {'meters': 500.0, 'label': '500m'},
      {'meters': 800.0, 'label': '800m'},
      {'meters': 1000.0, 'label': '1km'},
      {'meters': 1500.0, 'label': '1.5km'},
      {'meters': 2000.0, 'label': '2km'},
      {'meters': 3000.0, 'label': '3km'},
      {'meters': 5000.0, 'label': '5km'},
    ];

    // 添加在權限範圍內的選項
    for (final option in baseOptions) {
      final meters = option['meters'] as double;
      if (meters <= maxRange) {
        final label = option['label'] as String;
        options.add(
          _buildQuickSelectButton(
            label,
            () => _setRange(meters),
            (_radius - meters).abs() < 0.1, // 浮點數比較
          ),
        );
      }
    }

    // 如果用戶權限不是標準選項，添加最大權限選項
    if (!baseOptions.any(
        (option) => ((option['meters'] as double) - maxRange).abs() < 0.1)) {
      final maxLabel = _formatRange(maxRange);
      options.add(
        _buildQuickSelectButton(
          '最大 ($maxLabel)',
          () => _setRange(maxRange),
          (_radius - maxRange).abs() < 0.1,
        ),
      );
    }

    return options;
  }

  // 格式化範圍顯示
  String _formatRange(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      if (km == km.toInt()) {
        return '${km.toInt()}km';
      } else {
        return '${km.toStringAsFixed(1)}km';
      }
    } else {
      return '${meters.toInt()}m';
    }
  }

  // 設定範圍
  void _setRange(double range) {
    setState(() {
      // 確保設定的範圍不超過用戶的權限上限
      final maxRange = _getUserTotalRange();
      if (range <= maxRange) {
        _radius = range;
      } else {
        _radius = maxRange;
        // 顯示提示訊息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('設定範圍超過權限上限，已調整為最大可用範圍：${_formatRange(maxRange)}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
    Navigator.pop(context);
  }

  // 顏色選擇器
  Widget _buildColorSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildColorButton(const Color(0xFF667eea)),
          _buildColorButton(const Color(0xFF764ba2)),
          _buildColorButton(const Color(0xFFf093fb)),
          _buildColorButton(Colors.red),
          _buildColorButton(Colors.green),
          _buildColorButton(Colors.orange),
          _buildColorButton(Colors.blue),
          _buildColorButton(Colors.purple),
        ],
      ),
    );
  }

  // AI按鈕組
  Widget _buildAIButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAIButton(
                  '生成訊息',
                  Icons.auto_awesome,
                  () => _generateAIMessage(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAIButton(
                  '優化文字',
                  Icons.edit,
                  () => _optimizeText(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildAIButton(
              '翻譯',
              Icons.translate,
              () => _translateText(),
            ),
          ),
        ],
      ),
    );
  }

  // AI按鈕
  Widget _buildAIButton(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButtonIcon(icon),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 統一樣式的動作按鈕（等寬等高）
  // 重新設計的按鈕圖示 - 使用原始Material Design圖示
  Widget _buildButtonIcon(IconData icon, {double size = 18}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: const Color(0xFF667eea),
        size: size * 0.7,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool primary = false,
  }) {
    final bool disabled = onTap == null;
    final Gradient gradient = primary
        ? LinearGradient(
            colors: disabled
                ? [Colors.grey.shade500.withValues(alpha: 0.6), Colors.grey.shade600.withValues(alpha: 0.6)]
                : [const Color(0xFF667eea), const Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.28), Colors.white.withValues(alpha: 0.18)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Opacity(
      opacity: disabled ? 0.7 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: primary ? 0.25 : 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: (primary ? const Color(0xFF667eea) : Colors.black)
                    .withValues(alpha: primary ? 0.25 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButtonIcon(icon, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 顯示時間選擇器
  void _showTimeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 標題欄
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '選擇銷毀時間',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // 時間選項
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildTimeOptions(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 顯示範圍選擇器
  void _showRangeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 標題欄
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '選擇傳播範圍',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // 範圍選項
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildRangeOptions(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _generateAIMessage() {
    // AI生成訊息功能
    Navigator.pop(context);
  }

  void _optimizeText() {
    // 優化文字功能
    Navigator.pop(context);
  }

  void _translateText() {
    // 翻譯功能
    Navigator.pop(context);
  }

  void _handleSendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    // 內容審核檢查
    final moderationService = ContentModerationService();
    final result = moderationService.moderateContent(message);

    if (!result.isAllowed) {
      // 顯示違規提示
      _showModerationDialog(
        title: '內容審核未通過',
        message: result.reason,
        severity: result.severity,
      );
      return;
    }

    if (result.requiresReview) {
      // 內容需要審核但允許發送
      _showModerationDialog(
        title: '內容已標記審核',
        message: result.reason,
        severity: result.severity,
        allowSend: true,
        onConfirm: () => _sendMessage(message),
      );
      return;
    }

    // 內容審核通過，直接發送
    _sendMessage(message);
  }

  void _sendMessage(String message) {
    widget.onSend(
      message,
      _radius,
      _destroyDuration,
      _isAnonymous,
      null,
    );
    _controller.clear();
  }
  

  void _showModerationDialog({
    required String title,
    required String message,
    required ModerationSeverity severity,
    bool allowSend = false,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getSeverityIcon(severity),
              color: _getSeverityColor(severity),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          if (allowSend && onConfirm != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                '仍要發送',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (!allowSend)
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('我知道了'),
            ),
        ],
      ),
    );
  }

  IconData _getSeverityIcon(ModerationSeverity severity) {
    switch (severity) {
      case ModerationSeverity.high:
        return Icons.dangerous;
      case ModerationSeverity.medium:
        return Icons.warning;
      case ModerationSeverity.low:
        return Icons.info;
      case ModerationSeverity.none:
        return Icons.check_circle;
    }
  }

  Color _getSeverityColor(ModerationSeverity severity) {
    switch (severity) {
      case ModerationSeverity.high:
        return Colors.red;
      case ModerationSeverity.medium:
        return Colors.orange;
      case ModerationSeverity.low:
        return Colors.blue;
      case ModerationSeverity.none:
        return Colors.green;
    }
  }

  // 設定卡片容器
  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題欄
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
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
          // 內容區域
          ...children,
        ],
      ),
    );
  }

  // 開關設定項
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return Colors.white.withValues(alpha: 0.5);
            }),
            activeTrackColor: Colors.white.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.5),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  // 信息設定項
  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.8),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSelectButton(String text, VoidCallback onTap,
      [bool isSelected = false]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return InkWell(
      onTap: () {
        // 設定顏色功能
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }


}
