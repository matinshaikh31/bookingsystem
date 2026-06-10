import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String venueId;
  final String venueName;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime date; // Day the booking is for
  final String slot; // e.g. "09:00-10:00"
  final String status; // confirmed | cancelled
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.date,
    required this.slot,
    required this.status,
    required this.createdAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BookingModel(
      id: doc.id,
      venueId: data['venueId'] ?? '',
      venueName: data['venueName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      slot: data['slot'] ?? '',
      status: data['status'] ?? 'confirmed',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'venueId': venueId,
    'venueName': venueName,
    'userId': userId,
    'userName': userName,
    'userEmail': userEmail,
    'date': Timestamp.fromDate(date),
    'slot': slot,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
