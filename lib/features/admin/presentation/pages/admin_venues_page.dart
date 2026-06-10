import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service/firebase.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../venue/domain/models/venue_model.dart';
import '../../../venue/data/venue_fb_repo.dart';
import '../widgets/create_venue_sheet.dart';
import 'admin_shell.dart';

class AdminVenuesPage extends StatelessWidget {
  const AdminVenuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAdminAppBar(context, 'Venues'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New venue'),
        onPressed: () => CreateVenueSheet.show(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FBFireStore.venues
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return _emptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load venues',
              subtitle: snapshot.error.toString(),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _emptyState(
              icon: Icons.stadium_outlined,
              title: 'No venues yet',
              subtitle: 'Tap "New venue" to create the first one.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final v = VenueModel.fromFirestore(docs[i]);
              return _VenueCard(venue: v);
            },
          );
        },
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
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
}

class _VenueCard extends StatelessWidget {
  final VenueModel venue;
  const _VenueCard({required this.venue});

  Future<void> _deleteVenue(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Venue'),
        content: Text('Are you sure you want to delete "${venue.name}"? This will remove the venue from database.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<VenueFbRepo>().deleteVenue(venue.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${venue.name}" deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_soccer_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name, style: AppTextStyles.titleBold),
                const SizedBox(height: 2),
                Text(
                  '${venue.sport} • ${venue.location}',
                  style: AppTextStyles.bodyRegular,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${venue.pricePerSlot.toStringAsFixed(0)}',
                style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.textSecondary),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    tooltip: 'Edit',
                    onPressed: () => CreateVenueSheet.show(context, venue: venue),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.primary),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    tooltip: 'Delete',
                    onPressed: () => _deleteVenue(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
