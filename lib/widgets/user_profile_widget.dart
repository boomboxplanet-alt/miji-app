import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class UserProfileWidget extends StatelessWidget {
  final VoidCallback? onSignOut;

  const UserProfileWidget({
    super.key,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isSignedIn) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              // 用戶頭像
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryColor,
                backgroundImage: authProvider.userPhotoURL != null
                    ? NetworkImage(authProvider.userPhotoURL!)
                    : null,
                child: authProvider.userPhotoURL == null
                    ? Text(
                        authProvider.userDisplayName.isNotEmpty
                            ? authProvider.userDisplayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // 用戶資訊
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.userDisplayName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (authProvider.user?['email'] != null)
                      Text(
                        authProvider.user!['email'],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              
              // 登出按鈕
              if (onSignOut != null)
                IconButton(
                  onPressed: onSignOut,
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: '登出',
                ),
            ],
          ),
        );
      },
    );
  }
}
