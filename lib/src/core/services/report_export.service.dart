import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_reload_system/src/core/services/report_csv.service.dart';
import 'package:smart_reload_system/src/core/services/report_pdf.service.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_summary.entity.dart';

/// Builds the report as PDF or CSV and opens it in the phone's viewer.
/// Files go to the temporary directory (not visible in the user's files and
/// cleared by the OS), the same flow as the invoice PDF.
class ReportExportService {
  const ReportExportService();

  Future<void> openPdf({
    required ReportSummaryEntity summary,
    required String vendorName,
  }) async {
    final bytes = await const ReportPdfService()
        .build(summary: summary, vendorName: vendorName);
    await _writeAndOpen(bytes, 'pdf', 'application/pdf');
  }

  Future<void> openCsv({
    required ReportSummaryEntity summary,
    required String vendorName,
  }) async {
    final csv =
        const ReportCsvService().build(summary: summary, vendorName: vendorName);
    // UTF-8 byte-order mark so Excel reads characters like "–" correctly.
    final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);
    await _writeAndOpen(bytes, 'csv', 'text/csv');
  }

  Future<void> _writeAndOpen(List<int> bytes, String extension, String mime) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/vendor_report_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
    await file.writeAsBytes(bytes, flush: true);

    final result = await OpenFile.open(file.path, type: mime);
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }
}
