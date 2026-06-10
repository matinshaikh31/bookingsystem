import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import '../../domain/entity/auth_repo.dart';
import '../../domain/models/user_model.dart';
import '../../../../core/service/firebase.dart';

class AuthRepoImpl implements AuthRepo {
  bool get _isFirebaseEnabled {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // In-Memory mock states if Firebase is absent
  static final StreamController<bool> _mockStream = StreamController<bool>.broadcast();
  static UserModel? _mockUser;
  static bool _mockIsLoggedIn = false;

  @override
  Stream<bool> authStateChanges() {
    if (_isFirebaseEnabled) {
      return FBAuth.auth.authStateChanges().map((user) => user != null);
    }
    Timer.run(() => _mockStream.add(_mockIsLoggedIn));
    return _mockStream.stream;
  }

  @override
  Future<UserModel?> getUserData(String uid) async {
    if (_isFirebaseEnabled) {
      final doc = await FBFireStore.users.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    }
    return _mockUser ??
        UserModel(
          uid: 'mock_uid',
          name: 'Demo User',
          email: 'demo@bookingsystem.com',
          createdAt: DateTime.now(),
        );
  }

  @override
  Future<void> createUserData(UserModel user) async {
    if (_isFirebaseEnabled) {
      await FBFireStore.users.doc(user.uid).set(user.toFirestore());
      return;
    }
    _mockUser = user;
  }

  @override
  Future<void> login(String email, String password) async {
    if (_isFirebaseEnabled) {
      await FBAuth.auth.signInWithEmailAndPassword(email: email, password: password);
      return;
    }
    _mockUser = UserModel(
      uid: 'mock_uid',
      name: email.split('@')[0],
      email: email,
      createdAt: DateTime.now(),
    );
    _mockIsLoggedIn = true;
    _mockStream.add(true);
  }

  @override
  Future<void> signup(String email, String password, String name) async {
    if (_isFirebaseEnabled) {
      final credential = await FBAuth.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid != null) {
        final newUser = UserModel(
          uid: uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );
        await createUserData(newUser);
      }
      return;
    }
    _mockUser = UserModel(
      uid: 'mock_uid',
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    _mockIsLoggedIn = true;
    _mockStream.add(true);
  }

  @override
  Future<void> logout() async {
    if (_isFirebaseEnabled) {
      await FBAuth.auth.signOut();
      return;
    }
    _mockUser = null;
    _mockIsLoggedIn = false;
    _mockStream.add(false);
  }
}
