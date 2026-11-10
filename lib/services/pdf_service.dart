import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/client.dart';
import '../models/project.dart';
import '../models/payment.dart';

class PdfService {
  static Future<void> generateAndShareInvoice({
    required Client client,
    required List<Project> projects,
    required List<Payment> payments,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ARDOISE',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Financial Invoice',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      DateFormat('MMMM d, yyyy').format(DateTime.now()),
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Client: ${client.companyName}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 32),
            pw.Divider(),
            pw.SizedBox(height: 16),

            // Summary
            pw.Text(
              'Financial Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryBox(
                  'Total Budget',
                  NumberFormat.simpleCurrency(name: client.currency)
                      .format(client.totalBudget),
                ),
                _buildSummaryBox(
                  'Total Paid',
                  NumberFormat.simpleCurrency(name: client.currency)
                      .format(client.totalPaid),
                ),
                _buildSummaryBox(
                  'Balance',
                  NumberFormat.simpleCurrency(name: client.currency)
                      .format(client.balance),
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // Projects Table
            if (projects.isNotEmpty) ...[
              pw.Text(
                'Projects',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['Project Name', 'Status', 'Budget'],
                data: projects
                    .map(
                      (p) => [
                        p.name,
                        p.status,
                        NumberFormat.simpleCurrency(name: p.currency)
                            .format(p.budget),
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellPadding: const pw.EdgeInsets.all(8),
              ),
              pw.SizedBox(height: 24),
            ],

            // Payments Table
            if (payments.isNotEmpty) ...[
              pw.Text(
                'Payments',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Method', 'Amount'],
                data: payments
                    .map(
                      (p) => [
                        DateFormat('MMM d, yyyy').format(p.date),
                        p.method ?? 'Unknown',
                        NumberFormat.simpleCurrency(name: p.currency)
                            .format(p.amount),
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellPadding: const pw.EdgeInsets.all(8),
              ),
            ],
          ];
        },
        footer: (pw.Context context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Divider(),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generated by Ardoise • ${DateTime.now().year}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey500,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Share/Print the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          '${client.companyName}_Invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static pw.Widget _buildSummaryBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
