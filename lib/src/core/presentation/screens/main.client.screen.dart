import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/screens/payment.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/profile/presentation/screens/profile.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/home.client.screen.dart';

class MainClientScreen extends StatefulWidget {
  const MainClientScreen({super.key});

  @override
  State<MainClientScreen> createState() => _MainClientScreenState();
}

class _MainClientScreenState extends State<MainClientScreen> {
  int _selectedIndex = 0;

  List<Widget> screens = [
    HomeClientScreen(),
    TempScreen(title: "Family screen"),
    PaymentScreen(),
    ProfileScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom_rounded),
            label: 'Family',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_rounded),
            label: 'Payment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: AppColors.darkGrey,
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