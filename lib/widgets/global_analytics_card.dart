import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../models/client.dart';

class GlobalAnalyticsCard extends StatelessWidget {
  final List<Client> clients;

  const GlobalAnalyticsCard({super.key, required this.clients});

  @override
  Widget build(BuildContext context) {
    // 1. Group the totals by currency
    final Map<String, Map<String, double>> groupedTotals = {};

    for (var c in clients) {
      groupedTotals.putIfAbsent(
        c.currency,
        () => {'budget': 0.0, 'paid': 0.0, 'balance': 0.0},
      );

      groupedTotals[c.currency]!['budget'] =
          groupedTotals[c.currency]!['budget']! + c.totalBudget;
      groupedTotals[c.currency]!['paid'] =
          groupedTotals[c.currency]!['paid']! + c.totalPaid;
      groupedTotals[c.currency]!['balance'] =
          groupedTotals[c.currency]!['balance']! + c.balance;
    }

    // 2. Sort currencies by highest budget (so the most important is shown first)
    final sortedEntries = groupedTotals.entries.toList()
      ..sort((a, b) => b.value['budget']!.compareTo(a.value['budget']!));

    final primaryCurrency = sortedEntries.isNotEmpty
        ? sortedEntries.first
        : null;
    final otherCurrenciesCount = sortedEntries.length > 1
        ? sortedEntries.length - 1
        : 0;

    return GestureDetector(
      onTap: () {
        if (sortedEntries.isNotEmpty) {
          _showFullBreakdown(context, sortedEntries);
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Global Overview',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                if (otherCurrenciesCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '+$otherCurrenciesCount currencies',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 10,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (sortedEntries.isEmpty)
              const Text(
                'No financial data yet.',
                style: TextStyle(color: Colors.white70),
              )
            else
              _buildSingleCurrencyLayout(
                primaryCurrency!.key,
                primaryCurrency.value,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleCurrencyLayout(
    String currency,
    Map<String, double> totals,
  ) {
    final formatter = NumberFormat.simpleCurrency(
      name: currency,
      decimalDigits: 2,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem(
          'Total Budget',
          formatter.format(totals['budget']!),
          Colors.white,
        ),
        _buildStatItem(
          'Total Paid',
          formatter.format(totals['paid']!),
          const Color(0xFF10B981),
        ),
        _buildStatItem(
          'Balance',
          formatter.format(totals['balance']!),
          totals['balance']! > 0 ? const Color(0xFFF43F5E) : Colors.white,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- THE BOTTOM SHEET ---
  void _showFullBreakdown(
    BuildContext context,
    List<MapEntry<String, Map<String, double>>> sortedEntries,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border, // Fixed drag handle
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Financial Breakdown',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain, // Fixed dark mode title
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Totals grouped by currency across all your clients.',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              // Scrollable list for up to 8+ currencies
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sortedEntries.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 32,
                    color: AppColors.border,
                  ), // Fixed divider
                  itemBuilder: (context, index) {
                    final entry = sortedEntries[index];
                    final currency = entry.key;
                    final totals = entry.value;
                    final formatter = NumberFormat.simpleCurrency(
                      name: currency,
                      decimalDigits: 2,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  AppColors.primary, // Fixed background
                              child: Text(
                                currency.substring(0, 1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Fixed text visibility
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currency,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    AppColors.textMain, // Fixed dark mode text
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSheetStat(
                              'Budget',
                              formatter.format(totals['budget']!),
                              AppColors.textMain, // Fixed dark mode text
                            ),
                            _buildSheetStat(
                              'Paid',
                              formatter.format(totals['paid']!),
                              AppColors.success,
                            ),
                            _buildSheetStat(
                              'Balance',
                              formatter.format(totals['balance']!),
                              totals['balance']! > 0
                                  ? AppColors.danger
                                  : AppColors.textMain, // Fixed dark mode text
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetStat(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
