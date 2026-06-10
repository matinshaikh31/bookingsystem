import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/helpers/date_helper.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_required_placeholder.dart';

class ProfilePage extends StatelessWidget {
  final bool showLeading;
  const ProfilePage({super.key, this.showLeading = true});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!state.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(AppRoutes.home);
            }
          });
        }
      },
      builder: (context, state) {
        final user = state.currentUser;
        if (user == null) {
          return const AuthRequiredPlaceholder(
            title: 'My Profile',
            message:
                'Sign in to access your profile settings, view bookings, and manage account preferences.',
            icon: Icons.person_rounded,
          );
        }

        final joinedDate = DateHelper.formatToMy(user.createdAt);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('My Account'),
            leading: showLeading
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.go(AppRoutes.home),
                  )
                : null,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppColors.border, height: 1),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.softShadow,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.redShadow,
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: AppTextStyles.h2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: AppTextStyles.bodyRegular,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Member since $joinedDate',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Account settings section list
                Text(
                  'Preferences',
                  style: AppTextStyles.titleBold.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 12),

                // Cards with items
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        icon: Icons.bookmark_border_rounded,
                        title: 'My Bookings',
                        subtitle: 'Manage active reservations and flights',
                        onTap: () {},
                      ),
                      const Divider(),
                      _buildProfileItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        subtitle: 'Alerts, check-in info and updates',
                        onTap: () {},
                      ),
                      const Divider(),
                      _buildProfileItem(
                        icon: Icons.security_rounded,
                        title: 'Security',
                        subtitle: 'Change password or delete account',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Logout Button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Sign Out'),
                                content: const Text(
                                  'Are you sure you want to sign out?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Sign Out',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              context.read<AuthCubit>().logout();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Sign Out',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }
}
