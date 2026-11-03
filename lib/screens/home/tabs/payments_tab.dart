import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_theme.dart';
import '../../../dependencies.dart';
import '../../../models/payment.dart';
import '../payment_detail_screen.dart';
import '../add_payment_screen.dart';

class PaymentsTab extends StatefulWidget {
  final String clientId;
  final bool isOwner;
  final VoidCallback onRefresh;

  const PaymentsTab({
    super.key,
    required this.clientId,
    required this.isOwner,
    required this.onRefresh,
  });

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  late Future<List<Payment>> _futurePayments;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _futurePayments = clientService.getPayments(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<Payment>>(
          future: _futurePayments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final payments = snapshot.data ?? [];
            if (payments.isEmpty) {
              return Center(
                child: Text(
                  'No payments yet.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _load(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: payments.length,
                itemBuilder: (context, i) {
                  final p = payments[i];
                  final fmt = NumberFormat.simpleCurrency(name: p.currency);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.success,
                        child: Icon(
                          Icons.attach_money,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        fmt.format(p.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${DateFormat('MMM d, yyyy').format(p.date)} • ${p.method ?? "Unknown"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      onTap: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentDetailScreen(
                              payment: p,
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
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPaymentScreen(clientId: widget.clientId),
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
