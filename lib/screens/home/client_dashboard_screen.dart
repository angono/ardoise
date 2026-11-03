import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../dependencies.dart';
import '../../models/client.dart';
import 'edit_client_screen.dart';
import 'tabs/projects_tab.dart';
import 'tabs/payments_tab.dart';
import 'tabs/access_tab.dart';
import '../../services/pdf_service.dart';

class ClientDashboardScreen extends StatefulWidget {
  final Client client;
  const ClientDashboardScreen({super.key, required this.client});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  // 👇 NEW: state for the collapsible description
  bool _descriptionExpanded = false;

  // Show "Read more" when the description is longer than this.
  // Tweak if you want a different cutoff.
  static const int _descriptionCollapseThreshold = 100;

  bool get _hasLongDescription =>
      widget.client.description.length > _descriptionCollapseThreshold;

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.client.isOwner;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.client.companyName),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Generate Invoice',
              onPressed: () => _generatePdf(),
            ),
            if (isOwner)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditClientScreen(client: widget.client),
                    ),
                  );
                  if (result == 'deleted' && context.mounted) {
                    Navigator.pop(context, true);
                  } else if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
          ],
          bottom: TabBar(
            labelColor: AppColors.appBarText,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.appBarText,
            tabs: const [
              Tab(text: 'Projects'),
              Tab(text: 'Payments'),
              Tab(text: 'Access'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                children: [
                  ProjectsTab(
                    clientId: widget.client.id,
                    isOwner: isOwner,
                    onRefresh: _refreshDashboard,
                  ),
                  PaymentsTab(
                    clientId: widget.client.id,
                    isOwner: isOwner,
                    onRefresh: _refreshDashboard,
                  ),
                  AccessTab(
                    client: widget.client,
                    isOwner: isOwner,
                    onRefresh: _refreshDashboard,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshDashboard() {
    setState(() {});
  }

  Future<void> _generatePdf() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final projects = await clientService.getProjects(widget.client.id);
      final payments = await clientService.getPayments(widget.client.id);

      if (!mounted) return;
      Navigator.pop(context);

      await PdfService.generateAndShareInvoice(
        client: widget.client,
        projects: projects,
        payments: payments,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
    }
  }

  Widget _buildHeader() {
    final description = widget.client.description;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty) ...[
            // 👇 Clamp to 2 lines when collapsed
            Text(
              description,
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              maxLines: _descriptionExpanded ? null : 2,
              overflow: _descriptionExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            // 👇 Show toggle only if there's a lot of text
            if (_hasLongDescription)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _descriptionExpanded = !_descriptionExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _descriptionExpanded ? 'Show less' : 'Read more',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.appBarText,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                'Budget',
                NumberFormat.simpleCurrency(name: widget.client.currency)
                    .format(widget.client.totalBudget),
                AppColors.textMain,
              ),
              _buildStat(
                'Paid',
                NumberFormat.simpleCurrency(name: widget.client.currency)
                    .format(widget.client.totalPaid),
                AppColors.success,
              ),
              _buildStat(
                'Balance',
                NumberFormat.simpleCurrency(name: widget.client.currency)
                    .format(widget.client.balance),
                widget.client.balance > 0
                    ? AppColors.danger
                    : AppColors.textMain,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
