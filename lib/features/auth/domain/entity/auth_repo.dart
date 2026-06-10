import '../models/user_model.dart';

abstract class AuthRepo {
  Stream<bool> authStateChanges();
  Future<UserModel?> getUserData(String uid);
  Future<void> createUserData(UserModel user);
  Future<void> login(String email, String password);
  Future<void> signup(String email, String password, String name);
  Future<void> logout();
}
