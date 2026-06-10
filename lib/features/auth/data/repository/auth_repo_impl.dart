import '../../domain/entity/auth_repo.dart';
import '../../domain/models/user_model.dart';
import '../../../../core/service/firebase.dart';

class AuthRepoImpl implements AuthRepo {
  @override
  Stream<bool> authStateChanges() {
    return FBAuth.auth.authStateChanges().map((user) => user != null);
  }

  @override
  Future<UserModel?> getUserData(String uid) async {
    final doc = await FBFireStore.users.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> createUserData(UserModel user) async {
    await FBFireStore.users.doc(user.uid).set(user.toFirestore());
  }

  @override
  Future<void> login(String email, String password) async {
    await FBAuth.auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signup(String email, String password, String name) async {
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
  }

  @override
  Future<void> logout() async {
    await FBAuth.auth.signOut();
  }
}
