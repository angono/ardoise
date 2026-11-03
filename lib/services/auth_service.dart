import '../models/app_user.dart';

abstract class AuthService {
  AppUser? get currentUser;
  Future<AppUser?> login(String email, String password);
  Future<AppUser?> register(String email, String password, String fullName);
  Future<void> logout();
  Future<AppUser?> restoreSession();

  Future<void> updateProfile({required String fullName});
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
