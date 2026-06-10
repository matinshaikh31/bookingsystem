import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/venue_fb_repo.dart';
import 'venue_state.dart';

class VenueCubit extends Cubit<VenueState> {
  final VenueFbRepo venueFbRepo;
  StreamSubscription? _venuesSub;

  final searchCtrl = TextEditingController();

  VenueCubit({required this.venueFbRepo}) : super(VenueState.initial()) {
    searchCtrl.addListener(() {
      setSearchQuery(searchCtrl.text);
    });
    _venuesSub = venueFbRepo.streamVenues().listen(
      (venues) {
        emit(state.copyWith(allVenues: venues, isLoading: false));
        _filterVenues();
      },
      onError: (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      },
    );
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query.trim().toLowerCase()));
    _filterVenues();
  }

  void setSelectedSport(String sport) {
    emit(state.copyWith(selectedSport: sport));
    _filterVenues();
  }

  void clearSearch() {
    searchCtrl.clear();
    emit(state.copyWith(searchQuery: ''));
    _filterVenues();
  }

  void _filterVenues() {
    final filtered = state.allVenues.where((v) {
      final matchesSearch = v.name.toLowerCase().contains(state.searchQuery) ||
          v.location.toLowerCase().contains(state.searchQuery);
      final matchesSport = state.selectedSport == 'All' ||
          v.sport.toLowerCase() == state.selectedSport.toLowerCase();
      return matchesSearch && matchesSport;
    }).toList();

    emit(state.copyWith(filteredVenues: filtered));
  }

  @override
  Future<void> close() {
    _venuesSub?.cancel();
    searchCtrl.dispose();
    return super.close();
  }
}
