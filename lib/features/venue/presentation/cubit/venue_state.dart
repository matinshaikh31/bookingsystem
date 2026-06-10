import 'package:equatable/equatable.dart';
import '../../domain/models/venue_model.dart';

class VenueState extends Equatable {
  final List<VenueModel> allVenues;
  final List<VenueModel> filteredVenues;
  final String searchQuery;
  final String selectedSport;
  final bool isLoading;
  final String? errorMessage;

  const VenueState({
    required this.allVenues,
    required this.filteredVenues,
    required this.searchQuery,
    required this.selectedSport,
    required this.isLoading,
    this.errorMessage,
  });

  factory VenueState.initial() {
    return const VenueState(
      allVenues: [],
      filteredVenues: [],
      searchQuery: '',
      selectedSport: 'All',
      isLoading: false,
      errorMessage: null,
    );
  }

  VenueState copyWith({
    List<VenueModel>? allVenues,
    List<VenueModel>? filteredVenues,
    String? searchQuery,
    String? selectedSport,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VenueState(
      allVenues: allVenues ?? this.allVenues,
      filteredVenues: filteredVenues ?? this.filteredVenues,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSport: selectedSport ?? this.selectedSport,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        allVenues,
        filteredVenues,
        searchQuery,
        selectedSport,
        isLoading,
        errorMessage,
      ];
}
