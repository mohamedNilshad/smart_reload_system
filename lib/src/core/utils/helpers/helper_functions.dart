import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';

class HelperFunctions {

  static void customAlert({required BuildContext sContext, required String title, required String message}){
    showDialog(
      context: sContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.okLabel),
            )
          ],
        );
      },
    );
  }

  static void pushNavigateToScreen({required BuildContext context, required Widget screen}){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void pushAndReplaceNavigateToScreen({required BuildContext context, required Widget screen}){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static String truncateText(String text, int maxLength){
    if(text.length <= maxLength){
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  static bool isDarkMode(BuildContext context){
    return Theme.of(context).brightness == Brightness.dark;
  }

  static double screenHeight(BuildContext context){
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }

  static double pixelRatio(BuildContext context){
    return MediaQuery.of(context).devicePixelRatio;
  }


  static double statusBarHeight(BuildContext context){
    return MediaQuery.of(context).padding.top;
  }

  static double bottomNavBarHeight(BuildContext context){
    return kBottomNavigationBarHeight;
  }

  static double appBarHeight(BuildContext context){
    return kToolbarHeight;
  }

  static double keyBoardHeight(BuildContext context){
    final viewInsets = MediaQuery.of(context).viewInsets;
    return viewInsets.bottom;
  }

  static Future<bool> isKeyboardVisible(BuildContext context) async{
    final viewInsets = View.of(context).viewInsets;
    return viewInsets.bottom > 0;
  }

  static Future<bool> isPhysicalDevice(BuildContext context) async{
    return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }

  static Future<bool> hasInternetConnection() async{
    try{
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_){
      return false;
    }
  }

  static String getToday() {
    DateTime now = DateTime.now();
    int weekday = now.weekday;

    List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return  days[weekday - 1].toLowerCase();
  }

  static String convertToAMPM(String time) {
    DateTime dateTime = DateFormat('HH:mm').parse(time);
    return DateFormat('h:mm a').format(dateTime);
  }



  static String formatCurrency(double amount) {
    final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return currencyFormatter.format(amount);
  }

  static String getCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy_MM_dd_HH_mm_ss');
    return formatter.format(now);
  }

  static bool isIOS(){
    return Platform.isIOS;
  }

  static bool isAndroid(){
    return Platform.isAndroid;
  }

  static List<T> removeDuplicates<T>(List<T> list){
    return list.toSet().toList();
  }

  static String getInitials(String text) {
    if (text.isEmpty) return '-';

    final words = text.trim().split(RegExp(r'\s+'));

    if (words.isEmpty) return '-';

    if (words.length >= 2) {
      return (words[0].isNotEmpty ? words[0][0] : '') +
          (words[1].isNotEmpty ? words[1][0] : '');
    }

    return words[0].isNotEmpty ? words[0][0] : '';
  }
}
