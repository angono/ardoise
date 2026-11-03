import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../dependencies.dart';
import '../../models/project.dart';
import 'add_project_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;
  final bool isOwner;
  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.isOwner,
  });

  Future<void> _deleteProject(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text(
          'Are you sure you want to delete "${project.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await clientService.deleteProject(project.id);
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.simpleCurrency(name: project.currency);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddProjectScreen(
                      clientId: project.id,
                      project: project,
                    ),
                  ),
                );
                if (updated == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () => _deleteProject(context),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            project.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain, // Fixed dark mode text
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(project.status)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  project.status,
                  style: TextStyle(
                    color: _getStatusColor(project.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            fmt.format(project.budget),
            style: const TextStyle(
              fontSize: 28,
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(height: 32, color: AppColors.border), // Fixed divider
          Text(
            'Description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project.description.isEmpty
                ? 'No description provided.'
                : project.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.textMain, // Fixed dark mode text
            ),
          ),
          if (project.url != null && project.url!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Link',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              project.url!,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
