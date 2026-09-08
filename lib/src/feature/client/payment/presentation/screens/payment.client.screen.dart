import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.event.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.state.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
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
                padding: EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.linerGradient,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  spacing: 10,
                  children: [
                    SubTitleText(text: "TOTAL PAYABLE", color: AppColors.white),
                    HeadlineText(text: "RS. $amount", color: AppColors.white),
                    InkWell(
                      onTap: btnLoading ? null : (){
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
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(Sizes.sm),
                        margin: EdgeInsets.symmetric(horizontal: Sizes.xl),
                        alignment: AlignmentGeometry.center,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(25.0)
                        ),
                        child: btnLoading ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
                        ) : Text(
                          "Pay Now",
                          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 14.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TitleText(text: "Recent Invoices"),
              ListView.builder(
                  itemCount: 10,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {

                    return Container(
                      padding: EdgeInsets.all(Sizes.ssm),
                      margin: EdgeInsetsGeometry.only(bottom: 10.0),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        spacing: 10,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.green.withValues(alpha: 0.2),
                            child: Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 35,),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 5.0,
                            children: [
                              TitleText(text: "INV-1001", color: AppColors.darkerGrey),
                              BodyText(text: "2023-10-01", size: 10, color: AppColors.darkGrey),
                            ],
                          ),

                          Spacer(),
                          Column(
                            spacing: 5,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SubHeadlineText(text: "Rs. 1500", color: AppColors.darkerGrey, size: 16.0,),
                              CChip(label: "paid", bgColor: AppColors.green,)
                            ],
                          ),
                        ],
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
