import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/widgets/all_act_package_card.widget.dart';

class ReloadHistoryClientScreen extends StatefulWidget {
  final List<PackageRequestModel> packageList;
  const ReloadHistoryClientScreen({super.key, required this.packageList});

  @override
  State<ReloadHistoryClientScreen> createState() => _ReloadHistoryClientScreenState();
}

class _ReloadHistoryClientScreenState extends State<ReloadHistoryClientScreen> {
  double screenWidth = 0.0;
  List<PackageRequestModel> packageList = [];

  @override
  void initState() {
    packageList = widget.packageList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = HelperFunctions.screenWidth(context);
    return Scaffold(
      appBar: customAppBar(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icons.arrow_back_ios_new_rounded,
        title: "Reload History",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Sizes.ssm, Sizes.ssm, Sizes.ssm, 100 ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.0,
            children: packageList.map((package) {
              return AllActPackageCard(
                title: package.packageModel?.packageName ?? HelperFunctions.formatCurrency(package.amount),
                description: package.packageModel?.packageDescription ?? "Reload amount ${HelperFunctions.formatCurrency(package.amount)}",
                price: package.amount ?? 0.0,
                reqDate: package.requestDate,
                validity: HelperFunctions.formatValidity(package.packageModel?.packageValidity, package.packageModel?.validityPeriod),
                onlyAmount: (package.packageDetailsId == null || package.packageDetailsId!.isEmpty),
                expDate: package.expireDate,
                actDate: package.activatedDate,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
