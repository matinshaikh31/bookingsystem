import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/helpers/date_helper.dart';
import '../../../../core/service/firebase.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../venue/data/venue_fb_repo.dart';
import '../../../venue/domain/models/venue_model.dart';
import '../../../booking/data/booking_fb_repo.dart';
import '../../../booking/domain/models/booking_model.dart';
import '../../../booking/presentation/cubit/booking_cubit.dart';
import '../../../booking/presentation/cubit/booking_state.dart';
import 'admin_shell.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  bool _isCalendar = true;

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
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  void _showBookingDetails(BuildContext context, BookingModel booking) {
    final formattedDate = DateHelper.formatToDmy(booking.date);
    final createdDate = DateFormat('dd MMM yyyy, hh:mm a').format(booking.createdAt);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.event_available_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Booking Details', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Venue', booking.venueName, isBold: true),
            const Divider(height: 16),
            _detailRow('Booked By', booking.userName),
            _detailRow('User Email', booking.userEmail),
            const Divider(height: 16),
            _detailRow('Date', formattedDate),
            _detailRow('Time Slot', booking.slot),
            _detailRow('Status', booking.status.toUpperCase(), 
                valueColor: booking.status == 'confirmed' ? AppColors.success : AppColors.primary),
            const Divider(height: 16),
            _detailRow('Created At', createdDate, isSmall: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false, Color? valueColor, bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmall ? 12 : 14,
                color: AppColors.textSecondary,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isSmall ? 12 : 14,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final venueRepo = context.read<VenueFbRepo>();
    final bookingRepo = context.read<BookingFbRepo>();
    final bookingCubit = context.read<BookingCubit>();

    return StreamBuilder<List<VenueModel>>(
      stream: venueRepo.streamVenues(),
      builder: (context, venuesSnapshot) {
        final venues = venuesSnapshot.data ?? [];

        return BlocBuilder<BookingCubit, BookingState>(
          builder: (context, bookingState) {
            // Auto-select first venue if none is set
            if (venues.isNotEmpty &&
                (bookingState.selectedVenueId.isEmpty ||
                    !venues.any((v) => v.id == bookingState.selectedVenueId))) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                bookingCubit.selectVenue(venues.first.id);
              });
            }

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: buildAdminAppBar(context, 'Bookings'),
              body: Column(
                children: [
                  // View Toggle Header
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'View Mode:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              _buildToggleOption('Calendar', _isCalendar, () {
                                setState(() => _isCalendar = true);
                              }),
                              _buildToggleOption('List View', !_isCalendar, () {
                                setState(() => _isCalendar = false);
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),

                  // Calendar View Mode
                  if (_isCalendar) ...[
                    // Venue Filter Dropdown
                    Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list_rounded, size: 20, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          const Text('Venue: ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: venues.isEmpty
                                ? const Text('No venues available', style: TextStyle(color: AppColors.textLight))
                                : DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: bookingState.selectedVenueId.isEmpty ? null : bookingState.selectedVenueId,
                                      isExpanded: true,
                                      dropdownColor: AppColors.surface,
                                      icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                                      hint: const Text('Select a Venue'),
                                      items: venues.map((venue) {
                                        return DropdownMenuItem<String>(
                                          value: venue.id,
                                          child: Text(venue.name, style: AppTextStyles.bodyBold),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          bookingCubit.selectVenue(val);
                                        }
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),

                    // Date Navigator Header (only when venue selected)
                    if (bookingState.selectedVenueId.isNotEmpty) ...[
                      Container(
                        color: AppColors.surface,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectDate(context, bookingCubit, bookingState.selectedStartDate),
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
                                            DateHelper.formatToDmy(bookingState.selectedStartDate),
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
                            // Filter row and legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: ['All', 'Day', 'Night'].map((filter) {
                                    final isSelected = bookingState.slotFilter == filter;
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
                                    SizedBox(width: 8),
                                    _LegendDot(color: Colors.white, border: AppColors.border, label: 'Avail'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),

                      // Calendar Grid Content
                      Expanded(
                        child: StreamBuilder<List<BookingModel>>(
                          stream: bookingRepo.streamVenueBookings(bookingState.selectedVenueId),
                          builder: (context, bookingsSnapshot) {
                            final bookings = bookingsSnapshot.data ?? [];
                            final dates = _getDatesList(bookingState.selectedStartDate);
                            final filteredSlots = _getFilteredSlots(bookingState.slotFilter);

                            return Column(
                              children: [
                                // Grid Column Headers (Dates)
                                Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.surface,
                                    border: Border(bottom: BorderSide(color: AppColors.border)),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 80,
                                        height: 44,
                                        child: Center(child: Text('Time', style: AppTextStyles.captionBold)),
                                      ),
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

                                // Grid Rows (Slots)
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    itemCount: filteredSlots.length,
                                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                                    itemBuilder: (context, slotIdx) {
                                      final slotTime = filteredSlots[slotIdx];
                                      final isNight = _isNightSlot(slotTime);

                                      return SizedBox(
                                        height: 56,
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
                                              BookingModel? matchingBooking;
                                              for (final b in bookings) {
                                                if (DateHelper.formatToYmd(b.date) == dateKey && b.slot == slotTime) {
                                                  matchingBooking = b;
                                                  break;
                                                }
                                              }
                                              final isBooked = matchingBooking != null;

                                              Color cellColor = Colors.white;
                                              Color textColor = AppColors.textPrimary;
                                              Border border = Border.all(color: AppColors.border);
                                              String slotLabel = 'Available';

                                              if (isBooked) {
                                                cellColor = Colors.red.shade50;
                                                textColor = Colors.red.shade700;
                                                border = Border.all(color: Colors.red.shade200);
                                                slotLabel = 'Booked';
                                              }

                                              return Expanded(
                                                child: InkWell(
                                                  onTap: isBooked
                                                      ? () => _showBookingDetails(context, matchingBooking!)
                                                      : null,
                                                  child: Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: cellColor,
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: border,
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      slotLabel,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: textColor,
                                                      ),
                                                      textAlign: TextAlign.center,
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
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ] else ...[
                    // Chronological List View Mode
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FBFireStore.bookings
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
                              'Could not load bookings',
                              snapshot.error.toString(),
                            );
                          }
                          final docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return _empty(
                              Icons.event_busy_rounded,
                              'No bookings yet',
                              'Bookings made by users will appear here.',
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            itemCount: docs.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final b = BookingModel.fromFirestore(docs[i]);
                              return _BookingTile(booking: b, onTap: () => _showBookingDetails(context, b));
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToggleOption(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
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

class _BookingTile extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  const _BookingTile({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateHelper.formatToEeemmd(booking.date);
    final isCancelled = booking.status == 'cancelled';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(booking.venueName, style: AppTextStyles.titleBold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCancelled ? AppColors.border : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCancelled ? AppColors.textSecondary : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$dateStr • ${booking.slot}',
              style: AppTextStyles.bodyRegular,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${booking.userName} • ${booking.userEmail}',
                    style: AppTextStyles.captionMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
