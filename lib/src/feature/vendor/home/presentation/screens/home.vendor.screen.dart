import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/label_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/fallback.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/shimmer_loading.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.state.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/vendor/home/data/model/client.model.dart';
import 'package:smart_reload_system/src/feature/vendor/home/presentation/bloc/home/home.vendor.event.dart';
import 'package:smart_reload_system/src/feature/client/notification/presentation/screens/widget/notification_bell.widget.dart';
import 'package:smart_reload_system/src/feature/vendor/home/presentation/bloc/home/home.vendor.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/home/presentation/bloc/home/home.vendor.state.dart';
import 'package:smart_reload_system/src/feature/vendor/home/presentation/bloc/home/package_request.cubit.dart';
import 'package:smart_reload_system/src/feature/vendor/home/presentation/bloc/home/package_request.state.dart';

class HomeVendorScreen extends StatefulWidget {
  const HomeVendorScreen({super.key});

  @override
  State<HomeVendorScreen> createState() => _HomeVendorScreenState();
}

class _HomeVendorScreenState extends State<HomeVendorScreen> {

  List<Map<String, dynamic>> clientList = [];
  String vendorId = "";

  final Set<String> processedRequestIds = {};

  void handlePackageRequest1(Map<String, dynamic> requestMap) {

    print("REQUEST: $requestMap");
    print("LIST: $clientList");
    requestMap.forEach((key, value) {

      final request = (value as Map).cast<String, dynamic>();


      final index = clientList.indexWhere((client) =>
      client['client'].clientVendorId == request['clientVendorId'],
      );


      if (index == -1) return;

      if (request['status'] == false) {
        clientList[index]['count'] = clientList[index]['count'] - 1;
        setState(() {});
        return;
      }

      final updatedClient = {
        "client": clientList[index]['client'],
        "count": clientList[index]['count'] + 1,
      };
      clientList.removeAt(index);

      clientList.insert(0, updatedClient);

      setState(() {});
    });



  }

  // in your State class
  final Map<String, bool> _handledStatus = {};

  void handlePackageRequest(Map<String, dynamic> requestMap) {
    for (final entry in requestMap.entries) {
      if (entry.value is! Map) continue;
      final request = Map<String, dynamic>.from(entry.value as Map);

      final bool status = request['status'] == true;
      final bool wasTrue = _handledStatus[entry.key] ?? false;

      // Already handled with this same status, skip it
      if (wasTrue == status) continue;

      final index = clientList.indexWhere(
            (c) => c['client'].clientVendorId == request['clientVendorId'],
      );
      if (index == -1) continue;

      _handledStatus[entry.key] = status;

      final count = (clientList[index]['count'] as int?) ?? 0;

      if (status) {
        // false -> true: increment and move to top
        final item = clientList.removeAt(index);
        item['count'] = count + 1;
        clientList.insert(0, item);
      } else {
        // true -> false: decrement
        clientList[index]['count'] = count > 0 ? count - 1 : 0;
      }
    }

    if (mounted) setState(() {});
  }


  @override
  void initState() {
    super.initState();
    // Reset stale state on entry since HomeBloc is app-level and persists
    context.read<HomeVendorBloc>().add(const HomeDataReset());
    // Fetch fresh data
    context.read<HomeVendorBloc>().add(const HomeDataRequested());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PackageRequestCubit>().listenToPackageRequests(vendorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        String userName = "USER";

        if (sessionState is SessionAuthenticated) {
          userName = sessionState.user.fullName;
          vendorId = sessionState.user.uid;
        }

        return Scaffold(
          backgroundColor: AppColors.scaffoldVendor,
          appBar: customAppBar(
            isDark: true,
            title: userName,
            action: [NotificationBell(isVendor: true)],
          ),
          body: BlocListener<HomeVendorBloc, HomeVendorState>(
            listener: (context, state) {


              if (state is HomeFailure) {
                AppSnackbar.showError(context, state.message);
              }
              if(state is HomeSuccess){

                for(var client in state.data['clients']){
                  clientList.add({
                    "client": client,
                    "count": 0,
                  });
                }

                handlePackageRequest(state.data['packageRequests']);
                print("client.clientName");
                print(clientList);

              }


            },
            child: BlocListener<PackageRequestCubit, PackageRequestState>(
              listener: (context, state) {

                if (state is PackageRequestLoaded) {
                  print("state.result : ${state.requests}");

                  handlePackageRequest(state.requests);
                }
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeVendorBloc>().add(const HomeDataRequested());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: BlocBuilder<HomeVendorBloc, HomeVendorState>(
                  builder: (context, state) {
                    // Show shimmer loading
                     if (state is HomeLoading) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(Sizes.ssm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ShimmerBannerCard(),
                              const SizedBox(height: 10),
                              ShimmerLoading(
                                height: 18,
                                width: 120,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 12),
                              ShimmerVendorCard(),
                              ShimmerVendorCard(),
                              ShimmerVendorCard(),
                            ],
                          ),
                        ),
                      );
                    }

                    // Show actual content when success
                    if (state is HomeSuccess) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(Sizes.ssm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10.0,
                            children: [
                              // Display vendors
                              SubHeadlineText(text: "My Clients", isVendor: true),

                              if (clientList.isNotEmpty) ...{
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 10.0,
                                  children: clientList.map((client) {
                                    return _buildCustomTile(
                                      title: client['client'].clientName,
                                      phoneNumber: client['client'].clientPhone,
                                      count: client['count'],
                                      totalAmount: client['client'].totalPayable ?? 0.0,
                                      onTap: () {
                                        // Navigator.of(context).pushNamed(
                                        //   RouteConstants.connectionVendorScreen,
                                        //   arguments: cl,
                                        // );
                                      }
                                    );
                                  }).toList(),
                                ),
                              } else ...{
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: HelperFunctions.screenHeight(context)/3),
                                    child: TitleText(
                                      text: 'No clients available',
                                      color: AppColors.white,
                                      isBold: false,
                                    ),
                                  ),
                                ),
                              },
                            ],
                          ),
                        ),
                      );
                    }

                    // Fallback state
                    return FallbackWidget(
                        isVendor: true,
                        onPressed: () {
                          context.read<HomeVendorBloc>().add(const HomeDataRequested());
                        }
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomTile({
    required String title,
    required String phoneNumber,
    required int count,
    bool isActive = true,
    required double totalAmount,
    required Function() onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(Sizes.md),
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Color(0xFF40404E),//AppColors.darkContainers,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.15),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  spacing: 10.0,
                  children: [
                    CircleAvatar(
                      radius: 25.0,
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.8),
                      child: HeadlineText(
                        text: HelperFunctions.getInitials(title),
                        color: AppColors.white,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5.0,
                      children: [
                        TitleText(text: title, color: AppColors.white),
                        LabelText(
                          text: phoneNumber,
                          color: AppColors.darkGrey,
                        ),
                      ],
                    ),
                    Spacer(),
                    CircleAvatar(
                      radius: 18.0,
                      backgroundColor: AppColors.grey.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 0.3,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CChip(
                      label: isActive ? "Active" : "Inactive",
                      bgColor: isActive ? AppColors.green : AppColors.red,
                      enableStatus: true,
                      fontColor: AppColors.white,
                    ),
                    LabelText(
                      text: HelperFunctions.formatCurrency(totalAmount),
                      color: (totalAmount < 5000.00) ? AppColors.white : AppColors.red,
                      isBold: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        if(count > 0)...{
          Positioned(
            top: -5,
            right: -5,
            child: CircleAvatar(
              radius: 12.0,
              backgroundColor: AppColors.red,
              child: LabelText(
                text: count.toString(),
                color: AppColors.white,
                isBold: true,
              ),
            ),
          ),
        }

      ],
    );
  }
}
