import '../../../../core/service/firebase.dart';
import '../domain/models/venue_model.dart';

class VenueFbRepo {
  const VenueFbRepo();

  Stream<List<VenueModel>> streamVenues() {
    return FBFireStore.venues
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => VenueModel.fromFirestore(doc)).toList();
    });
  }

  Stream<VenueModel?> streamVenue(String id) {
    return FBFireStore.venues.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return VenueModel.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> saveVenue(VenueModel venue) async {
    await FBFireStore.venues.doc(venue.id).set(venue.toFirestore());
  }

  Future<void> deleteVenue(String id) async {
    await FBFireStore.venues.doc(id).delete();
  }
}
