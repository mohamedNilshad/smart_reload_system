import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/presentation/progress_indicators/custom.circular_progress_indicator.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/label_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/fallback.widget.dart';
import 'package:smart_reload_system/src/core/utils/report_format.util.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_period.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_summary.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/report/presentation/bloc/vendor_reports.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/report/presentation/bloc/vendor_reports.event.dart';
import 'package:smart_reload_system/src/feature/vendor/report/presentation/bloc/vendor_reports.state.dart';
import 'package:smart_reload_system/src/feature/vendor/report/presentation/screen/widget/kpi_card.widget.dart';
import 'package:smart_reload_system/src/feature/vendor/report/presentation/screen/widget/report_lists.widget.dart';
import 'package:smart_reload_system/src/feature/vendor/report/presentation/screen/widget/report_section.widget.dart';
import 'package:smart_reload_system/src/feature/vendor/report/presentation/screen/widget/sales_trend_chart.widget.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key, required this.vendorId});
  final String vendorId;

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  ReportPeriodEntity _period = ReportPeriodEntity.lastDays(7);

  /// Last loaded report, kept so the page doesn't blank out while refreshing.
  ReportSummaryEntity? _last;

  @override
  void initState() {
    super.initState();
    context.read<VendorReportsBloc>()
      ..add(const VendorReportsReset())
      ..add(VendorReportsRequested(vendorId: widget.vendorId, period: _period));
  }


  void _load() {
    context.read<VendorReportsBloc>().add(
          VendorReportsRequested(vendorId: widget.vendorId, period: _period),
        );
  }

  void _pick(ReportPeriodEntity period) {
    setState(() => _period = period);
    _load();
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final lastDay = DateTime(_period.to.year, _period.to.month, _period.to.day - 1);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: DateTimeRange(start: _period.from, end: lastDay),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );
    if (range == null || !mounted) return;
    _pick(ReportPeriodEntity.custom(range.start, range.end));
  }

  Future<void> _refresh() async {
    final bloc = context.read<VendorReportsBloc>();
    _load();
    await bloc.stream
        .firstWhere((s) => s is! VendorReportsLoading)
        .timeout(const Duration(seconds: 30), onTimeout: () => bloc.state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldVendor,
      appBar: customAppBar(
        isDark: true,
        onPressed: () => Navigator.of(context).pop(),
        icon: Icons.arrow_back_ios_new_rounded,
        title: "Reports",
      ),
      body: BlocConsumer<VendorReportsBloc, VendorReportsState>(
        listener: (context, state) {
          if (state is VendorReportsFailureState && _last != null) {
            AppSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is VendorReportsSuccess) _last = state.summary;
          final summary = _last;
          final isLoading = state is VendorReportsLoading || state is VendorReportsInitial;

          if (summary == null ) {
            if (state is VendorReportsFailureState) {
              return FallbackWidget(
                isDark: true,
                message: state.message,
                onPressed: _load,
              );
            }
            return CCircularProgressIndicator(color: AppColors.white);
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _periodChips(),
                const SizedBox(height: 6),
                _periodCaption(context),
                const SizedBox(height: 10),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: LinearProgressIndicator(minHeight: 3, color: AppColors.primary, backgroundColor: AppColors.grey),
                  ),
                _kpis(summary),
                const SizedBox(height: 14),
                ReportSection(
                  title: 'Sales trend',
                  subtitle: 'Tap a bar for the amount',
                  child: SalesTrendChart(points: summary.trend),
                ),
                ReportSection(
                  title: 'Unpaid ageing',
                  subtitle: 'All outstanding requests, by how long ago they were made',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AgingSummary(buckets: summary.aging),
                      const SizedBox(height: 16),
                      LabelText(
                        text: 'Who to chase',
                        color: AppColors.white,
                        isBold: true,
                      ),
                      UnpaidList(items: summary.topUnpaid),
                    ],
                  ),
                ),
                ReportSection(
                  title: 'Expiring in the next 7 days',
                  subtitle: 'Good moment to remind these connections to reload',
                  child: ExpiringList(items: summary.expiring),
                ),
                ReportSection(
                  title: 'Sales by provider',
                  child: BreakdownBars(items: summary.providers),
                ),
                ReportSection(
                  title: 'Top packages',
                  child: BreakdownBars(items: summary.topPackages),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _periodChips() {
    Widget chip(String label, VoidCallback onTap) {
      bool isSelected = _period.label == label;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          showCheckmark: false,
          color: isSelected ? WidgetStatePropertyAll(AppColors.primary) : null,
          backgroundColor: AppColors.darkContainers,
          labelStyle: TextStyle(
            color: AppColors.white,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
          onSelected: (_) => onTap(),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Today', () => _pick(ReportPeriodEntity.today())),
          chip('7 days', () => _pick(ReportPeriodEntity.lastDays(7))),
          chip('30 days', () => _pick(ReportPeriodEntity.lastDays(30))),
          chip('Custom', _pickCustom),
        ],
      ),
    );
  }

  Widget _periodCaption(BuildContext context) {
    final lastDay = DateTime(_period.to.year, _period.to.month, _period.to.day - 1);
    final range = _period.days == 1 ? formatDay(_period.from) : '${formatDay(_period.from)} – ${formatDay(lastDay)}';
    final days = _period.days;

    return BodyText(
      text: '$range · compared with the previous $days ${days == 1 ? 'day' : 'days'}',
      color: AppColors.grey,
    );
  }

  Widget _kpis(ReportSummaryEntity s) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Sales',
                  value: formatMoney(s.totalSales),
                  icon: Icons.payments_outlined,
                  changePct: s.salesChangePct,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  label: 'Paid',
                  value: formatMoney(s.paidAmount),
                  icon: Icons.check_circle_outline_rounded,
                  changePct: s.paidChangePct,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Outstanding',
                  value: formatMoney(s.outstanding),
                  icon: Icons.hourglass_bottom_rounded,
                  footnote: 'All unpaid requests',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  label: 'Requests',
                  value: '${s.requestCount}',
                  icon: Icons.receipt_long_outlined,
                  changePct: s.requestsChangePct,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

