import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/service/firebase.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../auth/domain/models/user_model.dart';
import 'admin_shell.dart';
import '../../../../core/const/role.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAdminAppBar(context, 'Users'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FBFireStore.users
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return _empty(
              Icons.error_outline_rounded,
              'Could not load users',
              snapshot.error.toString(),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _empty(
              Icons.people_outline_rounded,
              'No users yet',
              'Registered users will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final u = UserModel.fromFirestore(docs[i]);
              return _UserTile(user: u);
            },
          );
        },
      ),
    );
  }

  Widget _empty(IconData icon, String title, String subtitle) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.bodyRegular,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == Roles.admin;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isNotEmpty ? user.name : '(no name)',
                  style: AppTextStyles.titleBold,
                ),
                const SizedBox(height: 2),
                Text(user.email, style: AppTextStyles.bodyRegular),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAdmin ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              user.role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isAdmin ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
