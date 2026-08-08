import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/constants/svg_strings.dart';
import 'package:smart_reload_system/src/core/enums/connection_data.enum.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_bottom_sheet.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_chip.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/sticky_tab_bar_delegate.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/svg_builder.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package/packaget.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package/package.event.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package/package.state.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/widgets/package_card.widget.dart';

class PackageDetailsClientScreen extends StatefulWidget {
  final ConnectionModel connectionModel;
  const PackageDetailsClientScreen({super.key, required this.connectionModel});

  @override
  State<PackageDetailsClientScreen> createState() => _PackageDetailsClientScreenState();
}

class _PackageDetailsClientScreenState extends State<PackageDetailsClientScreen> {
  final _isLoadingNotifier = ValueNotifier<bool>(false);
  late final ConnectionModel connectionModel;

  bool fetchingPackages = true;
  List<PackageModel> packageDetails = [];
  List<PackageModel> dataPackages = [];
  List<PackageModel> voicePackages = [];
  List<PackageModel> comboPackages = [];

  bool isMobile = true;

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

      isMobile = (connectionModel.connectionType == TelecomType.Mobile.name);
      fetchingPackages = false;
    });
  }

  @override
  void dispose() {
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = HelperFunctions.screenWidth(context);
    return BlocListener<PackageBloc, PackageState>(
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
          title: "Package Details",
        ),
        body: Visibility(
          visible: !fetchingPackages,
          replacement: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<PackageBloc>().add(FetchPackages(
                  type: connectionModel.connectionType,
                  serviceProvider: connectionModel.serviceProvider!
              ));
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Visibility(
              visible: isMobile,
              replacement: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.sm),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildList(packages: dataPackages, isMobile: isMobile),
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
                            unselectedLabelColor: AppColors.darkerGrey,
                            indicatorColor: AppColors.primary,
                            labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
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
                        _buildList(packages: dataPackages, isMobile: isMobile),

                        /// Voice
                        _buildList(packages: voicePackages, isMobile: isMobile),

                        /// Combo
                        _buildList(packages: comboPackages, isMobile: isMobile),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList({required List<PackageModel> packages, required bool isMobile}){
    return ListView.builder(
      itemCount: packages.length,
      shrinkWrap: !isMobile,
      scrollDirection: Axis.vertical,
      physics: isMobile ? null : NeverScrollableScrollPhysics(),
      itemBuilder: (context, index){
        final item = packages[index];
        int count = (item.packageValidity).toInt();
        String validity = "$count ${item.validityPeriod}${count >1 ? 's' : ''}";

        return PackageCard(
          onTap: () {
            AppBottomSheet.showInfo(
              context,
              title: item.packageName,
              subtitle: item.packageDescription,
              buttonText: "Request Reload",
              isLoading: _isLoadingNotifier,
              points: [
                "Type: ${item.packageType}",
                "Validity: $validity",
                "Price: Rs. ${item.packagePrice.toStringAsFixed(0)}",
              ],
              onPressed: (){

                final data = PackageRequestModel(
                  clientVendorId: connectionModel.clientVendorId,
                  connectionId: connectionModel.id!,
                  requestDate: DateTime.now(),
                  packageDetailsId: item.id,
                  amount: item.packagePrice,
                );

                context.read<PackageBloc>().add(PackageRequest(data));
              }
            );
          },
          title: item.packageName,
          price: item.packagePrice,
          description: item.packageDescription,
          validity: validity,
        );
      },
    );
  }

  Widget _buildHeader() {
    return ListTile(
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
      title: TitleText(text: connectionModel.serviceProvider!),
      subtitle: Row(
        children: [
          CChip(label: connectionModel.connectionType),
        ],
      ),
    );
  }
}