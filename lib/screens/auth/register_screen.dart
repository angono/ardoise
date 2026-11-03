import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../dependencies.dart';
import '../home/main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.length < 6) {
      setState(() => _error = 'Please fill all fields (password min 6 chars)');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final user = await authService.register(
      _email.text.trim(),
      _password.text,
      _name.text.trim(),
    );
    if (!mounted) return;

    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Registration failed. Email might be in use.';
      });
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              style: TextStyle(color: AppColors.textMain), // Fixed dark mode
              decoration: InputDecoration(
                labelText: 'Full Name / Company Name',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppColors.textMuted,
                ), // Fixed icon
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              style: TextStyle(color: AppColors.textMain), // Fixed dark mode
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppColors.textMuted,
                ), // Fixed icon
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              style: TextStyle(color: AppColors.textMain), // Fixed dark mode
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AppColors.textMuted,
                ), // Fixed icon
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Register', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
