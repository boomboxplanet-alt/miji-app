import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.secondaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo區域
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 應用標題
                  const Text(
                    '秘跡 Miji',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 副標題
                  const Text(
                    '只在此時此地，說完即散',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 64),

                  // 登入區域
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '歡迎來到秘跡',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          '請登入以開始您的神秘之旅',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Google登入說明
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Google登入功能需要配置Client ID，目前請使用訪客模式體驗',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Google登入按鈕
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () => _handleGoogleSignIn(
                                        context, authProvider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                icon: authProvider.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.black54),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.login,
                                        size: 20,
                                        color: Colors.black54,
                                      ),
                                label: Text(
                                  authProvider.isLoading
                                      ? '登入中...'
                                      : '使用 Google 登入',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // 錯誤訊息
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            if (authProvider.errorMessage != null) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authProvider.errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          authProvider.clearError(),
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 訪客模式按鈕
                  TextButton(
                    onPressed: () => _handleGuestMode(context),
                    child: const Text(
                      '以訪客身份繼續',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 隱私政策和服務條款
                  const Text(
                    '登入即表示您同意我們的服務條款和隱私政策',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 處理Google登入
  Future<void> _handleGoogleSignIn(
      BuildContext context, AuthProvider authProvider) async {
    // 檢查是否使用佔位符Client ID
    if (_isPlaceholderClientId()) {
      // 顯示配置提示對話框
      _showConfigurationDialog(context);
      return;
    }

    final success = await authProvider.signInWithGoogle();

    if (success && context.mounted) {
      // 登入成功，導航到主界面
      await Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // 檢查是否為佔位符Client ID
  bool _isPlaceholderClientId() {
    // 這裡可以檢查當前配置的Client ID是否為佔位符
    return true; // 目前總是返回true，因為我們使用的是佔位符
  }

  // 顯示配置提示對話框
  void _showConfigurationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Google登入配置'),
          content: const Text(
            'Google登入功能需要配置有效的Client ID。\n\n'
            '請聯繫開發者完成配置，或使用訪客模式體驗應用功能。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('了解'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleGuestMode(context);
              },
              child: const Text('使用訪客模式'),
            ),
          ],
        );
      },
    );
  }

  // 處理訪客模式
  void _handleGuestMode(BuildContext context) {
    // 直接導航到主界面，不進行登入
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
