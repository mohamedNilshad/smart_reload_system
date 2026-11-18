
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_summary.entity.dart';

/// Builds the vendor report as CSV: several small tables stacked in one file,
/// each with a title row, separated by a blank line. Amounts are plain numbers
/// (no currency symbol or thousands separators) so spreadsheets can sum them.
class ReportCsvService {
  const ReportCsvService();

  String build({
    required ReportSummaryEntity summary,
    required String vendorName,
  }) {
    final out = StringBuffer();
    void row(List<Object?> cells) => out.writeln(cells.map(_cell).join(','));
    void gap() => out.writeln();

    final p = summary.period;
    final lastDay = DateTime(p.to.year, p.to.month, p.to.day - 1);

    row(['Sales report']);
    row(['Vendor', _text(vendorName)]);
    row(['Period start', _iso(p.from)]);
    row(['Period end', _iso(lastDay)]);
    row(['Generated', _iso(DateTime.now())]);
    gap();

    row(['Summary']);
    row(['Metric', 'Value', 'Change vs previous period (%)']);
    row(['Sales', _num(summary.totalSales), _pct(summary.salesChangePct)]);
    row(['Paid', _num(summary.paidAmount), _pct(summary.paidChangePct)]);
    row(['Outstanding (all unpaid)', _num(summary.outstanding), '']);
    row(['Requests', summary.requestCount, _pct(summary.requestsChangePct)]);
    gap();

    row(['Sales trend']);
    row(['Period start', 'Requests', 'Amount']);
    for (final t in summary.trend) {
      row([_iso(t.start), t.count, _num(t.amount)]);
    }
    gap();

    row(['Sales by provider']);
    row(['Provider', 'Requests', 'Amount', 'Share (%)']);
    for (final i in summary.providers) {
      row([_text(i.name), i.count, _num(i.amount), _num(i.share * 100)]);
    }
    gap();

    row(['Top packages']);
    row(['Package', 'Requests', 'Amount', 'Share (%)']);
    for (final i in summary.topPackages) {
      row([_text(i.name), i.count, _num(i.amount), _num(i.share * 100)]);
    }
    gap();

    row(['Unpaid ageing']);
    row(['Age', 'Unpaid requests', 'Amount']);
    for (final b in summary.aging) {
      row([b.label, b.count, _num(b.amount)]);
    }
    gap();

    row(['Who to chase']);
    row(['Connection', 'Number', 'Unpaid requests', 'Amount', 'Oldest (days)']);
    for (final i in summary.topUnpaid) {
      row([
        _text(i.connectionName),
        _phone(i.connectionNumber),
        i.count,
        _num(i.amount),
        i.oldestDays,
      ]);
    }
    gap();

    row(['Expiring in the next 7 days']);
    row(['Connection', 'Number', 'Package', 'Expires', 'Days left']);
    for (final i in summary.expiring) {
      row([
        _text(i.connectionName),
        _phone(i.connectionNumber),
        _text(i.packageName),
        _iso(i.expireDate),
        i.daysLeft,
      ]);
    }

    return out.toString();
  }

  // ----------------------------------------------------------------- helpers

  String _num(double v) => v.toStringAsFixed(2);

  String _pct(double? v) => v == null ? '' : v.toStringAsFixed(1);

  String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Free text from the database. A leading `=`, `@` (or `+`/`-` before a
  /// non-digit) would be run as a formula by Excel/Sheets, so neutralise it.
  String _text(String s) {
    if (s.isEmpty) return s;
    final first = s[0];
    final second = s.length > 1 ? s[1] : '';
    final startsFormula = first == '=' ||
        first == '@' ||
        ((first == '+' || first == '-') && !RegExp(r'\d').hasMatch(second));
    return startsFormula ? "'$s" : s;
  }

  /// Phone numbers: write as ="0771234567" so Excel keeps the leading zero
  /// instead of turning the number into 771234567.
  String _phone(String s) =>
      RegExp(r'^\+?\d+$').hasMatch(s) ? '="$s"' : _text(s);

  /// Quotes a cell when it contains a comma, quote or line break.
  String _cell(Object? v) {
    final s = v?.toString() ?? '';
    final needsQuotes =
        s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r');
    return needsQuotes ? '"${s.replaceAll('"', '""')}"' : s;
  }
}
