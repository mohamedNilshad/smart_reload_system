import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.event.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_bottom_sheet.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/fallback.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/shimmer_loading.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection.event.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection.state.dart' as c;
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/widgets/connection_card.widget.dart';

class ConnectionClientScreen extends StatefulWidget {
  final String name;
  final String clientVendorId;
  const ConnectionClientScreen({
    super.key,
    required this.name,
    required this.clientVendorId,
  });

  @override
  State<ConnectionClientScreen> createState() => _ConnectionClientScreenState();
}

class _ConnectionClientScreenState extends State<ConnectionClientScreen> {
  final amountController = TextEditingController();
  double screenWidth = 0.0;

  @override
  void initState() {
    super.initState();
    context.read<ConnectionBloc>().add(const ConnectionsReset());
    context.read<ConnectionBloc>().add(ConnectionsRequested(widget.clientVendorId));
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = HelperFunctions.screenWidth(context);
    return Scaffold(
      appBar: customAppBar(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icons.arrow_back_ios_new_rounded,
        title: widget.name,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ConnectionBloc>().add(const ConnectionsReset());
          context.read<ConnectionBloc>().add(ConnectionsRequested(widget.clientVendorId));
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: BlocBuilder<ConnectionBloc, c.ConnectionState>(
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
              debugPrint(state.message);
              return FallbackWidget(
                  onPressed: () {
                    context.read<ConnectionBloc>().add(ConnectionsRequested(widget.clientVendorId));
                  }
              );
            }

            if (state is c.ConnectionSuccess) {
              if (state.connections.isEmpty) {
                return const Center(child: Text('No connections found.'));
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.ssm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10.0,
                    children: state.connections.map((connection) {
                      return InkWell(
                        onTap: () async {

                          Navigator.pushNamed(
                            context,
                            RouteConstants.connectionDetailsClientScreen,
                            arguments: (
                            clientVendorId: connection.clientVendorId,
                            connectionId: connection.id,
                            conName: connection.conName,
                            conNumber: connection.conNumber,
                            status: connection.status,
                            conType: connection.conType,
                            conPlan: connection.conPlan,
                          ),
                          );
                        },
                        child: ConnectionCard(
                          onReloadTap: () async{
                            final result = await AppBottomSheet.showRadioSelect(
                              context,
                              title: 'Choose',
                              options: ['Select a package', 'Enter Amount'],
                              selectedValue: 'Select a package',
                            );
                            if (result != null) {
                              // use result
                              if(result == 'Select a package'){
                                //navigate to package screen
                              }else{
                                AppBottomSheet.showForm(
                                  context,
                                  title: 'Enter Amount',
                                  form: TextFormField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Amount'),
                                  ),
                                  buttonText: 'Continue',
                                  // isLoading: ,
                                  onSubmit: () {
                                    if(amountController.text.isNotEmpty){
                                      context.read<PaymentBloc>().add(
                                        StartPaymentRequested(
                                          orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
                                          amount: 500.00,
                                          itemDescription: 'Mobile Reload',
                                          firstName: 'Saman',
                                          lastName: 'Perera',
                                          email: 'saman@example.com',
                                          phone: '0771234567',
                                          address: 'No.1, Galle Road',
                                          city: 'Colombo',
                                        ),
                                      );
                                    }
                                    // Navigator.of(context).pop();
                                    // proceed with amountController.text
                                  },
                                );
                              }
                            }
                          },
                          conNumber: connection.conNumber,
                          lastDate: connection.lastDate,
                          conName: connection.conName,
                          status: connection.status,
                          conType: connection.conType,
                          conPlan: connection.conPlan,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
