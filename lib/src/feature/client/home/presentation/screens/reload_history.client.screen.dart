import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/enums/connection_data.enum.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/empty_screen.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/sticky_tab_bar_delegate.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/widgets/all_act_package_card.widget.dart';

class ReloadHistoryClientScreen extends StatefulWidget {
  final List<PackageRequestModel> packageList;
  final ConnectionModel connection;
  final bool isMobile;
  const ReloadHistoryClientScreen({super.key, required this.packageList, required this.isMobile, required this.connection});

  @override
  State<ReloadHistoryClientScreen> createState() => _ReloadHistoryClientScreenState();
}

class _ReloadHistoryClientScreenState extends State<ReloadHistoryClientScreen> {
  double screenWidth = 0.0;
  double screenHeight = 0.0;

  List<PackageRequestModel> selectedPackageList = [];
  List<PackageRequestModel> allPackageDetails = [];

  List<PackageRequestModel> dataPackages = [];
  List<PackageRequestModel> voicePackages = [];
  List<PackageRequestModel> comboPackages = [];

  double totalPrice = 0.0;

  late final ConnectionModel connection;

  @override
  void initState() {
    initValue(widget.packageList);
    connection = widget.connection;
    super.initState();
  }

  void initValue(List<PackageRequestModel> packages){
    setState(() {
      allPackageDetails.clear();
      dataPackages.clear();
      voicePackages.clear();
      comboPackages.clear();

      allPackageDetails = packages;
      selectedPackageList = allPackageDetails;

      for (var p in allPackageDetails) {

        if(p.activatedDate != null){
          totalPrice += p.amount!;
        }

        if(p.packageModel?.packageType == PackageType.Data.name){

          dataPackages.add(p);
        }else if(p.packageModel?.packageType == PackageType.Voice.name){
          voicePackages.add(p);
        }else if(p.packageModel?.packageType == PackageType.Combo.name){
          comboPackages.add(p);
        }
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = HelperFunctions.screenWidth(context);
    screenHeight = HelperFunctions.screenHeight(context);
    return Scaffold(
      appBar: customAppBar(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icons.arrow_back_ios_new_rounded,
        title: "Reload History",
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.ssm),
        child: Visibility(
          visible: widget.isMobile,
          replacement: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(addDivider: true),
                _buildList(
                  packages: dataPackages,
                  emptyMsg: "No Data packages activated!",
                  topPadding: true,
                ),
              ],
            ),
          ),
          child: DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled)  {
                return [
                  SliverToBoxAdapter(child: _buildHeader()),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: StickyTabBarDelegate(
                      TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.darkerGrey,
                        indicatorColor: AppColors.primary,
                        labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                        onTap: (v){
                          setState(() {
                            if(v == 0){
                              selectedPackageList = allPackageDetails;
                            }else if(v == 1){
                              selectedPackageList = dataPackages;
                            }else if(v == 2){
                              selectedPackageList = voicePackages;
                            }else if(v == 3){
                              selectedPackageList = comboPackages;
                            }
                            totalPrice = 0.0;
                            for(var sp in selectedPackageList){
                              if(sp.activatedDate != null){
                                totalPrice += sp.amount!;
                              }
                            }

                          });
                        },
                        tabs: const [
                          Tab(text: 'All'),
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
              body: TabBarView(
                children: [
                  _buildList(
                    packages: allPackageDetails,
                    emptyMsg: "No packages activated previously!",
                  ),

                  _buildList(
                    packages: dataPackages,
                    emptyMsg: "No data packages activated previously!",
                  ),

                  _buildList(
                    packages: voicePackages,
                    emptyMsg: "No data packages activated previously!",
                  ),

                  _buildList(
                    packages: comboPackages,
                    emptyMsg: "No combo packages activated previously!",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({bool addDivider = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText(text: connection.connectionName, color: AppColors.primary, isBold: false),
        HeadlineText(text: "${selectedPackageList.length} previous packages", size: 20),
        BodyText(text: "Rs. ${totalPrice.toStringAsFixed(2)} spent on ${HelperFunctions.maskPhoneNumber(connection.connectionNumber)}", color: AppColors.darkerGrey, size: 12),
        if(addDivider)...{
          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: Sizes.sm),
            child: Divider(),
          ),
        }
      ],
    );
  }


  Widget _buildList({required List<PackageRequestModel> packages, required String emptyMsg, bool topPadding = false}){

    return Visibility(
      visible: packages.isNotEmpty,
      replacement: Padding(
        padding: EdgeInsets.only(top: topPadding ? screenHeight/6 : 0.0),
        child: EmptyScreenWidget(message: emptyMsg),
      ),
      child: ListView.builder(
        itemCount: packages.length,
        shrinkWrap: !widget.isMobile,
        scrollDirection: Axis.vertical,
        physics: widget.isMobile ? null : NeverScrollableScrollPhysics(),
        padding: EdgeInsetsGeometry.only(top:Sizes.sm),
        itemBuilder: (context, index){
          final package = packages[index];

          return AllActPackageCard(
            title: package.packageModel?.packageName ?? HelperFunctions.formatCurrency(package.amount),
            description: package.packageModel?.packageDescription ?? "Reload amount ${HelperFunctions.formatCurrency(package.amount)}",
            price: package.amount ?? 0.0,
            reqDate: package.requestDate!,
            validity: HelperFunctions.formatValidity(package.packageModel?.packageValidity, package.packageModel?.validityPeriod),
            onlyAmount: (package.packageDetailsId == null || package.packageDetailsId!.isEmpty),
            expDate: package.expireDate,
            actDate: package.activatedDate,
          );
        },
      ),
    );
  }

}
