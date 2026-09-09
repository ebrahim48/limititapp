import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:limit_it_app/core/models/appinfo_model.dart';
import 'package:limit_it_app/core/models/daily_usage.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:intl/intl.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';

class ReportGeneratorService {
  /// Generate PDF report with usage statistics
  static Future<void> generateAndDownloadReport({
    required List<DailyUsageApp> dailyApps,
    required List<AppInfo> yourApps,
    List<AppUsageData>? appUsageData,
  }) async {
    final pdf = pw.Document();

    // Get current date
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader(dateFormat.format(now), timeFormat.format(now)),
            pw.SizedBox(height: 30),
            _buildSummarySection(appUsageData),
            pw.SizedBox(height: 30),
            _buildDailyUsageChart(dailyApps, appUsageData),
            pw.SizedBox(height: 30),
            _buildMostUsedAppsTable(yourApps, appUsageData),
            pw.SizedBox(height: 30),
            _buildTipsSection(),
            _buildFooter(),
          ];
        },
      ),
    );

    // Print/Share the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'LimitIt_Report_${DateFormat('yyyy-MM-dd').format(now)}.pdf',
    );
  }

  /// Build report header
  static pw.Widget _buildHeader(String date, String time) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF4C7C5B),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            appL10n.reportTitle,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            appL10n.reportGeneratedOn(date, time),
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary section
  static pw.Widget _buildSummarySection(List<AppUsageData>? appUsageData) {
    int totalApps = appUsageData?.length ?? 0;
    int totalUsageMinutes = 0;

    if (appUsageData != null) {
      totalUsageMinutes = appUsageData.fold(
        0,
        (sum, app) => sum + (app.usageTimeMs ~/ (1000 * 60)),
      );
    }

    int hours = totalUsageMinutes ~/ 60;
    int minutes = totalUsageMinutes % 60;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF5F5F5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFDDDDDD)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            appL10n.reportTodaysSummary,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF2C2C2C),
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(appL10n.reportTotalAppsUsed, '$totalApps'),
              _buildSummaryItem(appL10n.reportTotalTime, '$hours h $minutes min'),
              _buildSummaryItem(appL10n.reportAvgPerApp, totalApps > 0 ? '${(totalUsageMinutes / totalApps).toInt()} min' : '0 min'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFF4C7C5B),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColor.fromInt(0xFF666666),
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  /// Build daily usage chart (as a table since PDF doesn't support charts)
  static pw.Widget _buildDailyUsageChart(List<DailyUsageApp> dailyApps, List<AppUsageData>? appUsageData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          appL10n.reportDailyUsageBreakdown,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFF2C2C2C),
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFDDDDDD)),
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF0F0F0)),
              children: [
                _buildTableCell('App', isHeader: true),
                _buildTableCell(appL10n.reportUsageTime, isHeader: true, align: pw.TextAlign.right),
                _buildTableCell('% of Total', isHeader: true, align: pw.TextAlign.right),
              ],
            ),
            // Data rows
            ..._buildUsageRows(dailyApps, appUsageData),
          ],
        ),
      ],
    );
  }

  static List<pw.TableRow> _buildUsageRows(List<DailyUsageApp> dailyApps, List<AppUsageData>? appUsageData) {
    List<pw.TableRow> rows = [];

    if (appUsageData != null && appUsageData.isNotEmpty) {
      // Use real usage data
      for (var app in appUsageData) {
        int minutes = app.usageTimeMs ~/ (1000 * 60);
        String timeStr = minutes >= 60 ? '${minutes ~/ 60}h ${minutes % 60}m' : '${minutes}m';

        rows.add(
          pw.TableRow(
            children: [
              _buildTableCell(app.name),
              _buildTableCell(timeStr, align: pw.TextAlign.right),
              _buildTableCell(app.percentageString, align: pw.TextAlign.right),
            ],
          ),
        );
      }
    } else {
      // Use dummy data
      for (var app in dailyApps) {
        rows.add(
          pw.TableRow(
            children: [
              _buildTableCell(app.name),
              _buildTableCell(app.percentage, align: pw.TextAlign.right),
              _buildTableCell(app.percentage, align: pw.TextAlign.right),
            ],
          ),
        );
      }
    }

    return rows;
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColor.fromInt(0xFF2C2C2C),
        ),
        textAlign: align,
      ),
    );
  }

  /// Build most used apps table
  static pw.Widget _buildMostUsedAppsTable(List<AppInfo> yourApps, List<AppUsageData>? appUsageData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          appL10n.mostUsedApps,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFF2C2C2C),
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFDDDDDD)),
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF0F0F0)),
              children: [
                _buildTableCell(appL10n.reportAppName, isHeader: true),
                _buildTableCell('Usage', isHeader: true, align: pw.TextAlign.right),
                _buildTableCell('Share', isHeader: true, align: pw.TextAlign.right),
              ],
            ),
            // Data rows
            ..._buildAppRows(yourApps, appUsageData),
          ],
        ),
      ],
    );
  }

  static List<pw.TableRow> _buildAppRows(List<AppInfo> yourApps, List<AppUsageData>? appUsageData) {
    List<pw.TableRow> rows = [];

    if (appUsageData != null && appUsageData.isNotEmpty) {
      // Show top apps from real data
      for (var app in appUsageData.take(10)) {
        int minutes = app.usageTimeMs ~/ (1000 * 60);
        String timeStr = minutes >= 60 ? '${minutes ~/ 60}h ${minutes % 60}m' : '${minutes}m';

        rows.add(
          pw.TableRow(
            children: [
              _buildTableCell(app.name),
              _buildTableCell(timeStr, align: pw.TextAlign.right),
              _buildTableCell(app.percentageString, align: pw.TextAlign.right),
            ],
          ),
        );
      }
    } else {
      // Use dummy data
      for (var app in yourApps) {
        rows.add(
          pw.TableRow(
            children: [
              _buildTableCell(app.name),
              _buildTableCell(app.usage, align: pw.TextAlign.right),
              _buildTableCell(app.percentage, align: pw.TextAlign.right),
            ],
          ),
        );
      }
    }

    return rows;
  }

  /// Build tips section
  static pw.Widget _buildTipsSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFFF9E6),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFEDD69A)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            appL10n.reportTips,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF2C2C2C),
            ),
          ),
          pw.SizedBox(height: 10),
          _buildTipItem(appL10n.reportTip1),
          _buildTipItem(appL10n.reportTip2),
          _buildTipItem(appL10n.reportTip3),
          _buildTipItem(appL10n.reportTip4),
          _buildTipItem(appL10n.reportTip5),
        ],
      ),
    );
  }

  static pw.Widget _buildTipItem(String tip) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Text(
        tip,
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColor.fromInt(0xFF2C2C2C),
        ),
      ),
    );
  }

  /// Build footer
  static pw.Widget _buildFooter() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 30),
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF5F5F5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            appL10n.reportFooterTagline,
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColor.fromInt(0xFF666666),
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            appL10n.reportGeneratedBy,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromInt(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}
