import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_theme.dart';
import '../../../dependencies.dart';
import '../../../models/project.dart';
import '../project_detail_screen.dart';
import '../add_project_screen.dart';

class ProjectsTab extends StatefulWidget {
  final String clientId;
  final bool isOwner;
  final VoidCallback onRefresh;

  const ProjectsTab({
    super.key,
    required this.clientId,
    required this.isOwner,
    required this.onRefresh,
  });

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  late Future<List<Project>> _futureProjects;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _futureProjects = clientService.getProjects(widget.clientId);
    });
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
    return Stack(
      children: [
        FutureBuilder<List<Project>>(
          future: _futureProjects,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final projects = snapshot.data ?? [];
            if (projects.isEmpty) {
              return Center(
                child: Text(
                  'No projects yet.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _load(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: projects.length,
                itemBuilder: (context, i) {
                  final p = projects[i];
                  final fmt = NumberFormat.simpleCurrency(name: p.currency);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(
                        p.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(p.status)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                p.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(p.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Text(
                        fmt.format(p.budget),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.isDark
                              ? Colors.white
                              : AppColors.primaryLight, // FIXED
                        ),
                      ),
                      onTap: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectDetailScreen(
                              project: p,
                              isOwner: widget.isOwner,
                            ),
                          ),
                        );
                        if (updated == true) {
                          _load();
                          widget.onRefresh();
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (widget.isOwner)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddProjectScreen(clientId: widget.clientId),
                  ),
                );
                if (created == true) {
                  _load();
                  widget.onRefresh();
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}
