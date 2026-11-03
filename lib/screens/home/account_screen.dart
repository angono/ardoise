import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/theme_service.dart';
import '../../dependencies.dart';
import '../auth/welcome_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    // Choose a visible icon color for both themes
    final iconColor = AppColors.isDark
        ? Colors.white70
        : AppColors.primaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user?.fullName ?? 'User',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),
          Center(
            child: Text(
              user?.email ?? '',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 32),
          Divider(height: 1, color: AppColors.border), // Added border color
          ListTile(
            leading: Icon(Icons.edit, color: iconColor),
            title: Text(
              'Edit Profile',
              style: TextStyle(color: AppColors.textMain),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textMuted,
            ),
            onTap: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              if (updated == true) setState(() {});
            },
          ),
          ListTile(
            leading: Icon(Icons.lock_outline, color: iconColor),
            title: Text(
              'Change Password',
              style: TextStyle(color: AppColors.textMain),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textMuted,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          // --- DARK MODE TOGGLE ---
          SwitchListTile(
            secondary: Icon(Icons.dark_mode_outlined, color: iconColor),
            title: Text(
              'Dark Mode',
              style: TextStyle(color: AppColors.textMain),
            ),
            value: AppColors.isDark,
            activeThumbColor: AppColors.primary,
            onChanged: (value) async {
              await ThemeService.toggleTheme(value);
              setState(() {});
            },
          ),
          Divider(height: 1, color: AppColors.border), // Added border color
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.danger),
            ),
            onTap: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
