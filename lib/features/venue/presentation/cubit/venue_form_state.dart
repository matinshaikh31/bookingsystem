import 'package:equatable/equatable.dart';

class VenueFormState extends Equatable {
  final String name;
  final String location;
  final String sport;
  final double pricePerSlot;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const VenueFormState({
    required this.name,
    required this.location,
    required this.sport,
    required this.pricePerSlot,
    required this.isLoading,
    required this.isSuccess,
    this.errorMessage,
  });

  factory VenueFormState.initial() {
    return const VenueFormState(
      name: '',
      location: '',
      sport: '',
      pricePerSlot: 0.0,
      isLoading: false,
      isSuccess: false,
      errorMessage: null,
    );
  }

  VenueFormState copyWith({
    String? name,
    String? location,
    String? sport,
    double? pricePerSlot,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return VenueFormState(
      name: name ?? this.name,
      location: location ?? this.location,
      sport: sport ?? this.sport,
      pricePerSlot: pricePerSlot ?? this.pricePerSlot,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        name,
        location,
        sport,
        pricePerSlot,
        isLoading,
        isSuccess,
        errorMessage,
      ];
}
