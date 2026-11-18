import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/presentation/progress_indicators/custom.circular_progress_indicator.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_bottom_sheet.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_invoice_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
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
            setState(() {
              loading = state.isFetchingPaidInvoices;
            });
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
        child: Visibility(
          visible: !loading,
          replacement: Center(
            child: CCircularProgressIndicator(),
          ),
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
                      return CustomInvoiceCard(
                        onTap: (){
                          InvoiceItemsBottomSheet.show(
                            context,
                            total: item.paidAmount,
                            invoiceData: item.invoiceData,
                            isPaid: true,
                          );
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
          ),
        ),
      ),
    );
  }
}
