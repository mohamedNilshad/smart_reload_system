import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/constants/svg_strings.dart';
import 'package:smart_reload_system/src/core/enums/connection_data.enum.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_bottom_sheet.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_elevated_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/svg_builder.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package/packaget.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package/package.event.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package/package.state.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/widgets/activated_package_card.widget.dart';

class ConnectionDetailsClientScreen extends StatefulWidget {
  final ConnectionModel connectionModel;
  const ConnectionDetailsClientScreen({super.key, required this.connectionModel});

  @override
  State<ConnectionDetailsClientScreen> createState() => _ConnectionDetailsClientScreenState();
}

class _ConnectionDetailsClientScreenState extends State<ConnectionDetailsClientScreen> {
  final amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _isLoadingNotifier = ValueNotifier<bool>(false);
  late final ConnectionModel connectionModel;

  bool fetchingPackages = false;
  List<PackageModel> packageDetails = [];
  List<PackageModel> dataPackages = [];
  List<PackageModel> voicePackages = [];
  List<PackageModel> comboPackages = [];

  int expandId = -1;
  double screenWidth = 0.0;

  @override
  void initState() {
    connectionModel = widget.connectionModel;

    context.read<PackageBloc>().add(FetchPackages(
        type: connectionModel.connectionType,
        serviceProvider: connectionModel.serviceProvider!
    ));
    super.initState();
  }
  
  void initValue(){
    setState(() {
      for (var p in packageDetails) {
        if(p.packageType == PackageType.Data.name){
          dataPackages.add(p);
        }else if(p.packageType == PackageType.Voice.name){
          voicePackages.add(p);
        }else if(p.packageType == PackageType.Combo.name){
          comboPackages.add(p);
        }
      }
      fetchingPackages = false;
      // dataPackages = packageDetails.where((p) => p.packageType == PackageType.Data.name).toList();
      // voicePackages = packageDetails.where((p) => p.packageType == PackageType.Voice.name).toList();
      // comboPackages = packageDetails.where((p) => p.packageType == PackageType.Combo.name).toList();
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = HelperFunctions.screenWidth(context);
    return DefaultTabController(
      length: 3,
      child: BlocListener<PackageBloc, PackageState>(
        listener: (context, state) {
          if(state is PackageLoading){
            _isLoadingNotifier.value = state.requesting;
            fetchingPackages = state.fetching;
          }

          if (state is PackageSuccess) {
            if((state.isRequested != null) && (state.isRequested == true)){
              Navigator.of(context).pop();
              AppSnackbar.showSuccess(context, 'Reload request submitted!');
            }
            if(state.packages != null){
              packageDetails = state.packages!;
              initValue();
            }

          } else if (state is PackageFailure) {
            setState(() => fetchingPackages = false);
            AppSnackbar.showError(context, state.message);
          }
        },

        child: Scaffold(
          appBar: customAppBar(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.arrow_back_ios_new_rounded,
            title: "Connection Details",
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // context.read<HomeBloc>().add(const HomeDataRequested());
              // await Future.delayed(const Duration(milliseconds: 500));
            },
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // Everything above the tabs — scrolls away with the page.
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(Sizes.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10.0,
                        children: [
                          ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: CSvgBuilder(
                                path: SvgStrings.box,
                                colorFilter: ColorFilter.mode(AppColors.black, BlendMode.srcIn),
                              ),
                            ),
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 10,
                              children: [
                                TitleText(text: connectionModel.connectionName),
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor: connectionModel.isActive ? AppColors.green : AppColors.red,
                                ),
                              ],
                            ),
                            subtitle: SubTitleText(text: connectionModel.connectionNumber, color: AppColors.darkerGrey),
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              CChip(label: connectionModel.connectionType),
                              if (connectionModel.billingType != null) ...{
                                CChip(
                                  label: connectionModel.billingType!,
                                  bgColor: AppColors.primary,
                                  fontColor: AppColors.primary,
                                ),
                              },
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(Sizes.ssm),
                            margin: EdgeInsets.only(bottom: Sizes.ssm),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border(left: BorderSide(color: AppColors.primary, width: 5.0)),
                              color: AppColors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 5,
                                  children: [
                                    SubTitleText(text: "Last Reload Date: 25 Jul 2026"),
                                    TitleText(text: "Package Title"),
                                    BodyText(text: "Package description"),
                                  ],
                                ),
                                TextButton(
                                  onPressed: (){},
                                  child: Text("See All"),
                                ),
                              ],
                            ),
                          ),
                          SubHeadlineText(text: "Activated Packages"),
                        ],
                      ),
                    ),
                  ),

                  // Tab bar — pins to the top once the header above scrolls past it.
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyTabBarDelegate(
                      TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.darkerGrey,
                        indicatorColor: AppColors.primary,
                        labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                        tabs: const [
                          Tab(text: 'Data'),
                          Tab(text: 'Voice'),
                          Tab(text: 'Combo'),
                        ],
                      ),
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ];
              },
              body: Padding(
                padding: const EdgeInsets.fromLTRB(Sizes.sm, 0.0, Sizes.sm, 0.0),
                child: TabBarView(
                  children: [
                    /// Data
                    ListView.builder(
                      itemCount: dataPackages.length,
                      itemBuilder: (context, index){
                        return Padding(
                          padding:  EdgeInsets.only(bottom: (index == 9) ? 80 : 0.0),
                          child: ActivatedPackageCard(
                            onTap: () {
                              if(expandId == index) {
                                setState(() => expandId = -1);
                              }else {
                                setState(() => expandId = index);
                              }
                            },
                            title: dataPackages[index].packageName,
                            subtitle: dataPackages[index].packagePrice.toString(),
                            expDate: DateTime(2026, 4),
                            isExpand: expandId == index,
                            description: dataPackages[index].packageDescription,

                          ),
                        );
                      },
                    ),

                    /// Voice
                    ListView.builder(
                      itemCount: voicePackages.length,
                      itemBuilder: (context, index){
                        return Padding(
                          padding:  EdgeInsets.only(bottom: (index == 9) ? 80 : 0.0),
                          child: ActivatedPackageCard(
                            onTap: () {
                              if(expandId == index) {
                                setState(() => expandId = -1);
                              }else {
                                setState(() => expandId = index);
                              }
                            },
                            title: voicePackages[index].packageName,
                            subtitle: voicePackages[index].packagePrice.toString(),
                            expDate: DateTime(2026, 4),
                            isExpand: expandId == index,
                            description: voicePackages[index].packageDescription,
                          ),
                        );
                      },
                    ),


                    /// Combo
                    ListView.builder(
                      itemCount: comboPackages.length,
                      itemBuilder: (context, index){
                        return Padding(
                          padding:  EdgeInsets.only(bottom: (index == 9) ? 80 : 0.0),
                          child: ActivatedPackageCard(
                            onTap: () {
                              if(expandId == index) {
                                setState(() => expandId = -1);
                              }else {
                                setState(() => expandId = index);
                              }
                            },
                            title: comboPackages[index].packageName,
                            subtitle: comboPackages[index].packagePrice.toString(),
                            expDate: DateTime(2026, 4),
                            isExpand: expandId == index,
                            description: comboPackages[index].packageDescription,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
            child: CElevatedButton(
              onPressed: () async {
                if(!connectionModel.status){
                  AppSnackbar.showInfo(context, "Waiting for connection approve");
                  return;
                }


                final result = await AppBottomSheet.showRadioSelect(
                  context,
                  title: 'Choose',
                  askConfirm: false,
                  options: ['Select a package', 'Enter Amount'],
                  selectedValue: '',
                );

                if (result != null) {
                  if(result == 'Select a package' && context.mounted){
                    Navigator.of(context).pushNamed(RouteConstants.packageDetailsClientScreen, arguments: connectionModel);
                  }else{
                    amountController.clear();
                    AppBottomSheet.showForm(
                      context,
                      title: 'Enter Amount',
                      form: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Amount'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter amount';
                            if (double.parse(value) < 50.0) return 'Please enter minimum amount Rs. 50.00';
                            return null;
                          },
                        ),
                      ),
                      buttonText: 'Continue',
                      isLoading: _isLoadingNotifier,
                      onSubmit: () {
                        if(amountController.text.isNotEmpty && _formKey.currentState!.validate()){
                          final data = PackageRequestModel(
                            clientVendorId: connectionModel.clientVendorId,
                            connectionId: connectionModel.id!,
                            requestDate: DateTime.now(),
                            amount: double.parse(amountController.text),
                          );

                          context.read<PackageBloc>().add(PackageRequest(data));
                        }
                      },
                    );
                  }
                }
              },
              bgColor: connectionModel.status ? null : AppColors.darkerGrey,
              label: "Request Reload",
            ),
          ),

          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _StickyTabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar || oldDelegate.backgroundColor != backgroundColor;
  }
}