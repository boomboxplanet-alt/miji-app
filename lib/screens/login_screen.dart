import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../services/supabase_test.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withValues(alpha: 0.7),
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
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                      // 霓虹發光效果
                      BoxShadow(
                        color: const Color(0xFF00BFFF).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                      // 內層高光
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 標題區域
                      _buildHeader(context),

                      // 登入內容
                      Expanded(child: _buildLoginContent(context)),
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
                        borderRadius: BorderRadius.circular(7),
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
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                  '登入中心',
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

  Widget _buildLoginContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo 區域
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
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
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00BFFF).withValues(alpha: 0.6),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(
                        0xFF00BFFF,
                      ).withValues(alpha: 0.3 + (0.2 * _glowAnimation.value)),
                      blurRadius: 15 + (10 * _glowAnimation.value),
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // 標題
          const Text(
            '歡迎來到 MIJI 秘跡',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            '探索你周圍的秘密世界',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Supabase 狀態指示器
          _buildSupabaseStatus(context),

          const SizedBox(height: 24),

          // 登入按鈕
          _buildLoginButton(context),

          const SizedBox(height: 16),

          // 訪客模式按鈕
          _buildGuestButton(context),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00BFFF).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleGoogleLogin(context),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.login_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '使用訪客模式登入',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00BFFF).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleGuestMode(context),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFFF).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '使用訪客模式',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleGoogleLogin(BuildContext context) async {
    // Google 登入邏輯
    final authProvider = context.read<AuthProvider>();

    // 暫時使用訪客模式，因為 Google OAuth 需要額外配置
    print('Google 登入暫時使用訪客模式');
    await authProvider.signInAsGuest();
    Navigator.of(context).pop();
  }

  Widget _buildSupabaseStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00BFFF).withValues(alpha: 0.1),
            const Color(0xFF8B5CF6).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00BFFF).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF00BFFF),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00BFFF).withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Supabase 已整合',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '雲端認證與資料同步',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _testSupabaseConnection(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFFF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF00BFFF).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: const Text(
                '測試',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _testSupabaseConnection() async {
    await SupabaseTestService.testConnection();
  }

  void _handleGuestMode(BuildContext context) async {
    // 訪客模式邏輯
    final authProvider = context.read<AuthProvider>();
    await authProvider.signInAsGuest();
    Navigator.of(context).pop();
  }
}
