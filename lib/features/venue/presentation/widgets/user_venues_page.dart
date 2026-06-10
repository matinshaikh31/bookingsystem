import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../domain/models/venue_model.dart';
import '../cubit/venue_cubit.dart';
import '../cubit/venue_state.dart';

class UserVenuesPage extends StatelessWidget {
  const UserVenuesPage({super.key});

  // Predefined list of popular sports for filtering
  static const List<String> _sports = [
    'All',
    'Football',
    'Cricket',
    'Badminton',
    'Tennis',
    'Basketball',
  ];

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
      case 'soccer':
        return Icons.sports_soccer_rounded;
      case 'cricket':
        return Icons.sports_cricket_rounded;
      case 'badminton':
        return Icons.sports_tennis_rounded;
      case 'tennis':
        return Icons.sports_tennis_rounded;
      case 'basketball':
        return Icons.sports_basketball_rounded;
      default:
        return Icons.sports_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VenueCubit>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Available Venues'),
        centerTitle: false,
        titleSpacing: 20,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: BlocBuilder<VenueCubit, VenueState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Column(
            children: [
              // Search & Filters Header
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search Bar
                    TextField(
                      controller: cubit.searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search by venue name or location...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        suffixIcon: state.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 20),
                                onPressed: () => cubit.clearSearch(),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Horizontal Sports Filter
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _sports.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final sport = _sports[idx];
                          final isSelected = state.selectedSport == sport;
                          return ChoiceChip(
                            showCheckmark: false,
                            label: Text(sport),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                cubit.setSelectedSport(sport);
                              }
                            },
                            labelStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                            selectedColor: AppColors.black,
                            backgroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : AppColors.border,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Venues List
              Expanded(
                child: state.errorMessage != null
                    ? _emptyState(
                        icon: Icons.error_outline_rounded,
                        title: 'Error loading venues',
                        subtitle: state.errorMessage!,
                      )
                    : state.filteredVenues.isEmpty
                        ? _emptyState(
                            icon: Icons.stadium_outlined,
                            title: 'No venues found',
                            subtitle: 'Try adjusting your filters or search keywords.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            itemCount: state.filteredVenues.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 14),
                            itemBuilder: (context, i) {
                              final venue = state.filteredVenues[i];
                              return _UserVenueCard(
                                venue: venue,
                                icon: _getSportIcon(venue.sport),
                              );
                            },
                          ),
              ),
            ],
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

class _UserVenueCard extends StatelessWidget {
  final VenueModel venue;
  final IconData icon;

  const _UserVenueCard({
    required this.venue,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upper Info Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sport Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: AppTextStyles.titleBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              venue.location,
                              style: AppTextStyles.captionMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Price and CTA Bottom Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price per slot',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹ ${venue.pricePerSlot.toStringAsFixed(0)}',
                      style: AppTextStyles.titleBold.copyWith(
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/book/${venue.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      elevation: 0,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
