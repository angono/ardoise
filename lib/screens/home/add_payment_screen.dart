import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../core/app_constants.dart';
import '../../dependencies.dart';
import '../../models/payment.dart';

class AddPaymentScreen extends StatefulWidget {
  final String clientId;
  final Payment? payment;
  const AddPaymentScreen({super.key, required this.clientId, this.payment});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amount;
  late final TextEditingController _desc;
  late DateTime _date;

  String _selectedCurrency = 'EUR';
  String _selectedMethod = 'Bank Transfer';
  bool _loading = false;

  bool get isEditing => widget.payment != null;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: widget.payment?.amount.toString() ?? '',
    );
    _desc = TextEditingController(text: widget.payment?.description ?? '');
    _date = widget.payment?.date ?? DateTime.now();
    _selectedCurrency = widget.payment?.currency ?? 'EUR';
    _selectedMethod = widget.payment?.method ?? 'Bank Transfer';
  }

  @override
  void dispose() {
    _amount.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (isEditing) {
        await clientService.updatePayment(
          paymentId: widget.payment!.id,
          amount: double.tryParse(_amount.text) ?? 0.0,
          currency: _selectedCurrency,
          date: _date,
          method: _selectedMethod,
          description: _desc.text.trim(),
        );
      } else {
        await clientService.addPayment(
          clientId: widget.clientId,
          amount: double.tryParse(_amount.text) ?? 0.0,
          currency: _selectedCurrency,
          date: _date,
          method: _selectedMethod,
          description: _desc.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Payment' : 'Log Payment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amount,
                    style: TextStyle(color: AppColors.textMain), // Fixed
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final val = double.tryParse(v);
                      if (val == null || val <= 0) return 'Invalid amount';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCurrency,
                    style: TextStyle(color: AppColors.textMain), // Fixed
                    dropdownColor: AppColors.surface, // Fixed
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: AppConstants.currencies
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.code,
                            child: Text(c.code),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCurrency = v ?? 'EUR'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedMethod,
              style: TextStyle(color: AppColors.textMain), // Fixed
              dropdownColor: AppColors.surface, // Fixed
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.paymentMethods
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedMethod = v ?? 'Bank Transfer'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _desc,
              style: TextStyle(color: AppColors.textMain), // Fixed
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              title: Text(
                'Transaction Date',
                style: TextStyle(color: AppColors.textMain), // Fixed
              ),
              subtitle: Text(
                DateFormat('MMMM d, yyyy').format(_date),
                style: TextStyle(color: AppColors.textMuted), // Fixed
              ),
              trailing: Icon(
                Icons.calendar_today,
                color: AppColors.primaryLight, // Fixed visibility
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'Update Payment' : 'Record Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
