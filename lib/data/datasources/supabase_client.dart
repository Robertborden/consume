import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/api_constants.dart';

/// Singleton wrapper for Supabase client
class SupabaseClientWrapper {
  static SupabaseClientWrapper? _instance;
  static SupabaseClient? _client;

  SupabaseClientWrapper._();

  static SupabaseClientWrapper get instance {
    _instance ??= SupabaseClientWrapper._();
    return _instance!;
  }

  /// Initialize Supabase - call this in main.dart before runApp
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
    _client = Supabase.instance.client;
  }

  /// Get the Supabase client instance
  SupabaseClient get client {
    if (_client == null) {
      throw StateError(
        'Supabase has not been initialized. Call SupabaseClientWrapper.initialize() first.',
      );
    }
    return _client!;
  }

  /// Get the current user
  User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
  }

  /// Sign in with OAuth provider
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    return await client.auth.signInWithOAuth(
      provider,
      redirectTo: 'io.supabase.consume://login-callback/',
    );
  }

  /// Sign in with Apple
  Future<AuthResponse> signInWithApple() async {
    return await client.auth.signInWithApple();
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.consume://reset-password/',
    );
  }

  /// Update user metadata
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> data) async {
    return await client.auth.updateUser(
      UserAttributes(data: data),
    );
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    // This requires a server-side function or admin API
    // For now, we'll call a Supabase Edge Function
    await client.functions.invoke('delete-user-account');
  }
}
