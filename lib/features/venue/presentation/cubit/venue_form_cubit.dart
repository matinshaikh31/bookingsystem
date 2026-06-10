import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/venue_fb_repo.dart';
import '../../domain/models/venue_model.dart';
import 'venue_form_state.dart';

class VenueFormCubit extends Cubit<VenueFormState> {
  final VenueFbRepo venueFbRepo;

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final sportCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  VenueFormCubit({required this.venueFbRepo}) : super(VenueFormState.initial()) {
    nameCtrl.addListener(() => nameChanged(nameCtrl.text));
    locationCtrl.addListener(() => locationChanged(locationCtrl.text));
    sportCtrl.addListener(() => sportChanged(sportCtrl.text));
    priceCtrl.addListener(() {
      final p = double.tryParse(priceCtrl.text) ?? 0.0;
      priceChanged(p);
    });
  }

  void initializeForEdit(VenueModel venue) {
    nameCtrl.text = venue.name;
    locationCtrl.text = venue.location;
    sportCtrl.text = venue.sport;
    priceCtrl.text = venue.pricePerSlot.toStringAsFixed(0);

    emit(state.copyWith(
      name: venue.name,
      location: venue.location,
      sport: venue.sport,
      pricePerSlot: venue.pricePerSlot,
      isSuccess: false,
      errorMessage: null,
    ));
  }

  void nameChanged(String name) {
    emit(state.copyWith(name: name));
  }

  void locationChanged(String location) {
    emit(state.copyWith(location: location));
  }

  void sportChanged(String sport) {
    emit(state.copyWith(sport: sport));
  }

  void priceChanged(double price) {
    emit(state.copyWith(pricePerSlot: price));
  }

  Future<void> submitVenue({String? editId}) async {
    final name = nameCtrl.text.trim();
    final location = locationCtrl.text.trim();
    final sport = sportCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;

    if (name.isEmpty || location.isEmpty || sport.isEmpty || price < 0) {
      emit(state.copyWith(errorMessage: 'Please enter valid details for all fields.'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));

    try {
      final id = editId ?? DateTime.now().millisecondsSinceEpoch.toString();
      final venue = VenueModel(
        id: id,
        name: name,
        location: location,
        sport: sport,
        pricePerSlot: price,
        createdAt: DateTime.now(),
      );

      await venueFbRepo.saveVenue(venue);
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to save venue: $e'));
    }
  }

  Future<void> deleteVenue(String venueId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));
    try {
      await venueFbRepo.deleteVenue(venueId);
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to delete venue: $e'));
    }
  }

  @override
  Future<void> close() {
    nameCtrl.dispose();
    locationCtrl.dispose();
    sportCtrl.dispose();
    priceCtrl.dispose();
    return super.close();
  }
}
