import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../models/message.dart';

class TranslationButton extends StatelessWidget {
  final Message message;
  final VoidCallback? onTranslated;
  
  const TranslationButton({
    super.key,
    required this.message,
    this.onTranslated,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        // 如果已經翻譯過，顯示原文/譯文切換按鈕
        if (message.isTranslated) {
          return _buildToggleButton(context, messageProvider);
        }
        
        // 如果正在翻譯，顯示載入狀態
        if (messageProvider.isTranslating(message.id)) {
          return _buildLoadingButton();
        }
        
        // 顯示翻譯按鈕
        return _buildTranslateButton(context, messageProvider);
      },
    );
  }
  
  Widget _buildTranslateButton(BuildContext context, MessageProvider messageProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () async {
          await messageProvider.translateMessage(message.id);
          onTranslated?.call();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.translate,
                size: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 4),
              Text(
                '翻譯',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingButton() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '翻譯中...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildToggleButton(BuildContext context, MessageProvider messageProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顯示語言標籤
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getLanguageLabel(message.originalLanguage),
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 翻譯成功標籤
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 12,
                  color: Colors.green.withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  '已翻譯',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getLanguageLabel(String? languageCode) {
    const Map<String, String> languageLabels = {
      'km': '高棉語',
      'th': '泰語',
      'vi': '越南語',
      'zh': '中文',
      'zh-TW': '繁中',
      'zh-CN': '簡中',
      'en': 'English',
      'ja': '日語',
      'ko': '韓語',
      'fr': 'Français',
      'de': 'Deutsch',
      'es': 'Español',
      'it': 'Italiano',
      'ru': 'Русский',
    };
    
    return languageLabels[languageCode] ?? '未知';
  }
}