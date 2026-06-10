/// Holds the auth session info after login
class AuthModel {
  final String name;
  final String email;
  final String phone;

  const AuthModel({
    required this.name,
    required this.email,
    required this.phone,
  });
}
