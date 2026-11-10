import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/constants/svg_strings.dart';
import 'package:smart_reload_system/src/core/enums/connection_data.enum.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.state.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_bottom_sheet.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_elevated_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/empty_screen.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/sticky_tab_bar_delegate.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/svg_builder.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package/packaget.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package/package.event.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package/package.state.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/widgets/activated_package_card.widget.dart';
import 'package:smart_reload_system/src/core/error/error_logger.dart';

class ConnectionDetailsVendorScreen extends StatefulWidget {
  final ConnectionModel connectionModel;
  final String vendorId;
  const ConnectionDetailsVendorScreen({super.key, required this.connectionModel, required this.vendorId});

  @override
  State<ConnectionDetailsVendorScreen> createState() => _ConnectionDetailsVendorScreenState();
}

enum PackageFilter { all, pending, activated }

class _ConnectionDetailsVendorScreenState extends State<ConnectionDetailsVendorScreen> {
  final amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _isLoadingNotifier = ValueNotifier<bool>(false);
  late final ConnectionModel connectionModel;

  PackageFilter _selectedPackageFilter = PackageFilter.all;

  bool fetchingActPackage = true;
  List<PackageRequestModel> actPackageDetails = [];
  List<PackageRequestModel> allPackageDetails = [];

  List<PackageRequestModel> dataPackages = [];
  List<PackageRequestModel> voicePackages = [];
  List<PackageRequestModel> comboPackages = [];


  int expandId = -1;
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  bool isUtility = false;
  bool isMobile = false;
  String userName = "USER";

  @override
  void initState() {
    connectionModel = widget.connectionModel;
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) {
      userName = sessionState.user.fullName;
    }
    isMobile = connectionModel.connectionType.toLowerCase() == TelecomType.Mobile.name.toLowerCase();
    context.read<PackageBloc>().add(FetchActivatedPackages(connectionId: connectionModel.id!));
    super.initState();
  }
  
  List<PackageRequestModel> _filterPackages(List<PackageRequestModel> packages) {
    switch (_selectedPackageFilter) {
      case PackageFilter.pending:
        return packages.where((packageItem) => packageItem.activatedDate == null).toList();
      case PackageFilter.activated:
        return packages.where((packageItem) => packageItem.activatedDate != null).toList();
      case PackageFilter.all:
        return packages;
    }
  }

  void initValue(List<PackageRequestModel> packages){
    try{
      setState(() {
        allPackageDetails.clear();
        actPackageDetails.clear();
        dataPackages.clear();
        voicePackages.clear();
        comboPackages.clear();

        allPackageDetails = packages;

        for (var pc in packages) {
          if(pc.activatedDate == null || !HelperFunctions.isExpired(expDate: pc.expireDate!)){
            actPackageDetails.add(pc);
          }
        }

        for (var p in actPackageDetails) {
          if(p.packageModel?.packageType == PackageType.Data.name){
            dataPackages.add(p);
          }else if(p.packageModel?.packageType == PackageType.Voice.name){
            voicePackages.add(p);
          }else if(p.packageModel?.packageType == PackageType.Combo.name){
            comboPackages.add(p);
          }
        }
        fetchingActPackage = false;
        //show history only
        isUtility = (connectionModel.connectionCategory.toLowerCase() == ConCategory.Utility.name.toLowerCase()) || (connectionModel.connectionType.toLowerCase() == TelecomType.TV.name.toLowerCase());
      });
    }catch(e, st){
      ErrorLogger.log(
        e,
        location: 'ConnectionDetailsClientScreen.initValue',
        stackTrace: st,
      );
      setState(() => fetchingActPackage = false);
      AppSnackbar.showError(context, "Failed to load activated packages");
    }
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
    screenHeight = HelperFunctions.screenHeight(context);
    return BlocListener<PackageBloc, PackageState>(
      listener: (context, state) {
        if(state is PackageLoading){
          _isLoadingNotifier.value = state.requesting;
          fetchingActPackage = state.fetchingActPackage;
        }

        if (state is PackageSuccess) {
          if((state.isRequested != null) && (state.isRequested == true)){
            Navigator.of(context).pop();
            AppSnackbar.showSuccess(context, 'Reload request submitted!');
            context.read<PackageBloc>().add(FetchActivatedPackages(connectionId: connectionModel.id!));
          }
          if(state.actPackages != null){
            initValue(state.actPackages!);
          }

        } else if (state is PackageFailure) {
          setState(() => fetchingActPackage = false);
          AppSnackbar.showError(context, state.message);
        }
      },

      child: Scaffold(
        backgroundColor: AppColors.scaffoldVendor,
        appBar: customAppBar(
          isDark: true,
          onPressed: () => Navigator.of(context).pop(),
          icon: Icons.arrow_back_ios_new_rounded,
          title: "Connection Details",
        ),
        body: Visibility(
          visible: !fetchingActPackage,
          replacement: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<PackageBloc>().add(FetchActivatedPackages(connectionId: connectionModel.id!));
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Visibility(
              visible: !isUtility,
              replacement: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.sm),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildList(
                        packages: dataPackages,
                        emptyMsg: "No Data packages activated!",
                      ),
                    ],
                  ),
                ),
              ),
              child: Visibility(
                visible: isMobile,
                replacement: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(Sizes.sm),
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildList(
                          packages: dataPackages,
                          emptyMsg: "No Data packages activated!",
                          topPadding: true,
                        ),
                      ],
                    ),
                  ),
                ),
                child: DefaultTabController(
                  length: 3,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        // Everything above the tabs — scrolls away with the page.
                        SliverToBoxAdapter(child: _buildHeader()),

                        // Tab bar — pins to the top once the header above scrolls past it.
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: StickyTabBarDelegate(
                            TabBar(
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.grey,
                              indicatorColor: AppColors.primary,
                              labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                              tabs: const [
                                Tab(text: 'Data'),
                                Tab(text: 'Voice'),
                                Tab(text: 'Combo'),
                              ],
                            ),
                            backgroundColor: AppColors.scaffoldVendor,
                          ),
                        ),
                      ];
                    },
                    body: Padding(
                      padding: const EdgeInsets.fromLTRB(Sizes.sm, 0.0, Sizes.sm, 0.0),
                      child: TabBarView(
                        children: [
                          /// Data
                          _buildList(
                            packages: dataPackages,
                            emptyMsg: "No Data packages activated!",
                          ),

                          /// Voice
                          _buildList(
                            packages: voicePackages,
                            emptyMsg: "No Voice packages activated!",
                          ),

                          /// Combo
                          _buildList(
                            packages: comboPackages,
                            emptyMsg: "No Combo packages activated!",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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

              if(isUtility){
                showAmountSheet();
                return;
              }

              final result = await AppBottomSheet.showRadioSelect(
                context,
                isDark: true,
                title: 'Choose',
                askConfirm: false,
                options: ['Select a package', 'Enter Amount'],
                selectedValue: '',
              );

              if (result != null) {
                if(result == 'Select a package' && context.mounted){
                  Navigator.of(context).pushNamed(
                      RouteConstants.packageDetailsClientScreen,
                      arguments: (vendorId: widget.vendorId, connectionModel: connectionModel),
                  );
                }else{
                  showAmountSheet();
                }
              }
            },
            bgColor: connectionModel.status ? null : AppColors.darkerGrey,
            label: "Request Reload",
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  void showAmountSheet(){
    amountController.clear();
    AppBottomSheet.showForm(
      isDark: true,
      context,
      title: 'Enter Amount',
      form: Form(
        key: _formKey,
        child: TextFormField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: AppColors.white),
          decoration: const InputDecoration(labelText: 'Amount', labelStyle: TextStyle(color: AppColors.white)),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter amount';
            if (double.parse(value) < 50.0) return 'Please enter minimum amount Rs. 50.00';
            return null;
          },
        ),
      ),
      buttonText: 'Request Reload',
      isLoading: _isLoadingNotifier,
      onSubmit: () {
        if(_formKey.currentState!.validate()){
          final data = PackageRequestModel(
            clientVendorId: connectionModel.clientVendorId,
            vendorId: widget.vendorId,
            connectionId: connectionModel.id!,
            requestDate: DateTime.now(),
            amount: double.parse(amountController.text),
          );

          context.read<PackageBloc>().add(PackageRequest(data, userName));
        }
      },
    );
  }

  Widget _buildList({required List<PackageRequestModel> packages, required String emptyMsg, bool topPadding = false}){
    final filteredPackages = _filterPackages(packages);

    return Visibility(
      visible: filteredPackages.isNotEmpty,
      replacement: Padding(
        padding: EdgeInsets.only(top: topPadding ? screenHeight/6 : 0.0),
        child: EmptyScreenWidget(message: emptyMsg, isDark: true),
      ),
      child: ListView.builder(
        itemCount: filteredPackages.length,
        shrinkWrap: !isMobile,
        scrollDirection: Axis.vertical,
        physics: isMobile ? null : NeverScrollableScrollPhysics(),
        padding: EdgeInsetsGeometry.only(bottom: 100),
        itemBuilder: (context, index){
          final item = filteredPackages[index];

          return ActivatedPackageCard(
            isDark: true,
            onActionTap: (){
              ///open a bottom sheet contain a form to enter amount and activated button
            },
            onTap: () {
              if(expandId == index) {
                setState(() => expandId = -1);
              }else {
                setState(() => expandId = index);
              }
            },
            title: item.packageModel?.packageName ?? "-",
            price: item.amount ?? 0.0,
            expDate: item.expireDate,
            reqDate: item.requestDate,
            isExpand: expandId == index,
            description: item.packageModel?.packageDescription ?? "-",
            actDate: item.activatedDate,
            status: (item.activatedDate != null),
            validity: HelperFunctions.formatValidity(item.packageModel?.packageValidity, item.packageModel?.validityPeriod) ?? "",
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
                colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                TitleText(text: connectionModel.connectionName, color: AppColors.white),
                CircleAvatar(
                  radius: 5,
                  backgroundColor: connectionModel.isActive ? AppColors.green : AppColors.red,
                ),
              ],
            ),
            subtitle: SubTitleText(text: connectionModel.connectionNumber, color: AppColors.grey),
          ),
          Row(
            spacing: 5,
            children: [
              CChip(label: connectionModel.connectionType, fontColor: AppColors.white),
              if (connectionModel.billingType != null) ...{
                CChip(
                  label: connectionModel.billingType!,
                  bgColor: AppColors.primary,
                  fontColor: AppColors.white,
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
              color: AppColors.darkContainers,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    BodyText(text: "Reload History", color: AppColors.white),
                    TitleText(text: "Total reloads (${allPackageDetails.length})", color: AppColors.white),
                    SubTitleText(text: "click to see all", color: AppColors.grey),
                    // SubTitleText(text: "Last request: ${HelperFunctions.formatDateTime(actPackageDetails.last.requestDate)}"),
                  ],
                ),
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pushNamed(
                      RouteConstants.reloadHistoryClientScreen,
                      arguments: (
                       packageList: allPackageDetails,
                       connection: connectionModel,
                       isMobile: isMobile,
                      ),
                    );
                  },
                  child: Text("See All"),
                ),
              ],
            ),
          ),
          SubHeadlineText(text: "Activated Packages", color: AppColors.white),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPackageFilter = PackageFilter.all),
                    child: CChip(
                      label: 'All',
                      bgColor: _selectedPackageFilter == PackageFilter.all ? AppColors.primary : AppColors.grey,
                      fontColor: _selectedPackageFilter == PackageFilter.all ? AppColors.white : AppColors.darkerGrey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPackageFilter = PackageFilter.pending),
                    child: CChip(
                      label: 'Pending',
                      bgColor: _selectedPackageFilter == PackageFilter.pending ? AppColors.warning : AppColors.grey,
                      fontColor: _selectedPackageFilter == PackageFilter.pending ? AppColors.white : AppColors.darkerGrey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPackageFilter = PackageFilter.activated),
                    child: CChip(
                      label: 'Activated',
                      bgColor: _selectedPackageFilter == PackageFilter.activated ? AppColors.buttonGreen : AppColors.grey,
                      fontColor: _selectedPackageFilter == PackageFilter.activated ? AppColors.white : AppColors.darkerGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
