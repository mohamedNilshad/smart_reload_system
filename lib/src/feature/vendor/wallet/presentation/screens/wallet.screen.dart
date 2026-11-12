import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_invoice_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/fallback.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/shimmer_loading.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/wallet.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/wallet.event.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/wallet.state.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const WalletReset());
    context.read<WalletBloc>().add(const WalletRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldVendor,
      appBar: customAppBar(
        isDark: true,
        title: 'Wallet',
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return Padding(
              padding: const EdgeInsets.all(Sizes.ssm),
              child: Column(
                children: [
                  ShimmerLoading(height: 140, width: double.infinity, isDark: true),
                  const SizedBox(height: Sizes.sm),
                  ShimmerLoading(height: 90, width: double.infinity, isDark: true),
                  const SizedBox(height: Sizes.sm),
                  ShimmerLoading(height: 90, width: double.infinity, isDark: true),
                ],
              ),
            );
          }

          if (state is WalletFailure) {
            return FallbackWidget(
              isDark: true,
              onPressed: () {
                context.read<WalletBloc>().add(const WalletRequested());
              },
            );
          }

          if (state is WalletSuccess) {
            final summary = state.summary;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(Sizes.ssm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Sizes.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.linerGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SubTitleText(text: 'AVAILABLE BALANCE', color: AppColors.white),
                        const SizedBox(height: Sizes.xs),
                        HeadlineText(
                          text: HelperFunctions.formatCurrency(summary.totalCommission),
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Sizes.md),
                  TitleText(text: "Recent Invoices"),
                  ListView.builder(
                      itemCount: paidInvoiceData.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = paidInvoiceData[index];
                        return CustomInvoiceCard(
                          onTap: (){

                          },
                          title: item.invoiceData.vendor.vendorName,
                          icon: Icons.check_circle_outline_rounded,
                          subtitle: "INV-${item.id}",
                          amount: item.paidAmount,
                          date: item.invoiceDate,
                        );
                      }
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkContainers,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubTitleText(text: title.toUpperCase(), color: AppColors.darkGrey),
          const SizedBox(height: Sizes.xs),
          TitleText(text: value, color: AppColors.white, isBold: true),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;

  const _DetailsCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Sizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkContainers,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(text: title, color: AppColors.white),
          const SizedBox(height: Sizes.md),
          ...rows,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SubTitleText(text: label, color: AppColors.darkGrey),
          TitleText(text: value, color: AppColors.white, isBold: false),
        ],
      ),
    );
  }
}
