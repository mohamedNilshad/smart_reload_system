import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_elevated_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/empty_screen.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/fallback.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/shimmer_loading.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.event.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.state.dart' as c;
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
  final _isLoadingNotifier = ValueNotifier<bool>(false);
  double screenWidth = 0.0;
  final List<Map<String, String>> connectionsNumbers = [];

  @override
  void initState() {
    super.initState();
    context.read<ConnectionBloc>().add(const ConnectionsReset());
    context.read<ConnectionBloc>().add(ConnectionsRequested(widget.clientVendorId));
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
              return FallbackWidget(
                  onPressed: () {
                    context.read<ConnectionBloc>().add(ConnectionsRequested(widget.clientVendorId));
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

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Sizes.ssm, Sizes.ssm, Sizes.ssm, 100 ),
                  child: Column(
                    children: [
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
                                  arguments: connection,
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

                      Container(
                        margin: EdgeInsets.fromLTRB(0.0, Sizes.lg, 0.0, Sizes.sm),
                        alignment: AlignmentGeometry.topStart,
                        child: TitleText(text: "Pending Connections"),
                      ),

                      if(pendingList.isEmpty)...{
                        BodyText(text: "No connections!",),
                      }else...{
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
              arguments: (id: widget.clientVendorId, connectionNumbers: connectionsNumbers)
            ).then((result){

              if(result != null && result == true && context.mounted){
                context.read<ConnectionBloc>().add(const ConnectionsReset());
                context.read<ConnectionBloc>().add(ConnectionsRequested(widget.clientVendorId));
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
