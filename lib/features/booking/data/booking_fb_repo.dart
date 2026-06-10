import 'package:bookingsystem/features/booking/domain/models/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/helpers/date_helper.dart';
import '../../../../core/service/firebase.dart';

class BookingFbRepo {
  const BookingFbRepo();

  Stream<List<BookingModel>> streamVenueBookings(String venueId) {
    return FBFireStore.bookings
        .where('venueId', isEqualTo: venueId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<BookingModel>> streamUserBookings(
    String userId, {
    DateTime? filterDate,
  }) {
    Query query = FBFireStore.bookings.where('userId', isEqualTo: userId);

    if (filterDate != null) {
      final normalizedDate = DateTime(
        filterDate.year,
        filterDate.month,
        filterDate.day,
      );
      query = query.where(
        'date',
        isEqualTo: Timestamp.fromDate(normalizedDate),
      );
    } else {
      query = query.orderBy('date', descending: true).limit(10);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> createBookings(List<BookingModel> bookings) async {
    await FBFireStore.fb.runTransaction((transaction) async {
      // 1. Read all documents first to satisfy Firestore transaction rules
      final Map<DocumentReference, DocumentSnapshot> snapshots = {};
      for (final booking in bookings) {
        final dateStr = DateHelper.formatToYmd(booking.date);
        final docId =
            '${booking.venueId}_${dateStr}_${booking.slot.replaceAll(':', '-').replaceAll(' ', '_')}';
        final docRef = FBFireStore.bookings.doc(docId);
        final snapshot = await transaction.get(docRef);
        snapshots[docRef] = snapshot;
      }

      // 2. Check for conflicts
      for (final entry in snapshots.entries) {
        final snapshot = entry.value;
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>?;
          if (data != null && data['status'] == 'confirmed') {
            final slotName = data['slot'] ?? 'Unknown Slot';
            throw Exception(
              'Slot "$slotName" is already booked by another user.',
            );
          }
        }
      }

      // 3. Set the booking documents
      for (final booking in bookings) {
        final dateStr = DateHelper.formatToYmd(booking.date);
        final docId =
            '${booking.venueId}_${dateStr}_${booking.slot.replaceAll(':', '-').replaceAll(' ', '_')}';
        final docRef = FBFireStore.bookings.doc(docId);
        final finalBooking = BookingModel(
          id: docRef.id,
          venueId: booking.venueId,
          venueName: booking.venueName,
          userId: booking.userId,
          userName: booking.userName,
          userEmail: booking.userEmail,
          date: booking.date,
          slot: booking.slot,
          status: booking.status,
          createdAt: booking.createdAt,
        );
        transaction.set(docRef, finalBooking.toFirestore());
      }
    });
  }

  Future<void> cancelBooking(String bookingId) async {
    await FBFireStore.bookings.doc(bookingId).update({'status': 'cancelled'});
  }
}
