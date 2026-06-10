import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/helpers/date_helper.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/login_bottom_sheet.dart';
import '../../../venue/data/venue_fb_repo.dart';
import '../../../venue/domain/models/venue_model.dart';
import '../../data/booking_fb_repo.dart';
import '../../domain/models/booking_model.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class BookingPage extends StatelessWidget {
  final String venueId;
  const BookingPage({super.key, required this.venueId});

  static const List<String> _allTimeSlots = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
    '09:00 PM',
    '10:00 PM',
    '11:00 PM',
  ];

  bool _isNightSlot(String slot) {
    final isPM = slot.contains('PM');
    if (!isPM) return false;
    final hour = int.parse(slot.split(':')[0]);
    if (hour == 12) return false;
    return hour >= 6;
  }

  List<String> _getFilteredSlots(String slotFilter) {
    if (slotFilter == 'Day') {
      return _allTimeSlots.where((slot) => !_isNightSlot(slot)).toList();
    } else if (slotFilter == 'Night') {
      return _allTimeSlots.where((slot) => _isNightSlot(slot)).toList();
    }
    return _allTimeSlots;
  }

  List<DateTime> _getDatesList(DateTime startDate) {
    return List.generate(4, (index) => startDate.add(Duration(days: index)));
  }

  Future<void> _selectDate(BuildContext context, BookingCubit cubit, DateTime current) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current,
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
      cubit.selectStartDate(picked);
    }
  }

  Future<void> _handleBookingSubmit(
    BuildContext context,
    BookingCubit cubit,
    BookingState state,
    VenueModel venue,
  ) async {
    final authState = context.read<AuthCubit>().state;
    if (!authState.isAuthenticated) {
      LoginBottomSheet.show(context, navigateToProfile: false);
      return;
    }

    final user = authState.currentUser;
    if (user == null) return;

    final double totalCost = state.selectedSlots.length * venue.pricePerSlot;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Venue: ${venue.name}', style: AppTextStyles.bodyBold),
            const SizedBox(height: 8),
            Text('Slots selected: ${state.selectedSlots.length}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            Text('Total amount: ₹ ${totalCost.toStringAsFixed(0)}', style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      cubit.createBookingBatch(venue: venue, user: user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final venueRepo = context.read<VenueFbRepo>();
    final bookingRepo = context.read<BookingFbRepo>();
    final bookingCubit = context.read<BookingCubit>();

    return StreamBuilder<VenueModel?>(
      stream: venueRepo.streamVenue(venueId),
      builder: (context, venueSnapshot) {
        if (venueSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        final venue = venueSnapshot.data;
        if (venue == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Venue Details')),
            body: const Center(child: Text('Venue not found.')),
          );
        }

        return StreamBuilder<List<BookingModel>>(
          stream: bookingRepo.streamVenueBookings(venue.id),
          builder: (context, bookingsSnapshot) {
            final existingBookings = bookingsSnapshot.data ?? [];

            return BlocConsumer<BookingCubit, BookingState>(
              listener: (context, state) {
                if (state.isSuccess && state.successAction == BookingActionType.create) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking created successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  bookingCubit.clearMessage();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.go('/');
                    }
                  });
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
                final dates = _getDatesList(state.selectedStartDate);
                final filteredSlots = _getFilteredSlots(state.slotFilter);
                final double totalCost = state.selectedSlots.length * venue.pricePerSlot;

                return Scaffold(
                  backgroundColor: AppColors.background,
                  appBar: AppBar(
                    title: Text(venue.name),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () {
                        bookingCubit.clearSelection();
                        context.go('/');
                      },
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Container(color: AppColors.border, height: 1),
                    ),
                  ),
                  body: Column(
                    children: [
                      // Date Selector Header
                      Container(
                        color: AppColors.surface,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectDate(context, bookingCubit, state.selectedStartDate),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.border),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateHelper.formatToDmy(state.selectedStartDate),
                                            style: AppTextStyles.bodyBold,
                                          ),
                                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () => bookingCubit.setStartDateToday(),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  child: const Text('Today', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.keyboard_arrow_left_rounded),
                                  style: IconButton.styleFrom(
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => bookingCubit.adjustStartDate(-1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.keyboard_arrow_right_rounded),
                                  style: IconButton.styleFrom(
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => bookingCubit.adjustStartDate(1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Filters and Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: ['All', 'Day', 'Night'].map((filter) {
                                    final isSelected = state.slotFilter == filter;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ChoiceChip(
                                        showCheckmark: false,
                                        label: Text(filter),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          if (selected) {
                                            bookingCubit.toggleSlotFilter(filter);
                                          }
                                        },
                                        labelStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? Colors.white : AppColors.textSecondary,
                                        ),
                                        selectedColor: AppColors.black,
                                        backgroundColor: AppColors.background,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const Row(
                                  children: [
                                    _LegendDot(color: Colors.red, label: 'Booked'),
                                    SizedBox(width: 6),
                                    _LegendDot(color: Colors.white, border: AppColors.border, label: 'Avail'),
                                    SizedBox(width: 6),
                                    _LegendDot(color: Colors.teal, border: Colors.teal, label: 'Fast'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Slot Picker Grid
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                border: Border(bottom: BorderSide(color: AppColors.border)),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 80, height: 44, child: Center(child: Text('Time', style: AppTextStyles.captionBold))),
                                  ...dates.map((date) {
                                    final dayStr = DateHelper.formatToEee(date);
                                    final numStr = DateHelper.formatToDd(date);
                                    return Expanded(
                                      child: Container(
                                        height: 44,
                                        alignment: Alignment.center,
                                        child: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(text: '$numStr\n', style: AppTextStyles.bodyBold.copyWith(height: 1.1)),
                                              TextSpan(text: dayStr, style: AppTextStyles.caption.copyWith(fontSize: 10)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount: filteredSlots.length,
                                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                                itemBuilder: (context, slotIdx) {
                                  final slotTime = filteredSlots[slotIdx];
                                  final isNight = _isNightSlot(slotTime);

                                  return SizedBox(
                                    height: 64,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                                                size: 14,
                                                color: isNight ? Colors.indigo : Colors.orange,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(slotTime, style: AppTextStyles.captionBold.copyWith(fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                        ...dates.map((date) {
                                          final dateKey = DateHelper.formatToYmd(date);
                                          final slotKey = '$dateKey|$slotTime';

                                          BookingModel? matchingBooking;
                                          for (final b in existingBookings) {
                                            if (DateHelper.formatToYmd(b.date) == dateKey && b.slot == slotTime) {
                                              matchingBooking = b;
                                              break;
                                            }
                                          }
                                          final isBooked = matchingBooking != null;
                                          final isBookedByMe = isBooked && matchingBooking.userId == context.read<AuthCubit>().state.currentUser?.uid;

                                          bool isExpired = false;
                                          final now = DateTime.now();
                                          if (dateKey == DateHelper.formatToYmd(now)) {
                                            try {
                                              final slotDateTime = DateHelper.parseHma(slotTime);
                                              final nowTimeStr = DateHelper.formatToHma(now);
                                              final nowDateTime = DateHelper.parseHma(nowTimeStr);
                                              if (slotDateTime.isBefore(nowDateTime)) {
                                                isExpired = true;
                                              }
                                            } catch (_) {}
                                          }

                                          final isSelected = state.selectedSlots.contains(slotKey);

                                          Color cellColor = Colors.white;
                                          Color textColor = AppColors.textPrimary;
                                          Border border = Border.all(color: AppColors.border);
                                          String slotLabel = '1 left';

                                          if (isBooked) {
                                            cellColor = Colors.red.shade50;
                                            textColor = Colors.red.shade700;
                                            border = Border.all(color: Colors.red.shade200);
                                            slotLabel = isBookedByMe ? 'Your Book' : 'Booked';
                                          } else if (isExpired) {
                                            cellColor = AppColors.border;
                                            textColor = AppColors.textLight;
                                            slotLabel = 'N/A';
                                          } else if (isSelected) {
                                            cellColor = AppColors.primary;
                                            textColor = Colors.white;
                                            border = Border.all(color: AppColors.primaryDark);
                                          } else {
                                            final isFillingFast = (slotIdx + date.day) % 5 == 0;
                                            if (isFillingFast) {
                                              cellColor = Colors.teal.shade50;
                                              textColor = Colors.teal.shade700;
                                              border = Border.all(color: Colors.teal.shade200);
                                              slotLabel = 'Fast';
                                            }
                                          }

                                          return Expanded(
                                            child: InkWell(
                                              onTap: (isBooked || isExpired)
                                                  ? null
                                                  : () => bookingCubit.toggleSlot(slotKey),
                                              child: Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: cellColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: border,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    if (isBooked) ...[
                                                      Text(
                                                        slotLabel,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                          color: textColor,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ] else ...[
                                                      Text(
                                                        '₹${venue.pricePerSlot.toStringAsFixed(0)}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        slotLabel,
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.w500,
                                                          color: isSelected ? Colors.white70 : textColor.withValues(alpha: 0.8),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Sticky Footer
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          border: Border(top: BorderSide(color: AppColors.border)),
                        ),
                        child: state.selectedSlots.isEmpty
                            ? Container(
                                height: 52,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  'Please select slots',
                                  style: AppTextStyles.bodyBold.copyWith(color: AppColors.textSecondary),
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () => _handleBookingSubmit(context, bookingCubit, state, venue),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: state.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Book ${state.selectedSlots.length} Slots',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(width: 1, height: 16, color: Colors.white30),
                                            const SizedBox(width: 8),
                                            Text(
                                              '₹ ${totalCost.toStringAsFixed(0)}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final Color? border;
  final String label;

  const _LegendDot({
    required this.color,
    this.border,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: border != null ? Border.all(color: border!, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}
