import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_banner.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_tile.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';

class HomeClientScreen extends StatefulWidget {
  const HomeClientScreen({super.key});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "USER A",
        action: [
          IconButton(
            onPressed: (){},
            color: AppColors.darkGrey,
            icon: Stack(
              children: [
                Icon(Icons.notifications_none_rounded, size: 30),
                Positioned(
                  right: 5,
                  top: 5,
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: Colors.red,
                  ),
                )
              ],
            ),
          ),
        ]
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.ssm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.0,
            children: [
              CustomBanner(
                label: "NEW",
                title: "5G Packages Available!",
                body: "Upgrade your connection today and get 20% off your first month.",
              ),

              SubHeadlineText(text: "My Vendors"),

              CustomTile(
                onTap: (){
                  Navigator.pushNamed(context, RouteConstants.connectionClientScreen, arguments: "David jhon");
                },
                title: "David Jhon",
                ref: "Ref.",
                count: 2,
              ),
              CustomTile(
                onTap: (){
                  Navigator.pushNamed(context, RouteConstants.connectionClientScreen, arguments: "Jhon");
                },
                title: "Jhon",
                ref: "Ref.",
                count: 5,
              ),
              CustomTile(
                onTap: (){
                  Navigator.pushNamed(context, RouteConstants.connectionClientScreen, arguments: "Ravi");
                },
                title: "Ravi",
                ref: "Ref.",
                count: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
