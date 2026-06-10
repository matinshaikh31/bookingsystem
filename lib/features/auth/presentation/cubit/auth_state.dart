part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final String? message;
  final bool isLoading;
  final bool isPasswordVisible;
  final UserModel? currentUser;
  final bool isCheckingAuth;

  const AuthState({
    required this.isAuthenticated,
    this.message,
    required this.isLoading,
    required this.isPasswordVisible,
    this.currentUser,
    required this.isCheckingAuth,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      message: null,
      isLoading: false,
      isPasswordVisible: false,
      currentUser: null,
      isCheckingAuth: true,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    String? message,
    bool? isLoading,
    bool? isPasswordVisible,
    UserModel? currentUser,
    bool? isCheckingAuth,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      message: message,
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      currentUser: currentUser ?? this.currentUser,
      isCheckingAuth: isCheckingAuth ?? this.isCheckingAuth,
    );
  }

  @override
  List<Object?> get props => [
    isAuthenticated,
    message,
    isLoading,
    isPasswordVisible,
    currentUser,
    isCheckingAuth,
  ];
}
