import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../screens/login_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/task_screen.dart';

class FuturisticBottomNav extends StatefulWidget {
  final VoidCallback? onLocationPressed;
  final VoidCallback? onMessagePressed;

  const FuturisticBottomNav({
    super.key,
    this.onLocationPressed,
    this.onMessagePressed,
  });

  @override
  State<FuturisticBottomNav> createState() => _FuturisticBottomNavState();
}

class _FuturisticBottomNavState extends State<FuturisticBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();

    // 脈衝動畫控制器
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // 發光動畫控制器
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00BFFF).withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BFFF).withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. 用戶按鈕
              _buildLuxuryNavButton(
                context: context,
                icon: Icons.person_rounded,
                index: 0,
                onTap: () => _handleLogin(context),
              ),

              // 2. 定位按鈕
              _buildLuxuryNavButton(
                context: context,
                icon: Icons.navigation_rounded,
                index: 1,
                onTap: widget.onLocationPressed,
              ),

              // 3. 中央消息發送按鈕（特殊設計）
              _buildLuxuryCentralButton(
                context: context,
                icon: Icons.chat_bubble_outline_rounded,
                onTap: widget.onMessagePressed,
              ),

              // 4. 任務按鈕（帶提示和數量）
              _buildTaskButtonWithNotification(
                context: context,
                icon: Icons.task_alt_rounded,
                index: 2,
                onTap: () => _handleTask(context),
              ),

              // 5. 設置按鈕
              _buildLuxuryNavButton(
                context: context,
                icon: Icons.settings_rounded,
                index: 3,
                onTap: () => _handleSettings(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryNavButton({
    required BuildContext context,
    required IconData icon,
    required int index,
    required VoidCallback? onTap,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? -1 : index;
        });
        onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                // 紫藍漸層填色
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          const Color(0xFF8B5CF6),
                          const Color(0xFF3B82F6),
                          const Color(0xFF06B6D4),
                        ]
                      : [
                          const Color(0xFF1A1A2E).withValues(alpha: 0.6),
                          const Color(0xFF16213E).withValues(alpha: 0.4),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                // 霓虹描邊
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00BFFF).withValues(alpha: 0.8)
                      : const Color(0xFF00BFFF).withValues(alpha: 0.3),
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow: [
                  // 外層陰影
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                  // 霓虹發光效果
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFF00BFFF).withValues(alpha: 0.4),
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
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskButtonWithNotification({
    required BuildContext context,
    required IconData icon,
    required int index,
    required VoidCallback? onTap,
  }) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final bool isSelected = _selectedIndex == index;
        final int unclaimedCount = taskProvider.unclaimedCompletedTasksCount;
        final bool hasUnclaimedTasks = unclaimedCount > 0;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = isSelected ? -1 : index;
            });
            onTap?.call();
          },
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isSelected ? _pulseAnimation.value : 1.0,
                child: Stack(
                  children: [
                    // 主要按鈕
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        // 紫藍漸層填色
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isSelected
                              ? [
                                  const Color(0xFF8B5CF6),
                                  const Color(0xFF3B82F6),
                                  const Color(0xFF06B6D4),
                                ]
                              : [
                                  const Color(0xFF1A1A2E)
                                      .withValues(alpha: 0.6),
                                  const Color(0xFF16213E)
                                      .withValues(alpha: 0.4),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        // 霓虹描邊
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00BFFF).withValues(alpha: 0.8)
                              : const Color(0xFF00BFFF).withValues(alpha: 0.3),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: [
                          // 外層陰影
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                          // 霓虹發光效果
                          if (isSelected)
                            BoxShadow(
                              color: const Color(0xFF00BFFF)
                                  .withValues(alpha: 0.4),
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
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : Colors.white70,
                        size: 24,
                      ),
                    ),
                    // 通知徽章
                    if (hasUnclaimedTasks)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B)
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              unclaimedCount > 9
                                  ? '9+'
                                  : unclaimedCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLuxuryCentralButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: 64,
            height: 56,
            decoration: BoxDecoration(
              // 特殊中央按鈕漸層
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B5CF6),
                  const Color(0xFF3B82F6),
                  const Color(0xFF06B6D4),
                  const Color(0xFF00BFFF),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              // 強化霓虹描邊
              border: Border.all(
                color: const Color(0xFF00BFFF).withValues(alpha: 0.8),
                width: 2.5,
              ),
              boxShadow: [
                // 外層陰影
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                // 動態發光效果
                BoxShadow(
                  color: const Color(
                    0xFF00BFFF,
                  ).withValues(alpha: 0.4 + (0.3 * _glowAnimation.value)),
                  blurRadius: 20 + (10 * _glowAnimation.value),
                  offset: const Offset(0, 0),
                ),
                // 內層高光
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          );
        },
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user != null) {
      // 已登录，显示用户菜单
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('用户菜单'),
          content: Text('欢迎，${authProvider.user?.email ?? '用户'}'),
          actions: [
            TextButton(
              onPressed: () {
                authProvider.signOut();
                Navigator.of(context).pop();
              },
              child: const Text('退出登录', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      // 未登录，使用 showDialog 显示登录页面
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => const LoginScreen(),
      );
    }
  }

  void _handleTask(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const TaskScreen(),
    );
  }

  void _handleSettings(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SettingsScreen(),
    );
  }
}
