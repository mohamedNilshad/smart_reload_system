import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/data/model/Invoice_pdf_data.model.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/services/pdf_generator.service.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class InvoiceItemsBottomSheet extends StatefulWidget {
  const InvoiceItemsBottomSheet({
    super.key,
    required this.invoiceData,
    required this.scrollController,
    this.total = 0.0,
    this.title = 'Invoice items',
  });

  final ScrollController scrollController;
  final InvoicePdfData invoiceData;
  final String title;
  final double total;

  /// Call this to display the sheet.
  static Future<void> show(
      BuildContext context, {
        required InvoicePdfData invoiceData,
        String title = 'Invoice items',
        required double total,
      }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, controller) => InvoiceItemsBottomSheet(
          invoiceData: invoiceData,
          title: title,
          total: total,
          scrollController: controller,
        ),
      ),
    );
  }

  @override
  State<InvoiceItemsBottomSheet> createState() => _InvoiceItemsBottomSheetState();
}

class _InvoiceItemsBottomSheetState extends State<InvoiceItemsBottomSheet> {
  bool _isDownloading = false;
  String _expendedId = "";

  String _money(double v) => 'Rs. ${v.toStringAsFixed(2)}';

  Future<void> _download() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      await const InvoicePdfService().open(widget.invoiceData);
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Could not create the PDF');
        debugPrint(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header: download (top-left) · title · close
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Download PDF',
                  onPressed: _isDownloading ? null : _download,
                  icon: _isDownloading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      :  Icon(Icons.file_download_outlined),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items
          Expanded(
            child: widget.invoiceData.requests.isEmpty
                ? Center(
              child: Text(
                'No items',
                style: text.bodyMedium?.copyWith(color: AppColors.darkerGrey),
              ),
            )
                : ListView.separated(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: widget.invoiceData.requests.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: AppColors.grey,
              ),
              itemBuilder: (_, index) {
                final item = widget.invoiceData.requests[index];
                final isExpended = (_expendedId == item.id);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Sizes.sm),
                        decoration: !isExpended ? null : BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(16.0), topLeft: Radius.circular(16.0)),
                          border: Border(top: BorderSide(color: AppColors.primary), left: BorderSide(color: AppColors.primary), right: BorderSide(color: AppColors.primary))
                        ),
                        child: InkWell(
                          onTap: () {
                            if(isExpended){
                              setState(() => _expendedId = "");
                            }else{
                              setState(() => _expendedId = item.id!);
                            }

                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  size: 20,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 2,
                                  children: [
                                    Text(
                                      item.packageModel?.packageName ?? "N/A",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: text.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      item.connectionModel?.connectionName ?? 'N/A',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: text.bodySmall?.copyWith(
                                        color: AppColors.darkerGrey,
                                      ),
                                    ),
                                    Text(
                                      HelperFunctions.formatDateTime(item.activatedDate!),
                                      style: text.labelMedium?.copyWith(
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _money(item.amount ?? 0.0),
                                style: text.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if(isExpended)...{
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(Sizes.sm),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(16.0), bottomLeft: Radius.circular(16.0)),
                            border: Border(bottom: BorderSide(color: AppColors.primary), left: BorderSide(color: AppColors.primary), right: BorderSide(color: AppColors.primary)),
                            color: AppColors.grey.withValues(alpha: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 2,
                            children: [
                              Text(
                                item.connectionModel?.connectionNumber ?? 'N/A',
                                style: text.bodySmall,
                              ),
                              Text(
                                item.connectionModel?.serviceProvider ?? 'N/A',
                                style: text.bodySmall?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: AppColors.darkGrey
                                ),
                              ),
                              Text(
                                "${item.connectionModel?.connectionType ?? 'N/A'} | ${item.connectionModel?.billingType ?? 'N/A'}",
                                style: text.bodySmall,
                              ),
                            ],
                          ),
                        )
                      }
                    ],
                  ),
                );
              },
            ),
          ),

          // Total footer
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              border: Border(top: BorderSide(color: cs.outlineVariant)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [


                    buildBottomRow(
                      title: 'Sub total',
                      titleStyle: text.labelMedium!,
                      subtitle: widget.invoiceData.subtotal,
                      subtitleStyle: text.labelMedium!
                    ),

                    buildBottomRow(
                      title: 'Service charge (${widget.invoiceData.getCommissionPercentage}%)',
                      titleStyle: text.labelMedium!,
                      subtitle: widget.invoiceData.calCommission,
                      subtitleStyle: text.labelMedium!
                    ),

                    buildBottomRow(
                      title: 'Previous balance',
                      titleStyle: text.labelMedium!,
                      subtitle: widget.invoiceData.vendor.currentPaymentBalance ?? 0.0,
                      subtitleStyle: text.labelMedium!
                    ),

                    buildBottomRow(
                      title: 'Total',
                      titleStyle: text.titleMedium!,
                      subtitle: widget.total,
                      subtitleStyle: text.titleLarge!,
                      isTotal: true,
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomRow({
    required String title,
    required double subtitle,
    required TextStyle titleStyle,
    required TextStyle subtitleStyle,
    bool isTotal = false,
  }){
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: titleStyle),
        Text(
          _money(subtitle),
          style: subtitleStyle.copyWith(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppColors.black : AppColors.darkerGrey,
          ),
        ),
      ],
    );
  }
}