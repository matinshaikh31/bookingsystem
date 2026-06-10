import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../venue/domain/models/venue_model.dart';
import '../../data/booking_fb_repo.dart';
import '../../domain/models/booking_model.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingFbRepo bookingFbRepo;

  BookingCubit({required this.bookingFbRepo}) : super(BookingState.initial());

  void adjustStartDate(int days) {
    emit(state.copyWith(
      selectedStartDate: state.selectedStartDate.add(Duration(days: days)),
      selectedSlots: const {},
    ));
  }

  void setStartDateToday() {
    final now = DateTime.now();
    emit(state.copyWith(
      selectedStartDate: DateTime(now.year, now.month, now.day),
      selectedSlots: const {},
    ));
  }

  void selectStartDate(DateTime date) {
    emit(state.copyWith(
      selectedStartDate: DateTime(date.year, date.month, date.day),
      selectedSlots: const {},
    ));
  }

  void toggleSlotFilter(String filter) {
    emit(state.copyWith(slotFilter: filter));
  }

  void toggleSlot(String slotKey) {
    final updated = Set<String>.from(state.selectedSlots);
    if (updated.contains(slotKey)) {
      updated.remove(slotKey);
    } else {
      updated.add(slotKey);
    }
    emit(state.copyWith(selectedSlots: updated));
  }

  void clearSelection() {
    emit(state.copyWith(selectedSlots: const {}));
  }

  void selectFilterDate(DateTime? date) {
    if (date == null) {
      clearFilterDate();
    } else {
      emit(state.copyWith(selectedFilterDate: DateTime(date.year, date.month, date.day)));
    }
  }

  void clearFilterDate() {
    emit(state.copyWith(clearFilterDate: true));
  }

  Future<void> createBookingBatch({
    required VenueModel venue,
    required UserModel user,
  }) async {
    if (state.selectedSlots.isEmpty) return;

    emit(state.copyWith(isLoading: true, isSuccess: false, successAction: BookingActionType.none, errorMessage: null));

    try {
      final List<BookingModel> bookings = [];
      for (var slotKey in state.selectedSlots) {
        final parts = slotKey.split('|');
        final dateStr = parts[0];
        final slotTime = parts[1];
        final parsedDate = DateTime.parse(dateStr);

        final booking = BookingModel(
          id: '', // Generated in repo
          venueId: venue.id,
          venueName: venue.name,
          userId: user.uid,
          userName: user.name,
          userEmail: user.email,
          date: parsedDate,
          slot: slotTime,
          status: 'confirmed',
          createdAt: DateTime.now(),
        );
        bookings.add(booking);
      }

      await bookingFbRepo.createBookings(bookings);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        successAction: BookingActionType.create,
        selectedSlots: const {},
      ));
    } catch (e) {
      final err = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(isLoading: false, errorMessage: err));
    }
  }

  Future<void> cancelUserBooking(String bookingId) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, successAction: BookingActionType.none, errorMessage: null));
    try {
      await bookingFbRepo.cancelBooking(bookingId);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        successAction: BookingActionType.cancel,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to cancel booking: $e'));
    }
  }

  void selectVenue(String venueId) {
    emit(state.copyWith(selectedVenueId: venueId));
  }

  void clearMessage() {
    emit(state.copyWith(errorMessage: null, isSuccess: false, successAction: BookingActionType.none));
  }
}
