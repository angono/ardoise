import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../dependencies.dart';
import '../../models/client.dart';
import '../../widgets/global_analytics_card.dart';
import 'client_dashboard_screen.dart';
import 'create_client_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Client>? _clients;
  bool _isLoading = true;
  String? _error;

  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() => _error = null);
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final data = await clientService.getMyClients();
      if (mounted) {
        setState(() {
          _clients = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: AppColors.textMain,
                ), // Fix dark mode text
                decoration: InputDecoration(
                  hintText: 'Search clients...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ardoise',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Hello, ${user?.fullName ?? "User"}',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.appBarText,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      floatingActionButton: _isSearching
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateClientScreen()),
                );
                if (created == true) _loadClients(isRefresh: true);
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Client'),
            ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.danger),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _loadClients(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final allClients = _clients ?? [];

    final filteredClients = allClients.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.companyName.toLowerCase().contains(_searchQuery) ||
          c.description.toLowerCase().contains(_searchQuery);
    }).toList();

    if (allClients.isEmpty && !_isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'You have no clients yet.\nTap "New Client" to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadClients(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: filteredClients.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return GlobalAnalyticsCard(clients: allClients);
          }

          final c = filteredClients[i - 1];
          final fmt = NumberFormat.simpleCurrency(name: c.currency);

          // DYNAMIC BADGE COLORS (Fixing dark mode visibility)
          final badgeBgColor = c.isOwner
              ? AppColors.primaryLight.withValues(alpha: 0.15)
              : (AppColors.isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200);
          final badgeTextColor = c.isOwner
              ? (AppColors.isDark ? Colors.white : AppColors.primary)
              : (AppColors.isDark ? Colors.white70 : Colors.black87);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientDashboardScreen(client: c),
                    ),
                  );
                  _loadClients(isRefresh: true);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              c.companyName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    AppColors.textMain, // Fixed dark mode text
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              c.isOwner ? 'Owner' : 'Client',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (c.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          c.description,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      Divider(height: 24, color: AppColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStat(
                            'Budget',
                            fmt.format(c.totalBudget),
                            AppColors.textMain, // Fixed dark mode text
                          ),
                          _buildStat(
                            'Paid',
                            fmt.format(c.totalPaid),
                            AppColors.success,
                          ),
                          _buildStat(
                            'Balance',
                            fmt.format(c.balance),
                            c.balance > 0
                                ? AppColors.danger
                                : AppColors.textMain, // Fixed dark mode text
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
