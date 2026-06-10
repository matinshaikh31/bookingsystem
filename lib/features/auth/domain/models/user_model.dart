import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/const/role.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final bool isDeleted;
  final String role;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.isDeleted = false,
    this.role = Roles.user,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['isDeleted'] ?? false,
      role: data['role'] ?? Roles.user,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
                ? (map['createdAt'] as Timestamp).toDate()
                : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      isDeleted: map['isDeleted'] ?? false,
      role: map['role'] ?? Roles.user,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDeleted': isDeleted,
      'role': role,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    DateTime? createdAt,
    bool? isDeleted,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      role: role ?? this.role,
    );
  }
}
