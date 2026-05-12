import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_reload_system/src/core/bloc/theme/theme.bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/progress_indicators/custom.circular_progress_indicator.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/features/home/presentation/bloc/history.bloc.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';

import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool loading = false;
  bool isOpened = false;

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  Future<void> scanQR() async {
    // String barcodeScanRes;
    //
    // try {
    //   barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
    //     '#ff6666', 'Cancel', true, ScanMode.QR,
    //   );
    //
    //   if (barcodeScanRes == '-1') return;
    //   if (!mounted) return;
    //   Navigator.pushNamed(context,
    //     RouteConstants.scanCodeScreen, arguments: barcodeScanRes,
    //   );
    // } on PlatformException catch (e) {
    //   barcodeScanRes = 'Failed to get platform version. $e';
    //   customSnackBar(context, barcodeScanRes);
    // } catch (strace, e) {
    //   barcodeScanRes = 'An unexpected error occurred. $e';
    //   customSnackBar(context, barcodeScanRes);
    // }
  }

  Future<void> scanBarcode() async {
    // String barcodeScanRes;
    //
    // try {
    //   barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
    //     '#ff6666', 'Cancel', true, ScanMode.BARCODE,
    //   );
    //
    //   if (barcodeScanRes == '-1') return;
    //   if (!mounted) return;
    //   Navigator.pushNamed(context,
    //     RouteConstants.scanCodeScreen, arguments: barcodeScanRes,
    //   );
    // } on PlatformException catch (e) {
    //   barcodeScanRes = 'Failed to get platform version. $e';
    //   customSnackBar(context, barcodeScanRes);
    // } catch (strace, e) {
    //   barcodeScanRes = 'An unexpected error occurred. $e';
    //   customSnackBar(context, barcodeScanRes);
    // }
  }

  Future<void> continuousScan() async {

    // List<String> results = [];
    // StreamSubscription? barcodeStream;
    //
    // try {
    //   barcodeStream = FlutterBarcodeScanner.getBarcodeStreamReceiver(
    //     '#ff6666', 'OK', true, ScanMode.BARCODE,
    //   )?.listen((barcode) async {
    //
    //     if (barcode == '-1') {
    //       if (!mounted) return;
    //       Navigator.pushNamed(
    //         context,
    //         RouteConstants.continuousScanResultScreen,
    //         arguments: results,
    //       );
    //       barcodeStream?.cancel();
    //       return;
    //     }
    //     setState(() => results.add(barcode));
    //     // if (await Vibration.hasVibrator()) Vibration.vibrate(duration: 300);
    //   });
    //
    //   if (results.isEmpty) return;
    //   // if (!mounted) return;
    //   // Navigator.pushNamed(context,
    //   //   RouteConstants.continuousScanResultScreen, arguments: results,
    //   // );
    // } on PlatformException catch (e) {
    //   customSnackBar(context, 'Failed to get platform version. $e');
    // } catch (strace, e) {
    //   customSnackBar(context, 'An unexpected error occurred. $e');
    // }
  }

  Future<void> loadHistory() async{
    if (loading) return;
    setState(() => loading = true);
    context.read<HistoryBloc>().add(FetchAllHistoryEvent());
    setState(() => loading = false);
  }

  @override
  void initState() {
    loadHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = HelperFunctions.isDarkMode(context);
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeState) {
        return Scaffold(
          appBar: AppBar(centerTitle: true, title: const Text(AppStrings.brandName)),
          drawer: Drawer(
            child: BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  if(state is LoadingHistoryState){
                    if(state.isHistory) return const CCircularProgressIndicator();
                  }else if(state is ErrorHistoryState){
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.error,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        IconButton(
                          onPressed: ()=>loadHistory(),
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    );
                  }else if(state is LoadedCodeHistoryState){
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Sizes.spaceBtwSections),
                          // ListTile(
                          //   contentPadding: const EdgeInsets.only(left: Sizes.sm, right: Sizes.sm),
                          //   titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                          //   title: const Text('Theme'),
                          //   subtitle: Text(themeState.name),
                          //   trailing: Switch(
                          //     value: themeState == ThemeMode.dark,
                          //     onChanged: (value) {
                          //       context.read<ThemeBloc>().add(ChangeThemeEvent(value));
                          //     },
                          //   ),
                          // ),
                          ListTile(
                            contentPadding: const EdgeInsets.only(left: Sizes.sm, right: Sizes.sm),
                            titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                            title: const Text(AppStrings.settingsLabel),
                            trailing: IconButton(
                              onPressed: ()=>Navigator.pushNamed(context, RouteConstants.settingsScreen),
                              icon: const Icon(Icons.settings),
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: Sizes.spaceBtwItems),
                          Padding(
                            padding: const EdgeInsets.only(left: Sizes.sm),
                            child: Text(
                              'History',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          state.history.isEmpty ?
                          Padding(
                            padding: EdgeInsets.only(top:HelperFunctions.screenHeight(context) / 3),
                            child: const Center(child: Text('No History Available')),
                          ) :
                          ListView.separated(
                            shrinkWrap: true,
                            itemCount: state.history.length,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.zero,
                            reverse: true,
                            itemBuilder: (BuildContext context, int index)  {
                              String date = DateFormat('dd-MMMM-yyyy').format(DateTime.parse(state.history[index].modifiedDate));
                              return ListTile(
                                title: Text(state.history[index].saveName),
                                titleTextStyle: Theme.of(context).textTheme.titleMedium,
                                subtitle: Text(date),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                                tileColor: isDark ? AppColors.black: AppColors.grey,
                                onTap: () {},
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return const SizedBox(height: Sizes.xs);
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: TextButton(
                      onPressed: ()=>loadHistory(),
                      child: const Text('Click to Refresh'),
                    ),
                  );
                }
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(Sizes.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const SizedBox(height: Sizes.spaceBtwItems),
                GestureDetector(
                  onTap: (){
                    // String da = 'www.google.com';//*
                    // String da1 = '+974585485';
                    // String da2 = 'www.youtube.com';
                    // String da3 = 'http://atlasaxillia.com/';
                    // String da4 = 'https://www.instagram.com/atlas.srilanka/';
                    // String da5 = 'https://mail.google.com/';
                    // String da6 = 'https://drive.google.com/';
                    // String da7 = 'This is just text';
                    // String da8 = 'This is a phone +001234567 This is a link www.youtube.com This is just text';
                    // String da9 = 'mailto:n@gmail.com?subject=testing&body=hii dff ddf'; //*
                    // String da10 = 'WIFI:SLT;T:WEP;P:1234;H:false;;';//*
                    // String da11 = 'tel:+974585485';//*
                    // String da12 = 'SMSTO:+94777192608:Tesingd';//
                    //
                    //
                    // Navigator.pushNamed(context,
                    //   RouteConstants.scanCodeScreen,
                    //   arguments: da9
                    // );
                    // showDialog(
                    //   context: context,
                    //   builder: (BuildContext context) {
                    //     return buildAlertBox();
                    //   },
                    // );
                    // scanBarcode();

                  },
                  child: const CCard(
                    title: 'Scan',
                    bgColor: AppColors.linerGradient,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget buildAlertBox(){

    return AlertDialog(
      title: Center(
        child: Text(
          "Select Type",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 25),
        ),
      ),
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: Sizes.xl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

        ],
      ),
    );
  }
}
