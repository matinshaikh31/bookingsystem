/// Holds the auth session info after login
class AuthModel {
  final String name;
  final String email;
  final String phone;
  final String token;

  const AuthModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.token,
  });

  /// Dummy logged-in user
  factory AuthModel.dummy() => const AuthModel(
    name: 'Aarav Sharma',
    email: 'aarav.sharma@gmail.com',
    phone: '+91 98765 43210',
    token: 'dummy_token_abc123',
  );
}
