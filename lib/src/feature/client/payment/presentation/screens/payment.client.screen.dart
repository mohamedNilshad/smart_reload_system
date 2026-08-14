import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.event.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.state.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_elevated_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  bool btnLoading = false;
  double amount = 0.00;

  @override
  void initState() {
    super.initState();
    amount = 3482.00;
    // context.read<PaymentBloc>().add(const PaymentReset());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = HelperFunctions.screenWidth(context);
    return Scaffold(
      appBar: customAppBar(title: "Invoice"),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          btnLoading = state is PaymentProcessing;
          if (state is PaymentSuccess) {
            AppSnackbar.showInfo(context, "Payment Successful! ${state.paymentId}");

            setState(() {
              btnLoading = false;
              amount = 0.0;
            });
          } else if (state is PaymentFailureState) {
            setState(() {
              btnLoading = false;
            });
            AppSnackbar.showError(context, state.message);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Container(
                width: screenWidth,
                margin: EdgeInsets.symmetric(horizontal: Sizes.sm),
                padding: EdgeInsets.all(Sizes.md),
                decoration: BoxDecoration(
                  gradient: AppColors.linerGradient,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  spacing: 10,
                  children: [
                    SubTitleText(text: "TOTAL PAYABLE", color: AppColors.white),
                    HeadlineText(text: "RS. $amount", color: AppColors.white),
                    CElevatedButton(
                      isLoading: btnLoading,
                      loadingColor: AppColors.black,
                      onPressed: btnLoading ? null : (){
                        context.read<PaymentBloc>().add(
                          StartPaymentRequested(
                            amount: amount,
                            address: "Kandy Sri Lanka",
                            city: "Kandy",
                            email: "nilshad@gmail.com",
                            firstName: "Mohamed",
                            itemDescription: "",
                            lastName: "Nilshad",
                            orderId: "SRS-${DateTime.now().microsecondsSinceEpoch}",
                            phone: "0776198355",
                          ),
                        );
                      },
                      bgColor: btnLoading ? AppColors.buttonDisabled : AppColors.white,
                      fgColor: AppColors.black,
                      width: 150,
                      height: 30,
                      label: "Pay",
                    )
                  ],
                ),
              ),
              TitleText(text: "Recent Invoices"),
              ListView.builder(
                  itemCount: 10,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(

                        tileColor: AppColors.grey,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.green.withValues(alpha: 0.3),
                          child: Icon(Icons.check, color: AppColors.green),
                        ),
                        title: TitleText(text: "INV-1001"),
                        subtitle: BodyText(text: "2023-10-01", size: 10, color: AppColors.darkerGrey),
                        trailing: Column(
                          spacing: 5,
                          children: [
                            SubHeadlineText(text: "Rs. 1500"),
                            CChip(label: "paid", bgColor: AppColors.green,)
                          ],
                        ),
                      ),
                    );
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
