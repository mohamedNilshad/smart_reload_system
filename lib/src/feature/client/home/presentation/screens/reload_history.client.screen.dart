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
  final bool isDark;
  const ReloadHistoryClientScreen({super.key, required this.packageList, required this.isMobile, required this.connection, this.isDark = false});

  @override
  State<ReloadHistoryClientScreen> createState() => _ReloadHistoryClientScreenState();
}

class _ReloadHistoryClientScreenState extends State<ReloadHistoryClientScreen> {
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  late final bool isDark;

  List<PackageRequestModel> selectedPackageList = [];
  List<PackageRequestModel> allPackageDetails = [];

  List<PackageRequestModel> dataPackages = [];
  List<PackageRequestModel> voicePackages = [];
  List<PackageRequestModel> comboPackages = [];
  List<PackageRequestModel> otherPackages = [];

  double totalPrice = 0.0;

  late final ConnectionModel connection;

  @override
  void initState() {
    isDark = widget.isDark;
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
      otherPackages.clear();

      allPackageDetails = packages;
      selectedPackageList = allPackageDetails;

      for (var p in allPackageDetails) {

        //ignore pending packages
        if(p.activatedDate == null && (p.isCancel == null || p.isCancel == false)){
          continue;
        }

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

        if(p.packageModel?.packageType == null && p.activatedDate == null){
          otherPackages.add(p);
        }
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = HelperFunctions.screenWidth(context);
    screenHeight = HelperFunctions.screenHeight(context);
    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldVendor : null,
      appBar: customAppBar(
        isDark: isDark,
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
                  emptyMsg: "No Reloads !",
                  topPadding: true,
                ),
              ],
            ),
          ),
          child: DefaultTabController(
            length: 5,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled)  {
                return [
                  SliverToBoxAdapter(child: _buildHeader()),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: StickyTabBarDelegate(
                      TabBar(
                        isScrollable: true, // Allow horizontal scrolling
                        tabAlignment: TabAlignment.center, // Align tabs to the left
                        labelColor: AppColors.primary,
                        unselectedLabelColor: isDark ? AppColors.grey : AppColors.darkerGrey,
                        indicatorColor: AppColors.primary,
                        physics: ScrollPhysics(),
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
                            }else if(v == 4){
                              selectedPackageList = otherPackages;
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
                          Tab(text: 'Other'),
                        ],
                      ),
                      backgroundColor: isDark ? AppColors.scaffoldVendor : Theme.of(context).scaffoldBackgroundColor,
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

                  _buildList(
                    packages: otherPackages,
                    emptyMsg: "No other packages activated previously!",
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
        HeadlineText(text: "${selectedPackageList.length} previous packages", size: 20, color: isDark ? AppColors.white : null,),
        BodyText(text: "Rs. ${totalPrice.toStringAsFixed(2)} spent on ${HelperFunctions.maskPhoneNumber(connection.connectionNumber)}", color: isDark ? AppColors.grey : AppColors.darkerGrey, size: 12),
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
        child: EmptyScreenWidget(message: emptyMsg, isDark: isDark),
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
            isDark: isDark,
            title: package.packageModel?.packageName ?? HelperFunctions.formatCurrency(package.amount),
            description: package.packageModel?.packageDescription ?? "Reload amount ${HelperFunctions.formatCurrency(package.amount)}",
            price: package.amount ?? 0.0,
            reqDate: package.requestDate!,
            validity: HelperFunctions.formatValidity(package.packageModel?.packageValidity, package.packageModel?.validityPeriod),
            onlyAmount: (package.packageDetailsId == null || package.packageDetailsId!.isEmpty),
            expDate: package.expireDate,
            actDate: package.activatedDate,
            isCanceled: package.isCancel ?? false,
          );
        },
      ),
    );
  }

}
