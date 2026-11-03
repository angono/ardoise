import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'auth_service.dart';

class SupabaseAuthService implements AuthService {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  Future<AppUser> _fetchProfile(String userId) async {
    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return AppUser(
      id: profile['id'] as String,
      email: profile['email'] as String? ?? '',
      fullName: profile['full_name'] as String? ?? 'Utilisateur',
    );
  }

  @override
  Future<AppUser?> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) return null;
      _currentUser = await _fetchProfile(response.user!.id);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AppUser?> register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        // This metadata is read by our SQL trigger to create the profile
        data: {'full_name': fullName},
      );
      if (response.user == null) return null;

      _currentUser = await _fetchProfile(response.user!.id);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
    _currentUser = null;
  }

  @override
  Future<AppUser?> restoreSession() async {
    final session = _client.auth.currentSession;
    if (session?.user == null) return null;
    try {
      _currentUser = await _fetchProfile(session!.user.id);
      return _currentUser;
    } catch (_) {
      await _client.auth.signOut();
      return null;
    }
  }

    @override
  Future<void> updateProfile({required String fullName}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    await _client
        .from('profiles')
        .update({'full_name': fullName})
        .eq('id', userId);

    // Update local cache
    if (_currentUser != null) {
      _currentUser = AppUser(
        id: _currentUser!.id,
        email: _currentUser!.email,
        fullName: fullName,
      );
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final email = _client.auth.currentUser?.email;
    if (email == null) throw Exception('Not logged in');

    // Verify old password by attempting to sign in
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );
    } catch (e) {
      throw Exception('Incorrect old password.');
    }

    // Update password
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}
