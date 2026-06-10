import 'package:cloud_firestore/cloud_firestore.dart';

class VenueModel {
  final String id;
  final String name;
  final String location;
  final String sport;
  final double pricePerSlot;
  final DateTime createdAt;
  final bool isActive;

  const VenueModel({
    required this.id,
    required this.name,
    required this.location,
    required this.sport,
    required this.pricePerSlot,
    required this.createdAt,
    this.isActive = true,
  });

  factory VenueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return VenueModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      sport: data['sport'] ?? '',
      pricePerSlot: (data['pricePerSlot'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'location': location,
    'sport': sport,
    'pricePerSlot': pricePerSlot,
    'createdAt': Timestamp.fromDate(createdAt),
    'isActive': isActive,
  };
}
