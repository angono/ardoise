import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_theme.dart';
import '../../../models/client.dart';
import '../manage_access_screen.dart';

class AccessTab extends StatelessWidget {
  final Client client;
  final bool isOwner;
  final VoidCallback onRefresh;

  const AccessTab({
    super.key,
    required this.client,
    required this.isOwner,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<dynamic>>(
          future: Supabase.instance.client
              .from('client_access')
              .select(
                'id, user_id, role, profiles!client_access_user_id_fkey(full_name, email)',
              )
              .eq('client_id', client.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.danger),
                ),
              );
            }

            final list = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final row = list[i];
                final profile = row['profiles'];
                final isOwnerRow = row['role'] == 'owner';

                final chipBgColor = isOwnerRow
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (AppColors.isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200);

                // FIXED: Owner text must be white in dark mode
                final chipTextColor = isOwnerRow
                    ? (AppColors.isDark ? Colors.white : AppColors.primaryLight)
                    : (AppColors.isDark ? Colors.white : Colors.black87);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isOwnerRow
                          ? AppColors.primary
                          : AppColors.primaryLight,
                      child: Text(
                        profile['full_name']?[0].toUpperCase() ?? '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      profile['full_name'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    subtitle: Text(
                      profile['email'] ?? '',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: chipBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isOwnerRow ? 'Owner' : 'Client',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: chipTextColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        if (isOwner)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageAccessScreen(client: client),
                  ),
                );
                if (updated == true) onRefresh();
              },
              child: const Icon(Icons.person_add),
            ),
          ),
      ],
    );
  }
}
