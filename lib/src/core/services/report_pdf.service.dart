import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_reload_system/src/core/utils/report_format.util.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_summary.entity.dart';

/// Builds the vendor report as a PDF. Same fonts, colours and look as the
/// invoice PDF.
class ReportPdfService {
  const ReportPdfService();

  static final _accent = PdfColor.fromHex('#1E5EFF');
  static final _ink = PdfColor.fromHex('#1B1F2A');
  static final _muted = PdfColor.fromHex('#6B7280');
  static final _border = PdfColor.fromHex('#E5E7EB');
  static final _zebra = PdfColor.fromHex('#F7F8FA');
  static final _good = PdfColor.fromHex('#1E8E3E');
  static final _bad = PdfColor.fromHex('#D93025');

  Future<Uint8List> build({
    required ReportSummaryEntity summary,
    required String vendorName,
  }) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${ctx.pageNumber} / ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ),
        build: (_) => [
          _header(summary, vendorName),
          pw.SizedBox(height: 18),
          _kpis(summary),
          pw.SizedBox(height: 22),
          _section('Sales trend', _trend(summary.trend)),
          _section('Sales by provider',
              _breakdownTable(summary.providers, 'Provider')),
          _section('Top packages',
              _breakdownTable(summary.topPackages, 'Package')),
          _section('Unpaid ageing', _agingTable(summary.aging)),
          _section('Who to chase', _unpaidTable(summary.topUnpaid)),
          _section('Expiring in the next 7 days',
              _expiringTable(summary.expiring)),
        ],
      ),
    );

    return doc.save();
  }

  // ------------------------------------------------------------------ header

  pw.Widget _header(ReportSummaryEntity s, String vendorName) {
    final p = s.period;
    final lastDay = DateTime(p.to.year, p.to.month, p.to.day - 1);
    final range = p.days == 1
        ? formatDate(p.from)
        : '${formatDate(p.from)} – ${formatDate(lastDay)}';

    pw.Widget label(String t) =>
        pw.Text(t, style: pw.TextStyle(color: PdfColors.blue100, fontSize: 8));
    pw.Widget value(String t) => pw.Text(
          t,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        );

    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
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
                'SALES REPORT',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 10),
              label('VENDOR'),
              pw.SizedBox(height: 2),
              value(vendorName),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              label('PERIOD'),
              pw.SizedBox(height: 2),
              value(range),
              pw.SizedBox(height: 10),
              label('GENERATED'),
              pw.SizedBox(height: 2),
              value(formatDate(DateTime.now())),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------- KPIs

  pw.Widget _kpis(ReportSummaryEntity s) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: _kpi('Sales', formatMoney(s.totalSales), s.salesChangePct)),
        pw.SizedBox(width: 8),
        pw.Expanded(child: _kpi('Paid', formatMoney(s.paidAmount), s.paidChangePct)),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _kpi('Outstanding', formatMoney(s.outstanding), null,
              note: 'All unpaid requests'),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _kpi('Requests', '${s.requestCount}', s.requestsChangePct),
        ),
      ],
    );
  }

  pw.Widget _kpi(String label, String value, double? pct, {String? note}) {
    final change = pct == null
        ? (note ?? 'No prior data')
        : '${pct >= 0 ? '+' : '-'}${formatPct(pct)} vs previous';
    final color = pct == null ? _muted : (pct >= 0 ? _good : _bad);

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _border),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(color: _muted, fontSize: 8)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(change, style: pw.TextStyle(color: color, fontSize: 7)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- sections

  pw.Widget _section(String title, pw.Widget child) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  pw.Widget _trend(List<TrendPoint> points) {
    final maxValue =
        points.fold<double>(0, (m, p) => p.amount > m ? p.amount : m);
    if (points.isEmpty || maxValue == 0) {
      return pw.Text(
        'No sales in this period',
        style: pw.TextStyle(color: _muted, fontSize: 9),
      );
    }

    const chartHeight = 90.0;
    final labelEvery = math.max(1, (points.length / 8).ceil());
    final best = points.reduce((a, b) => a.amount >= b.amount ? a : b);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          height: chartHeight,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              for (final p in points)
                pw.Expanded(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                    height: p.amount == 0 ? 1 : (p.amount / maxValue) * chartHeight,
                    decoration: pw.BoxDecoration(
                      color: _accent,
                      borderRadius: pw.BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            for (var i = 0; i < points.length; i++)
              pw.Expanded(
                child: pw.Text(
                  i % labelEvery == 0 ? points[i].label : '',
                  softWrap: false,
                  style: pw.TextStyle(color: _muted, fontSize: 6),
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Highest: ${best.label} · ${formatMoney(best.amount)}',
          style: pw.TextStyle(color: _muted, fontSize: 8),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ tables

  pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
    required Map<int, pw.Alignment> alignments,
    Map<int, pw.TableColumnWidth>? widths,
  }) {
    if (rows.isEmpty) {
      return pw.Text('No data', style: pw.TextStyle(color: _muted, fontSize: 9));
    }
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      columnWidths: widths,
      headerAlignments: alignments,
      cellAlignments: alignments,
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: pw.BoxDecoration(
        color: _ink,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      cellStyle: pw.TextStyle(color: _ink, fontSize: 9),
      oddRowDecoration: pw.BoxDecoration(color: _zebra),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _border, width: 0.5),
      ),
    );
  }

  pw.Widget _breakdownTable(List<BreakdownItem> items, String firstHeader) {
    return _table(
      headers: [firstHeader, 'Requests', 'Amount', 'Share'],
      rows: [
        for (final i in items)
          [
            i.name,
            '${i.count}',
            formatMoney(i.amount),
            '${(i.share * 100).toStringAsFixed(0)}%',
          ],
      ],
      alignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      widths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FixedColumnWidth(55),
        2: const pw.FixedColumnWidth(95),
        3: const pw.FixedColumnWidth(50),
      },
    );
  }

  pw.Widget _agingTable(List<AgingBucket> buckets) {
    return _table(
      headers: ['Age', 'Unpaid requests', 'Amount'],
      rows: [
        for (final b in buckets) [b.label, '${b.count}', formatMoney(b.amount)],
      ],
      alignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _unpaidTable(List<UnpaidConnection> items) {
    return _table(
      headers: ['Connection', 'Number', 'Unpaid', 'Amount', 'Oldest'],
      rows: [
        for (final i in items)
          [
            i.connectionName,
            i.connectionNumber,
            '${i.count}',
            formatMoney(i.amount),
            '${i.oldestDays}d',
          ],
      ],
      alignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _expiringTable(List<ExpiringConnection> items) {
    String when(int days) =>
        days <= 0 ? 'Today' : (days == 1 ? 'Tomorrow' : 'In $days days');

    return _table(
      headers: ['Connection', 'Number', 'Package', 'Expires', 'When'],
      rows: [
        for (final i in items)
          [
            i.connectionName,
            i.connectionNumber,
            i.packageName,
            formatDate(i.expireDate),
            when(i.daysLeft),
          ],
      ],
      alignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerRight,
      },
    );
  }
}
