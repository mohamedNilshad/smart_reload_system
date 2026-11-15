import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_bottom_sheet.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_invoice_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/empty_screen.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/fallback.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/shimmer_loading.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/entity/commission_withdrew_history.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/com_history/com_history.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/com_history/com_history.event.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/com_history/com_history.state.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/wallet/wallet.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/wallet/wallet.event.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/wallet/wallet.state.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  bool isTotalLoading = false;
  bool isHistoryLoading = false;
  bool isWithdrawalLoading = false;
  bool isError = false;
  double totalBalance = 0.0;
  List<ComWithdrawHistoryEntity> historyList = const [];

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const WalletReset());
    context.read<WalletBloc>().add(const WalletRequested());
    context.read<ComHistoryBloc>().add(const ComWithdrawHistoryRequested());
  }

  Future<void> _showWithdrawSheet(double availableBalance) async {
    final bankName = 'Commercial Bank';
    final accountHolder = 'Smart Reload System Vendor';
    final accountNumber = '1234567890';
    final navigator = Navigator.of(context);

    final confirmed = await AppBottomSheet.showForm<bool>(
      context,
      isDark: true,
      title: 'Withdraw commission',
      buttonText: 'Confirm withdraw',
      form: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(text: 'Bank: $bankName', color: AppColors.grey),
          const SizedBox(height: 8),
          BodyText(text: 'Account holder: $accountHolder', color: AppColors.grey),
          const SizedBox(height: 8),
          BodyText(text: 'Account number: ${HelperFunctions.maskPhoneNumber(accountNumber)}', color: AppColors.grey),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
              child: HeadlineText(text: HelperFunctions.formatCurrency(availableBalance), color: AppColors.white))
        ],
      ),
      onSubmit: () => navigator.pop(true),
    );

    if (confirmed == true) {

      if (!mounted) return;
      context.read<WalletBloc>().add(
        ComWithdrawalSubmitted(
          withdrewAmount: availableBalance,
          totalAmount: availableBalance,
          bankName: bankName,
          accountHolder: accountHolder,
          accountNumber: accountNumber,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldVendor,
      appBar: customAppBar(isDark: true, title: 'Wallet'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.ssm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Header
            BlocListener<WalletBloc, WalletState>(
              listener: (context, state) {
                if(state is WalletLoading) {
                  isError = false;
                  isTotalLoading = state.isWalletLoading;
                  isWithdrawalLoading = state.isWithdrawalLoading;
                }
                if (state is WalletFailure) {
                  AppSnackbar.showError(context, state.message);
                  isError = true;
                }
                if(state is WalletSuccess) {
                  setState(() {
                    totalBalance = state.totalBalance;
                    isTotalLoading = false;
                    isWithdrawalLoading = false;
                    isError = false;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Sizes.lg),
                decoration: BoxDecoration(
                  gradient: AppColors.linerGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        SubTitleText(
                          text: 'AVAILABLE BALANCE',
                          color: AppColors.white,
                        ),
                        Visibility(
                          visible: !isError,
                          replacement: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white.withValues(alpha: 0.14),
                            ),
                            child: IconButton(
                              onPressed: (){
                                context.read<WalletBloc>().add(const WalletRequested());
                              },
                              icon: Icon(Icons.refresh),
                            ),
                          ),
                          child: TextButton(
                            onPressed: totalBalance == 0.0 ? null : () => _showWithdrawSheet(totalBalance),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.white,
                              backgroundColor: AppColors.white.withValues(alpha: 0.14),
                            ),
                            child: const Text('Withdraw'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.xs),
                    HeadlineText(
                      text: HelperFunctions.formatCurrency(totalBalance),
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),


            const SizedBox(height: Sizes.md),
            TitleText(text: 'Withdrawal history', color: AppColors.white),
            const SizedBox(height: Sizes.md),

            ///History
            BlocBuilder<ComHistoryBloc, ComHistoryState>(
              builder: (context, state) {
                if(state is ComHistoryLoading) {
                  return Column(
                    spacing: 10,
                    children: [
                      ShimmerLoading(
                        height: 90,
                        width: double.infinity,
                        isDark: true,
                      ),
                      ShimmerLoading(
                        height: 90,
                        width: double.infinity,
                        isDark: true,
                      ),
                      ShimmerLoading(
                        height: 90,
                        width: double.infinity,
                        isDark: true,
                      ),
                    ],
                  );
                }
                if (state is ComHistoryFailure) {
                  return FallbackWidget(
                    isDark: true,
                    onPressed: () {
                      context.read<ComHistoryBloc>().add(const ComWithdrawHistoryRequested());
                    },
                  );
                }
                if(state is WithdrawHistorySuccess) {
                  historyList = state.history;

                  if(historyList.isEmpty) {
                    return EmptyScreenWidget(isDark: true, message: 'No withdrawal history yet.');
                  }else{
                    return ListView.separated(
                      itemCount: historyList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, _) =>
                      const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = historyList[index];
                        return CustomInvoiceCard(
                          title: HelperFunctions.invoiceNumber((historyList.length - index)),
                          icon: Icons.monetization_on_outlined,
                          subtitle: 'Withdrawn',
                          amount: item.withdrewAmount,
                          date: item.date,
                          isDark: true,
                        );

                      },
                    );
                  }
                }

                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
