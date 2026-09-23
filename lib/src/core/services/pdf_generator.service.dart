import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_reload_system/src/core/data/model/Invoice_pdf_data.model.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/vendor.model.dart';

class InvoicePdfService {
  const InvoicePdfService();

  static final _accent = PdfColor.fromHex('#1E5EFF');
  static final _ink = PdfColor.fromHex('#1B1F2A');
  static final _muted = PdfColor.fromHex('#6B7280');
  static final _border = PdfColor.fromHex('#E5E7EB');
  static final _zebra = PdfColor.fromHex('#F7F8FA');

  Future<Uint8List> build(InvoicePdfData data) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );
    // For scripts Noto Sans doesn't cover (Sinhala, Tamil, Arabic, ...), bundle
    // that script's Noto font and add it here, e.g.
    // pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSansSinhala-Regular.ttf'))
    final fallback = <pw.Font>[];

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        fontFallback: fallback,
      ),
    );
    String money(double v) => '${data.currency}${v.toStringAsFixed(2)}';


    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${ctx.pageNumber} / ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ),
        build: (_) => [
          _header(data.vendor, data.clientEmail, data.clientPhone, data.clientName),
          pw.SizedBox(height: 24),
          _itemsTable(data, money),
          pw.SizedBox(height: 24),
          _bottom(data, money),
        ],
      ),
    );

    return doc.save();
  }

  /// Builds the PDF, writes it to the temporary directory (cleared by the OS,
  /// not visible in the user's files) and opens it in the system PDF viewer.
  Future<void> open(InvoicePdfData data) async {
    final bytes = await build(data);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);
    await _openFile(file);
  }

  static Future<void> _openFile(File file) async {
    final result = await OpenFile.open(file.path, type: 'application/pdf');
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }

  // ---------------------------------------------------------------- header

  pw.Widget _header(VendorModel vendor, String clientEmail, String clientPhone, String clientName) {

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _accent,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Text(
                vendor.vendorName,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 1),
              pw.Text(
                vendor.vendorEmail,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 1),
              pw.Text(
                vendor.vendorPhone,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'DATE',
                style: pw.TextStyle(color: PdfColors.blue100, fontSize: 8),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                _date(DateTime.now()),
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                clientName,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 1),
              pw.Text(
                clientEmail,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 1),
              pw.Text(
                clientPhone,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- items

  pw.Widget _itemsTable(InvoicePdfData data, String Function(double) money) {
    final rows = <List<String>>[];
    for (var i = 0; i < data.requests.length; i++) {
      final r = data.requests[i];
      rows.add([
        '${i + 1}',
        HelperFunctions.formatDateTime(r.activatedDate!),
        r.connectionModel?.connectionName ?? '-',
        r.connectionModel?.connectionNumber ?? '-',
        r.packageModel?.packageName ?? '-',
        money(InvoicePdfData.amountOf(r)),
      ]);
    }

    final alignments = {
      0: pw.Alignment.center,
      1: pw.Alignment.centerLeft,
      2: pw.Alignment.centerLeft,
      3: pw.Alignment.centerLeft,
      4: pw.Alignment.centerLeft,
      5: pw.Alignment.centerRight,
    };

    return pw.TableHelper.fromTextArray(
      headers: ['Item No', 'Date', 'Connection', 'Number', 'Package', 'Amount'],
      data: rows,
      columnWidths: {
        0: const pw.FixedColumnWidth(48),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2.2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2.4),
        5: const pw.FixedColumnWidth(80),
      },
      headerAlignments: alignments,
      cellAlignments: alignments,
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: pw.BoxDecoration(
        color: _ink,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      cellStyle: pw.TextStyle(color: _ink, fontSize: 10),
      oddRowDecoration: pw.BoxDecoration(color: _zebra),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _border, width: 0.5),
      ),
    );
  }

  // ---------------------------------------------------------------- bottom

  pw.Widget _bottom(InvoicePdfData data, String Function(double) money) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Last payment card
        if(data.vendor.lastPaidDate != null)...{
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _border),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LAST PAYMENT',
                    style: pw.TextStyle(
                      color: _muted,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  _row('Paid amount', money(data.vendor.lastPaidAmount ?? 0.0)),
                  _row('Paid date', _date(data.vendor.lastPaidDate)),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 20),
        },

        // Summary
        pw.SizedBox(
          width: 230,
          child: pw.Column(
            children: [
              _row('Subtotal', money(data.subtotal)),
              _row('Service charge(${data.getCommissionPercentage}%)', money(data.calCommission)),
              _row('Balance from last payment', money(data.vendor.currentPaymentBalance ?? 0.0)),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: _accent,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      money(data.total),
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: _muted, fontSize: 10)),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _date(DateTime? d) {
    if (d == null) return '-';
    return HelperFunctions.formatDateTime(d);
    // const months = [
    //   'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    //   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    // ];
    // return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }
}