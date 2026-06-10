import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bookingsystem/core/service/firebase.dart';
import 'package:bookingsystem/features/auth/domain/entity/auth_repo.dart';
import 'package:bookingsystem/features/auth/domain/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AuthCubit({required this.authRepo}) : super(AuthState.initial());

  StreamSubscription<bool>? authStream;

  // Login controllers
  final loginFormKey = GlobalKey<FormState>();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // Signup controllers
  final signupFormKey = GlobalKey<FormState>();
  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();

  void checkAuth() {
    authStream = authRepo.authStateChanges().listen((isAuthenticated) async {
      if (isAuthenticated) {
        final uid = FBAuth.auth.currentUser?.uid;
        final userData = uid != null ? await authRepo.getUserData(uid) : null;
        emit(
          state.copyWith(
            isAuthenticated: true,
            currentUser: userData,
            isCheckingAuth: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isAuthenticated: false,
            currentUser: null,
            isCheckingAuth: false,
          ),
        );
      }
    });
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> login() async {
    if (loginFormKey.currentState?.validate() ?? false) {
      try {
        emit(state.copyWith(isLoading: true));

        final email = loginEmailController.text.trim().toLowerCase();
        final password = loginPasswordController.text;

        await authRepo.login(email, password);

        final uid = FBAuth.auth.currentUser?.uid;
        final userData = uid != null ? await authRepo.getUserData(uid) : null;
        emit(
          state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            message: null,
            currentUser: userData,
          ),
        );
      } catch (e) {
        debugPrint('AuthCubit.login error: $e');
        emit(
          state.copyWith(
            isLoading: false,
            message: _getErrorMessage(e.toString()),
            isAuthenticated: false,
          ),
        );
      }
    }
  }

  Future<void> signup() async {
    if (signupFormKey.currentState?.validate() ?? false) {
      try {
        emit(state.copyWith(isLoading: true));

        final email = signupEmailController.text.trim().toLowerCase();
        final password = signupPasswordController.text;
        final name = signupNameController.text.trim();

        await authRepo.signup(email, password, name);

        final uid = FBAuth.auth.currentUser?.uid;
        final userData = uid != null ? await authRepo.getUserData(uid) : null;
        emit(
          state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            message: null,
            currentUser: userData,
          ),
        );
      } catch (e) {
        debugPrint('AuthCubit.signup error: $e');
        emit(
          state.copyWith(
            isLoading: false,
            message: _getErrorMessage(e.toString()),
            isAuthenticated: false,
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    try {
      emit(state.copyWith(isLoading: true));
      await authRepo.logout();

      loginEmailController.clear();
      loginPasswordController.clear();
      signupNameController.clear();
      signupEmailController.clear();
      signupPasswordController.clear();

      emit(
        AuthState.initial().copyWith(
          isAuthenticated: false,
          currentUser: null,
          isCheckingAuth: false,
        ),
      );
    } catch (e) {
      debugPrint('AuthCubit.logout error: $e');
      emit(
        state.copyWith(
          isLoading: false,
          message: _getErrorMessage(e.toString()),
        ),
      );
    }
  }

  void clearMessage() {
    emit(state.copyWith(message: null));
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No user found with this email';
    } else if (error.contains('wrong-password')) {
      return 'Wrong password';
    } else if (error.contains('invalid-credential')) {
      return 'Invalid email or password';
    } else if (error.contains('email-already-in-use')) {
      return 'Email already in use';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    }
    if (error.contains('] ')) {
      return error.split('] ').last;
    }
    return 'An error occurred: $error';
  }

  @override
  Future<void> close() {
    authStream?.cancel();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    return super.close();
  }
}
