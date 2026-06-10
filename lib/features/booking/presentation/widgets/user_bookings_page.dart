import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/date_helper.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/auth_required_placeholder.dart';
import '../../data/booking_fb_repo.dart';
import '../../domain/models/booking_model.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class UserBookingsPage extends StatelessWidget {
  const UserBookingsPage({super.key});

  Future<void> _handleCancelBooking(
    BuildContext context,
    BookingCubit cubit,
    BookingModel booking,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel your booking at "${booking.venueName}" for ${booking.slot}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep Booking',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Cancel Booking',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      cubit.cancelUserBooking(booking.id);
    }
  }

  Future<void> _selectFilterDate(
    BuildContext context,
    BookingCubit cubit,
    DateTime? current,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      cubit.selectFilterDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingRepo = context.read<BookingFbRepo>();
    final bookingCubit = context.read<BookingCubit>();

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (!authState.isAuthenticated) {
          return const AuthRequiredPlaceholder(
            title: 'My Bookings',
            message:
                'Sign in to see and manage your active bookings and reservations.',
            icon: Icons.event_note_rounded,
          );
        }

        final user = authState.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return BlocConsumer<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state.isSuccess &&
                state.successAction == BookingActionType.cancel) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking cancelled successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
              bookingCubit.clearMessage();
            } else if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.primary,
                ),
              );
              bookingCubit.clearMessage();
            }
          },
          builder: (context, state) {
            final hasFilter = state.selectedFilterDate != null;

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: const Text('My Bookings'),
                centerTitle: false,
                titleSpacing: 20,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(color: AppColors.border, height: 1),
                ),
              ),
              body: Column(
                children: [
                  // Filter header container
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          hasFilter
                              ? 'Filtered by: ${DateHelper.formatToDmy(state.selectedFilterDate!)}'
                              : 'Showing latest 10 bookings',
                          style: AppTextStyles.captionBold.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            if (hasFilter) ...[
                              TextButton.icon(
                                onPressed: () => bookingCubit.clearFilterDate(),
                                icon: const Icon(
                                  Icons.filter_alt_off_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                label: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            OutlinedButton.icon(
                              onPressed: () => _selectFilterDate(
                                context,
                                bookingCubit,
                                state.selectedFilterDate,
                              ),
                              icon: const Icon(
                                Icons.date_range_rounded,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                              label: const Text(
                                'Filter Date',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  // Bookings List
                  Expanded(
                    child: StreamBuilder<List<BookingModel>>(
                      stream: bookingRepo.streamUserBookings(
                        user.uid,
                        filterDate: state.selectedFilterDate,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        }
                        final bookings = snapshot.data ?? [];

                        if (bookings.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 56,
                                    color: AppColors.textLight,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No bookings found',
                                    style: AppTextStyles.h3,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    hasFilter
                                        ? 'No bookings match the selected date. Try selecting another date or clear filters.'
                                        : 'You haven\'t made any bookings yet.',
                                    style: AppTextStyles.bodyRegular,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: bookings.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, idx) {
                            final booking = bookings[idx];
                            return _BookingItemCard(
                              booking: booking,
                              onCancel: () => _handleCancelBooking(
                                context,
                                bookingCubit,
                                booking,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BookingItemCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onCancel;

  const _BookingItemCard({required this.booking, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateHelper.formatToDmy(booking.date);
    final isConfirmed = booking.status == 'confirmed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.venueName,
                  style: AppTextStyles.titleBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isConfirmed ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(formattedDate, style: AppTextStyles.bodyRegular),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(booking.slot, style: AppTextStyles.bodyRegular),
                  ],
                ),
              ),
            ],
          ),
          if (isConfirmed) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.border),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Cancel Booking',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
