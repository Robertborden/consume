import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_client.dart';

/// Provider for auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return SupabaseClientWrapper.instance.authStateChanges.map((state) => state.session?.user);
});

/// Provider for current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Provider for auth controller
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

/// Auth controller for handling authentication
class AuthController {
  final Ref _ref;
  
  AuthController(this._ref);
  
  SupabaseClientWrapper get _supabase => SupabaseClientWrapper.instance;
  
  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.signInWithEmail(
      email: email,
      password: password,
    );
  }
  
  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return await _supabase.signUpWithEmail(
      email: email,
      password: password,
      metadata: displayName != null ? {'display_name': displayName} : null,
    );
  }
  
  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    return await _supabase.signInWithOAuth(OAuthProvider.google);
  }
  
  /// Sign in with Apple
  Future<AuthResponse> signInWithApple() async {
    return await _supabase.signInWithApple();
  }
  
  /// Sign out
  Future<void> signOut() async {
    await _supabase.signOut();
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    await _supabase.resetPassword(email);
  }
}
