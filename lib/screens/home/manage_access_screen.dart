import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_theme.dart';
import '../../dependencies.dart';
import '../../models/client.dart';
import '../../models/app_user.dart';

class ManageAccessScreen extends StatefulWidget {
  final Client client;
  const ManageAccessScreen({super.key, required this.client});

  @override
  State<ManageAccessScreen> createState() => _ManageAccessScreenState();
}

class _ManageAccessScreenState extends State<ManageAccessScreen> {
  bool _loading = true;
  bool _saving = false;
  List<AppUser> _allUsers = [];
  Set<String> _selectedUserIds = {};
  String _ownerId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final users = await clientService.getAllUsers();
      final currentAccess = await Supabase.instance.client
          .from('client_access')
          .select('user_id, role')
          .eq('client_id', widget.client.id);

      final accessList = currentAccess as List;
      final ownerRow = accessList
          .where((r) => r['role'] == 'owner')
          .firstOrNull;

      if (!mounted) return;
      setState(() {
        _allUsers = users;
        _ownerId = ownerRow != null ? ownerRow['user_id'] : '';
        _selectedUserIds = accessList
            .map((r) => r['user_id'] as String)
            .toSet();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final idsToSync = _selectedUserIds.where((id) => id != _ownerId).toList();
      await clientService.syncAccessList(
        clientId: widget.client.id,
        userIdsToKeep: idsToSync,
        grantedByUserId: authService.currentUser!.id,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the correct visible color for the "(Owner)" text
    final ownerTextColor = AppColors.isDark
        ? Colors.white70
        : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Access'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Client: ${widget.client.companyName}',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _allUsers.length,
                    itemBuilder: (context, i) {
                      final user = _allUsers[i];
                      final isOwner = user.id == _ownerId;
                      final isSelected = _selectedUserIds.contains(user.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: isOwner
                            ? null
                            : (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedUserIds.add(user.id);
                                  } else {
                                    _selectedUserIds.remove(user.id);
                                  }
                                });
                              },
                        activeColor: AppColors.primary,
                        checkColor: Colors.white,
                        title: Row(
                          children: [
                            Text(
                              user.fullName,
                              style: TextStyle(
                                color:
                                    AppColors.textMain, // Fixed dark mode text
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isOwner) ...[
                              const SizedBox(width: 8),
                              Text(
                                '(Owner)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ownerTextColor, // Fixed dark mode text
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          user.email,
                          style: TextStyle(
                            color: AppColors.textMuted,
                          ), // Fixed dark mode text
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
