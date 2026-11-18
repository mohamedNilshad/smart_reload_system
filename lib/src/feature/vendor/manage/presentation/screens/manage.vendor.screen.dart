import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/domain/entity/user.entity.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.state.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/feature/vendor/report/presentation/screen/vendor_dashboard.screen.dart';

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

  late UserEntity user;

  bool isLoading = false;

  @override
  void initState() {
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) user = sessionState.user;
    super.initState();
  }


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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorDashboardScreen(vendorId: user.uid, vendorName: user.fullName),
                    ),
                  );

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
