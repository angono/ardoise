import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../dependencies.dart';
import '../../models/payment.dart';
import 'add_payment_screen.dart';

class PaymentDetailScreen extends StatelessWidget {
  final Payment payment;
  final bool isOwner;
  const PaymentDetailScreen({
    super.key,
    required this.payment,
    required this.isOwner,
  });

  Future<void> _deletePayment(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Payment?'),
        content: const Text(
          'Are you sure you want to delete this payment record? This action cannot be undone.',
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
      await clientService.deletePayment(payment.id);
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.simpleCurrency(name: payment.currency);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        actions: [
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPaymentScreen(
                      clientId: payment.id,
                      payment: payment,
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
              onPressed: () => _deletePayment(context),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            fmt.format(payment.amount),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMMM d, yyyy').format(payment.date),
            style: TextStyle(fontSize: 16, color: AppColors.textMuted),
          ),
          Divider(height: 32, color: AppColors.border), // Fixed divider
          _buildRow('Payment Method', payment.method ?? 'Unknown'),
          const SizedBox(height: 24),
          _buildRow(
            'Description',
            payment.description?.isNotEmpty == true
                ? payment.description!
                : 'No description provided.',
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppColors.textMain, // Fixed dark mode text
          ),
        ),
      ],
    );
  }
}
