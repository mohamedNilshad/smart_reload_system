import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/payment/data/model/paid_invoice_data.model.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.bloc.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.event.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.state.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  bool loading = false;
  double amount = 0.00;
  List<PaidInvoiceDataModel> paidInvoiceData = [];

  @override
  void initState() {
    super.initState();

    context.read<PaymentClientBloc>().add(const FetchPaidInvoices(clientVendorId: "vendor123"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: "Invoice"),
      body: BlocListener<PaymentClientBloc, PaymentClientState>(
        listener: (context, state) {
          
          if(state is PaymentLoading){
            loading = state.isFetchingPaidInvoices;
          }
          if (state is PaidInvoicesSuccess) {

            setState(() {
              paidInvoiceData = state.paidInvoices;
              loading = false;
            });
          } else if (state is PaymentFailure) {
            setState(() => loading = false);
            AppSnackbar.showError(context, state.message);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              TitleText(text: "Recent Invoices"),
              ListView.builder(
                  itemCount: paidInvoiceData.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = paidInvoiceData[index];
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

                            children: [
                              TitleText(text: item.invoiceData.vendor.vendorName, color: AppColors.darkerGrey),
                              BodyText(text: "INV-${item.id}", size: 10, color: AppColors.darkGrey),
                            ],
                          ),

                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SubHeadlineText(text: "Rs. ${item.paidAmount.toStringAsFixed(2)}", color: AppColors.darkerGrey, size: 16.0,),
                              BodyText(text: HelperFunctions.formatDateTime(item.invoiceDate, withTime: false), size: 10, color: AppColors.darkGrey),
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
