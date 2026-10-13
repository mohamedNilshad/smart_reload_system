import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.event.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.state.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/data/model/Invoice_pdf_data.model.dart';
import 'package:smart_reload_system/src/core/presentation/progress_indicators/custom.circular_progress_indicator.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_bottom_sheet.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_elevated_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/empty_screen.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/fallback.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/shimmer_loading.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/core/domain/entity/user.entity.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.state.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/vendor.model.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.event.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.state.dart' as c;
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/widgets/connection_card.widget.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.event.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.bloc.dart';

import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.state.dart';

class ConnectionClientScreen extends StatefulWidget {
  final VendorModel vendor;
  const ConnectionClientScreen({super.key, required this.vendor});

  @override
  State<ConnectionClientScreen> createState() => _ConnectionClientScreenState();
}

class _ConnectionClientScreenState extends State<ConnectionClientScreen> {
  final amountController = TextEditingController();
  final _isLoadingNotifier = ValueNotifier<bool>(false);
  double screenWidth = 0.0;
  final List<Map<String, String>> connectionsNumbers = [];

  bool paymentBtnLoading = false;
  bool payableLoading = false;
  bool payableAmountLoading = true;
  double paymentAmount = 0.0;
  List<PackageRequestModel> payableList = [];
  late VendorModel vendor;
  late UserEntity user;

  InvoicePdfData? invoiceData;
  String serviceCharge = "0+0";

  @override
  void initState() {
    super.initState();
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) user = sessionState.user;

    vendor = widget.vendor;
    context.read<ConnectionBloc>().add(const ConnectionsReset());
    context.read<ConnectionBloc>().add(ConnectionsRequested(vendor.clientVendorId));

  }

  @override
  void dispose() {
    amountController.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  void initValues(List<ConnectionModel> connections){
    connectionsNumbers.clear();
    for (var connection in connections) {
      connectionsNumbers.add({
        'category': connection.connectionCategory,
        'number': connection.connectionNumber,
      });
    }
  }

  Future<void> calPayAmount() async {
    setState(()  {
      paymentAmount = 0.0;
      payableAmountLoading = true;

      if(payableList.isNotEmpty){
        for (var item in payableList) {
          paymentAmount += item.amount ?? 0.0;
        }
      }

      invoiceData = InvoicePdfData(
        vendor: widget.vendor,
        clientName: user.fullName,
        clientEmail: user.email,
        clientPhone: user.phoneNumber,
        requests: payableList.reversed.toList(),
        serviceCharge: serviceCharge,
        currency: 'Rs. ',
      );

      paymentAmount += invoiceData?.calCommission ?? 0.0;

    });

    setState(() => payableAmountLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    screenWidth = HelperFunctions.screenWidth(context);
    return Scaffold(
      appBar: customAppBar(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icons.arrow_back_ios_new_rounded,
        title: vendor.vendorName,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ConnectionBloc>().add(const ConnectionsReset());
          context.read<ConnectionBloc>().add(ConnectionsRequested(vendor.clientVendorId));
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: BlocConsumer<ConnectionBloc, c.ConnectionState>(
          listener: (context, state){
            if (state is c.ConnectionSuccess){
              context.read<PaymentClientBloc>().add(FetchPayableDetails(clientVendorId :vendor.clientVendorId));

            }
          },
          builder: (context, state) {

            if (state is c.ConnectionLoading) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      ShimmerLoading(
                        height: 180,
                        width: screenWidth,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      ShimmerLoading(
                        height: 180,
                        width: screenWidth,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is c.ConnectionFailure) {
              return FallbackWidget(
                  onPressed: () {
                    context.read<ConnectionBloc>().add(ConnectionsRequested(vendor.clientVendorId));
                  }
              );
            }

            if (state is c.ConnectionSuccess) {
              if (state.connections.isEmpty) {
                return EmptyScreenWidget();
              }

              initValues(state.connections);
              List<ConnectionModel> approvedList = state.connections.where((c) => c.status == true).toList();
              List<ConnectionModel> pendingList = state.connections.where((c) => c.status == false).toList();

              return MultiBlocListener(
                listeners: [
                  BlocListener<PaymentClientBloc, PaymentClientState>(
                    listener: (context, pState) {

                      if(pState is PaymentLoading){
                        payableLoading = pState.isFetching;
                      }
                      if (pState is PayableSuccess) {
                        setState(() {
                          payableLoading = false;
                          payableList = pState.payableList;
                          serviceCharge = pState.serviceCharge;

                          // if(payableList.isNotEmpty) {
                          //   calPayAmount();
                          // }else{
                          //   payableAmountLoading = false;
                          // }
                          calPayAmount();
                        });

                      } else if (pState is PaymentClientSuccess) {
                        if(pState.isPaymentCreated){
                          context.read<PaymentClientBloc>().add(FetchPayableDetails(clientVendorId :vendor.clientVendorId));
                        }

                      } else if (pState is PaymentFailure) {
                        setState(() => payableLoading = false);
                        AppSnackbar.showError(context, pState.message, showUp: true);
                      }
                    },
                  ),

                  BlocListener<PaymentBloc, PaymentState>(
                    listener: (context, state) {
                      paymentBtnLoading = state is PaymentProcessing;

                      if (state is PaymentSuccess) {
                        AppSnackbar.showInfo(context, "Payment Successful! ${state.paymentId}", showUp: true);

                        context.read<PaymentClientBloc>().add(CreatePayment(
                          clientVendorId: vendor.clientVendorId,
                          lastPaidAmount: paymentAmount,
                          lastPaidDate: state.paymentDate,
                          reqPackageIdList: payableList.map((e) => e.id ?? "").toList(),
                          vendorId: vendor.vendorId,
                          vendorComAmount: 0.0,
                          paymentRefNumber: state.paymentId,
                          invoiceData: invoiceData!,
                        ));
                        setState(() => paymentBtnLoading = false);
                      } else if (state is PaymentFailureState) {
                        setState(() => paymentBtnLoading = false);
                        AppSnackbar.showError(context, state.message);
                      }
                    },
                  ),
                ],
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(Sizes.ssm, Sizes.ssm, Sizes.ssm, 100 ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: screenWidth,
                              padding: EdgeInsets.all(Sizes.sm),
                              decoration: BoxDecoration(
                                gradient: AppColors.linerGradient,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                spacing: 10,
                                children: [
                                  SubTitleText(text: "TOTAL PAYABLE", color: AppColors.white),
                                  (payableAmountLoading) ? CCircularProgressIndicator(color: AppColors.white, radius: 25): HeadlineText(text: "RS. $paymentAmount", color: AppColors.white),
                                  InkWell(
                                    onTap: paymentBtnLoading || payableAmountLoading || (paymentAmount == 0.0) ? null : (){
                                      context.read<PaymentBloc>().add(
                                        StartPaymentRequested(
                                          amount: paymentAmount,
                                          address: "Kandy Sri Lanka",
                                          city: "Kandy",
                                          email: user.email,
                                          firstName: user.fullName,
                                          itemDescription: "",
                                          lastName: "SRS",
                                          orderId: "SRS-${DateTime.now().microsecondsSinceEpoch}",
                                          phone: user.phoneNumber,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(Sizes.sm),
                                      margin: EdgeInsets.symmetric(horizontal: Sizes.xl),
                                      alignment: AlignmentGeometry.center,
                                      decoration: BoxDecoration(
                                          color: (paymentAmount == 0.0) ? AppColors.buttonDisabled : AppColors.white,
                                          borderRadius: BorderRadius.circular(25.0)
                                      ),
                                      child: paymentBtnLoading ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
                                      ) : Text(
                                        "Pay Now",
                                        style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 14.0),
                                      ),
                                    ),
                                  ),
                                  if((paymentAmount != 0.0))...{
                                    TextButton(
                                      onPressed: (){
                                        InvoiceItemsBottomSheet.show(
                                          context,
                                          total: paymentAmount,
                                          invoiceData: invoiceData!,
                                        );
                                      },
                                      child: Text(
                                        "See details",
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  }else...{
                                    SizedBox(height: 10.0),
                                  }

                                ],
                              ),
                            ),
                            Positioned(
                              top: 5,
                              left: 5,
                              child: InkWell(
                                onTap: (){
                                  //navigate to payment screen
                                },
                                child: CircleAvatar(
                                  backgroundColor: AppColors.darkerGrey.withValues(alpha: 0.5),
                                  child: Icon(Icons.history_rounded, color: AppColors.white),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Container(
                          margin: EdgeInsets.symmetric(vertical: Sizes.sm),
                          alignment: AlignmentGeometry.topStart,
                          child: TitleText(text: "Activated Connections"),
                        ),

                        if(approvedList.isEmpty)...{
                          BodyText(text: "No connections!", color: AppColors.darkerGrey),
                        }else...{
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10.0,
                            children: approvedList.map((connection) {
                              return ConnectionCard(
                                onTap: () async {
                                  Navigator.pushNamed(
                                    context,
                                    RouteConstants.connectionDetailsClientScreen,
                                    arguments: (vendorId: vendor.vendorId, connectionModel: connection),
                                  );
                                },
                                conNumber: connection.connectionNumber,
                                lastDate: connection.lastReloadDate,
                                conName: connection.connectionName,
                                isActive: connection.isActive,
                                conType: connection.connectionType,
                                conPlan: connection.billingType,
                              );
                            }).toList(),
                          ),
                        },


                        if(pendingList.isNotEmpty)...{
                          Container(
                            margin: EdgeInsets.fromLTRB(0.0, Sizes.lg, 0.0, Sizes.sm),
                            alignment: AlignmentGeometry.topStart,
                            child: TitleText(text: "Pending Connections"),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10.0,
                            children: pendingList.map((connection) {
                              return ConnectionCard(
                                onTap: () async {
                                  Navigator.pushNamed(
                                    context,
                                    RouteConstants.connectionDetailsClientScreen,
                                    arguments: connection,
                                  );
                                },
                                conNumber: connection.connectionNumber,
                                lastDate: connection.lastReloadDate,
                                conName: connection.connectionName,
                                isActive: connection.isActive,
                                conType: connection.connectionType,
                                conPlan: connection.billingType,
                                status: false,
                              );
                            }).toList(),
                          ),
                        },
                      ],
                    ),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
        child: CElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              RouteConstants.addNewConnectionClientScreen,
              arguments: (clientVendorId: vendor.clientVendorId, connectionNumbers: connectionsNumbers)
            ).then((result){

              if(result != null && result == true && context.mounted){
                context.read<ConnectionBloc>().add(const ConnectionsReset());
                context.read<ConnectionBloc>().add(ConnectionsRequested(vendor.clientVendorId));
              }
            });
          },
          label: "Add new connection",
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
