import 'package:flutter/material.dart';
import '../services/content_moderation_service.dart';

/// 舉報對話框
class ReportDialog extends StatefulWidget {
  final String messageId;
  final String reporterId;
  final VoidCallback? onReported;

  const ReportDialog({
    super.key,
    required this.messageId,
    required this.reporterId,
    this.onReported,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  final TextEditingController _additionalInfoController =
      TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moderationService = ContentModerationService();
    final reasons = moderationService.getReportReasons();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.report,
            color: Colors.red,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            '舉報內容',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '請選擇舉報原因：',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // 舉報原因選項
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: RadioGroup<String>(
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                  child: Column(
                    children: reasons.map((reason) {
                      return RadioListTile<String>(
                        title: Text(
                          reason,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: reason,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 額外說明
            const Text(
              '額外說明（選填）：',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _additionalInfoController,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: '請描述具體問題...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed:
              _isSubmitting || _selectedReason == null ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('提交舉報'),
        ),
      ],
    );
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final moderationService = ContentModerationService();
      final success = await moderationService.reportContent(
        messageId: widget.messageId,
        reporterId: widget.reporterId,
        reason: _selectedReason!,
        additionalInfo: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
      );

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          _showSuccessDialog();
          widget.onReported?.call();
        }
      } else {
        if (mounted) {
          _showErrorDialog('舉報提交失敗，請稍後重試');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('舉報提交失敗：$e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
            SizedBox(width: 8),
            Text('舉報成功'),
          ],
        ),
        content: const Text(
          '感謝您的舉報，我們會盡快處理。\n\n為了維護社區環境，我們鼓勵用戶積極舉報不當內容。',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 24,
            ),
            SizedBox(width: 8),
            Text('舉報失敗'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}

/// 顯示舉報對話框的便捷方法
void showReportDialog({
  required BuildContext context,
  required String messageId,
  required String reporterId,
  VoidCallback? onReported,
}) {
  showDialog(
    context: context,
    builder: (context) => ReportDialog(
      messageId: messageId,
      reporterId: reporterId,
      onReported: onReported,
    ),
  );
}
