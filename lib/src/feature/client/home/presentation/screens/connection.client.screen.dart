import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.event.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.state.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/app_data.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/data/model/Invoice_pdf_data.model.dart';
import 'package:smart_reload_system/src/core/enums/connection_data.enum.dart';
import 'package:smart_reload_system/src/core/presentation/progress_indicators/custom.circular_progress_indicator.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_bottom_sheet.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_elevated_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
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

enum ConnectionFilter { all, pending, activated }

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
  ConnectionFilter _selectedFilter = ConnectionFilter.all;

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

  // List<ConnectionModel> _filteredConnections(List<ConnectionModel> connections) {
  //   switch (_selectedFilter) {
  //     case ConnectionFilter.pending:
  //       return connections.where((connection) => connection.status == false).toList();
  //     case ConnectionFilter.activated:
  //       return connections.where((connection) => connection.status == true).toList();
  //     case ConnectionFilter.all:
  //       return connections;
  //   }
  // }

  List<ConnectionModel> _filteredConnections(List<ConnectionModel> connections) {
    final List<ConnectionModel> filtered;

    switch (_selectedFilter) {
      case ConnectionFilter.pending:
        filtered = connections.where((connection) => connection.status == false).toList();
        break;
      case ConnectionFilter.activated:
        filtered = connections.where((connection) => connection.status == true).toList();
        break;
      case ConnectionFilter.all:
      // Create a copy so .sort() does not mutate the original state list in place
        filtered = List<ConnectionModel>.of(connections);
        break;
    }

    filtered.sort((a, b) {
      final dateA = a.lastReloadDate;
      final dateB = b.lastReloadDate;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;  // Push connections with null date to the bottom
      if (dateB == null) return -1;

      return dateB.compareTo(dateA); // Descending (newest reload first)
    });

    return filtered;
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
                          vendorComAmount: invoiceData!.vendorCommissionAmount,
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

                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedFilter = ConnectionFilter.all),
                                  child: CChip(
                                    label: 'All',
                                    bgColor: _selectedFilter == ConnectionFilter.all ? AppColors.primary : AppColors.grey,
                                    fontColor: _selectedFilter == ConnectionFilter.all ? AppColors.white : AppColors.darkerGrey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedFilter = ConnectionFilter.pending),
                                  child: CChip(
                                    label: 'Pending',
                                    bgColor: _selectedFilter == ConnectionFilter.pending ? AppColors.warning : AppColors.grey,
                                    fontColor: _selectedFilter == ConnectionFilter.pending ? AppColors.white : AppColors.darkerGrey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedFilter = ConnectionFilter.activated),
                                  child: CChip(
                                    label: 'Activated',
                                    bgColor: _selectedFilter == ConnectionFilter.activated ? AppColors.buttonGreen : AppColors.grey,
                                    fontColor: _selectedFilter == ConnectionFilter.activated ? AppColors.white : AppColors.darkerGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Builder(
                          builder: (context) {
                            final filteredConnections = _filteredConnections(state.connections);
                            if (filteredConnections.isEmpty) {
                              return BodyText(text: "No connections!", color: AppColors.darkerGrey);
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 10.0,
                              children: filteredConnections.map((connection) {
                                final bool isActivated = connection.status == true;
                                return ConnectionCard(
                                  onTap: () async {
                                    if (isActivated) {
                                      Navigator.pushNamed(
                                        context,
                                        RouteConstants.connectionDetailsClientScreen,
                                        arguments: (vendorId: vendor.vendorId, connectionModel: connection, paymentAmount: paymentAmount),
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        RouteConstants.connectionDetailsClientScreen,
                                        arguments: connection,
                                      );
                                    }
                                  },
                                  conId: connection.id,
                                  payableAmount: paymentAmount,
                                  showAIButton: (connection.connectionCategory != ConCategory.Utility.name) && (connection.connectionType != TelecomType.TV.name),
                                  conNumber: connection.connectionNumber,
                                  lastDate: connection.lastReloadDate,
                                  conName: connection.connectionName,
                                  isActive: connection.isActive,
                                  conType: connection.connectionType,
                                  conPlan: connection.billingType,
                                  status: isActivated,
                                );
                              }).toList(),
                            );
                          },
                        ),
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
            if(paymentAmount >= AppData.lockAmount) {
              AppSnackbar.showInfo(context, AppData.lockAmountMessage);
              return;

            }
            Navigator.of(context).pushNamed(
              RouteConstants.addNewConnectionClientScreen,
              arguments: (clientVendorId: vendor.clientVendorId, connectionNumbers: connectionsNumbers, isDark: false)
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
