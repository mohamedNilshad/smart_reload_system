import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/data/model/Invoice_pdf_data.model.dart';
import 'package:smart_reload_system/src/core/domain/entity/user.entity.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.state.dart';
import 'package:smart_reload_system/src/core/presentation/progress_indicators/custom.circular_progress_indicator.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_bottom_sheet.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_elevated_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/empty_screen.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/fallback.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/shimmer_loading.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
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
import 'package:smart_reload_system/src/feature/vendor/home/data/model/client.model.dart';

enum ConnectionFilter { all, pending, activated }

class ConnectionListVendorScreen extends StatefulWidget {
  final ClientModel client;
  const ConnectionListVendorScreen({super.key, required this.client});

  @override
  State<ConnectionListVendorScreen> createState() => _ConnectionListVendorScreenState();
}

class _ConnectionListVendorScreenState extends State<ConnectionListVendorScreen> {

  double screenWidth = 0.0;
  final List<Map<String, String>> connectionsNumbers = [];

  bool payableAmountLoading = true;
  double paymentAmount = 0.0;
  List<PackageRequestModel> payableList = [];
  late ClientModel client;
  late UserEntity user;
  ConnectionFilter _selectedFilter = ConnectionFilter.all;

  InvoicePdfData? invoiceData;
  String serviceCharge = "0+0";

  @override
  void initState() {
    super.initState();
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) user = sessionState.user;

    client = widget.client;
    context.read<ConnectionBloc>().add(const ConnectionsReset());
    context.read<ConnectionBloc>().add(ConnectionsRequested(client.clientVendorId));

  }

  @override
  void dispose() {
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

  List<ConnectionModel> _filteredConnections(List<ConnectionModel> connections) {
    switch (_selectedFilter) {
      case ConnectionFilter.pending:
        return connections.where((connection) => connection.status == false).toList();
      case ConnectionFilter.activated:
        return connections.where((connection) => connection.status == true).toList();
      case ConnectionFilter.all:
        return connections;
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

      final vendorTemp = VendorModel(
        clientVendorId: client.clientVendorId,
        vendorId: user.uid,
        vendorName: user.fullName,
        vendorEmail: user.email,
        vendorPhone: user.phoneNumber,
        connectionCount: client.connectionCount,
        currentPaymentBalance: client.totalPayable,
        lastPaidAmount: client.lastPaidAmount,
        lastPaidDate: client.lastPaidDate,
      );

      invoiceData = InvoicePdfData(
        vendor: vendorTemp,
        clientName: client.clientName,
        clientEmail: client.clientEmail,
        clientPhone: client.clientPhone,
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
      backgroundColor: AppColors.scaffoldVendor,
      appBar: customAppBar(
        isDark: true,
        onPressed: () => Navigator.of(context).pop(),
        icon: Icons.arrow_back_ios_new_rounded,
        title: client.clientName,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ConnectionBloc>().add(const ConnectionsReset());
          context.read<ConnectionBloc>().add(ConnectionsRequested(client.clientVendorId));
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: BlocConsumer<ConnectionBloc, c.ConnectionState>(
          listener: (context, state){
            if (state is c.ConnectionSuccess){
              context.read<PaymentClientBloc>().add(FetchPayableDetails(clientVendorId :client.clientVendorId));

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
                        isDark: true,
                        height: 90,
                        width: screenWidth,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      ShimmerLoading(
                        isDark: true,
                        height: 15,
                        width: screenWidth/2,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      ShimmerLoading(
                        isDark: true,
                        height: 130,
                        width: screenWidth,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      ShimmerLoading(
                        isDark: true,
                        height: 130,
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
                isDark: true,
                onPressed: () => context.read<ConnectionBloc>().add(
                    ConnectionsRequested(client.clientVendorId)
                ),
              );
            }

            if (state is c.ConnectionSuccess) {
              if (state.connections.isEmpty) {
                return EmptyScreenWidget(isDark: true);
              }

              initValues(state.connections);

              return BlocListener<PaymentClientBloc, PaymentClientState>(
                listener: (context, pState) {

                  if (pState is PayableSuccess) {
                    setState(() {
                      payableList = pState.payableList;
                      serviceCharge = pState.serviceCharge;

                      calPayAmount();
                    });

                  }
                },
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
                              if((paymentAmount != 0.0))...{
                                TextButton(
                                  onPressed: (){
                                    InvoiceItemsBottomSheet.show(
                                      context,
                                      isDark: true,
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
                              return EmptyScreenWidget(
                                isDark: true,
                                padding: EdgeInsetsGeometry.only(top: HelperFunctions.screenHeight(context)/4.5),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 10.0,
                              children: filteredConnections.map((connection) {
                                final bool isActivated = connection.status == true;
                                return ConnectionCard(
                                  isDark: true,
                                  onTap: () async {
                                    if (isActivated) {
                                      Navigator.pushNamed(
                                        context,
                                        RouteConstants.connectionDetailsVendorScreen,
                                        arguments: (vendorId: user.uid, connectionModel: connection, client: client),
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        RouteConstants.connectionDetailsClientScreen,
                                        arguments: connection,
                                      );
                                    }
                                  },
                                  payableAmount: paymentAmount,
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
            Navigator.of(context).pushNamed(
              RouteConstants.addNewConnectionClientScreen,
              arguments: (
              clientVendorId: client.clientVendorId,
              connectionNumbers: connectionsNumbers,
              isDark: true,
              )
            ).then((result){

              if(result != null && result == true && context.mounted){
                context.read<ConnectionBloc>().add(const ConnectionsReset());
                context.read<ConnectionBloc>().add(ConnectionsRequested(client.clientVendorId));
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
