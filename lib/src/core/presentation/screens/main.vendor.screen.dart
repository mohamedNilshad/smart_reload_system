import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/features/profile/presentation/screens/profile.screen.dart';
import 'package:smart_reload_system/src/feature/vendor/home/presentation/screens/home.vendor.screen.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/screens/wallet.screen.dart';

class MainVendorScreen extends StatefulWidget {
  const MainVendorScreen({super.key});

  @override
  State<MainVendorScreen> createState() => _MainVendorScreenState();
}

class _MainVendorScreenState extends State<MainVendorScreen> {
  int _selectedIndex = 0;

  List<Widget> screens = [
    HomeVendorScreen(),
    TempScreen(title: "Invoice screen"),
    WalletScreen(),
    ProfileScreen(isDark: true),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.darkGrey, width: 0.5)),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Invoice',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: AppColors.darkGrey,
          backgroundColor: AppColors.bottomNavVendor,
          unselectedLabelStyle: TextStyle(color: AppColors.darkGrey),
          showUnselectedLabels: true,
          selectedItemColor: AppColors.primary,
          type: BottomNavigationBarType.fixed,
          onTap: (index){
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      body: screens[_selectedIndex],
    );
  }

  Widget buildNavItem({required IconData icon, required bool isSelected}){
    return Container(
      width: 10,
      margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: Sizes.ssm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.0),
        color: isSelected ? AppColors.secondary.withValues(alpha: 0.3) : Colors.transparent,
      ),
      child: NavigationDestination(
        icon: Icon(icon, color: isSelected ? AppColors.info : AppColors.white, size: Sizes.iconLg),
        label: '',
      ),
    );
  }
}


class TempScreen extends StatelessWidget {
  final String title;
  const TempScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '$title Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}