import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  List<Map<String, dynamic>> items = [
    {
      'title': 'Reports',
      'icon': Icons.assessment_outlined,
      'iconColor': AppColors.purple,
    },
    {
      'title': 'Clients',
      'icon': Icons.group,
      'iconColor': AppColors.success,
    },
    {
      'title': 'Bank Info',
      'icon': Icons.account_balance,
      'iconColor': AppColors.info,
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldVendor,
      appBar: customAppBar(isDark: true, title: "Manage"),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(Sizes.ssm),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 15,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: (){
                if(index == 0){
                  //do
                } else if(index == 1){
                  //do
                } else if(index == 2){
                  //Bank info
                  Navigator.pushNamed(context, RouteConstants.bankInfoVendorScreen);

                }
              },
              child: CCard(
                isDark: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[index]['icon'], size: 48, color: items[index]['iconColor']),
                    SizedBox(height: 8),
                    TitleText(
                      text: items[index]['title'],
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
