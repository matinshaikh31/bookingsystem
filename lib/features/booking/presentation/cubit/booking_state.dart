import 'package:equatable/equatable.dart';

enum BookingActionType { none, create, cancel }

class BookingState extends Equatable {
  final DateTime selectedStartDate;
  final String slotFilter;
  final Set<String> selectedSlots;
  final DateTime? selectedFilterDate;
  final bool isLoading;
  final bool isSuccess;
  final BookingActionType successAction;
  final String? errorMessage;
  final String selectedVenueId;

  const BookingState({
    required this.selectedStartDate,
    required this.slotFilter,
    required this.selectedSlots,
    this.selectedFilterDate,
    required this.isLoading,
    required this.isSuccess,
    required this.successAction,
    this.errorMessage,
    required this.selectedVenueId,
  });

  factory BookingState.initial() {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    return BookingState(
      selectedStartDate: todayMidnight,
      slotFilter: 'All',
      selectedSlots: const {},
      selectedFilterDate: null,
      isLoading: false,
      isSuccess: false,
      successAction: BookingActionType.none,
      errorMessage: null,
      selectedVenueId: '',
    );
  }

  BookingState copyWith({
    DateTime? selectedStartDate,
    String? slotFilter,
    Set<String>? selectedSlots,
    DateTime? selectedFilterDate,
    bool? isLoading,
    bool? isSuccess,
    BookingActionType? successAction,
    String? errorMessage,
    String? selectedVenueId,
    bool clearFilterDate = false,
  }) {
    return BookingState(
      selectedStartDate: selectedStartDate ?? this.selectedStartDate,
      slotFilter: slotFilter ?? this.slotFilter,
      selectedSlots: selectedSlots ?? this.selectedSlots,
      selectedFilterDate: clearFilterDate ? null : (selectedFilterDate ?? this.selectedFilterDate),
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      successAction: successAction ?? this.successAction,
      errorMessage: errorMessage,
      selectedVenueId: selectedVenueId ?? this.selectedVenueId,
    );
  }

  @override
  List<Object?> get props => [
        selectedStartDate,
        slotFilter,
        selectedSlots,
        selectedFilterDate,
        isLoading,
        isSuccess,
        successAction,
        errorMessage,
        selectedVenueId,
      ];
}
