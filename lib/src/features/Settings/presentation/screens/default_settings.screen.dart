import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/Sliders/slider.widget.dart';
import 'package:smart_reload_system/src/core/presentation/popups/confirm_popup.widget.dart';
import 'package:smart_reload_system/src/core/presentation/popups/custom_color_picker.dart';
import 'package:smart_reload_system/src/core/presentation/progress_indicators/custom.circular_progress_indicator.dart';
import 'package:smart_reload_system/src/core/presentation/snack_bars/custom.snackbar.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/features/Settings/data/models/settings.model.dart';
import 'package:smart_reload_system/src/features/Settings/presentation/bloc/settings.bloc.dart';

class DefaultSettingsScreen extends StatefulWidget {
  const DefaultSettingsScreen({super.key});

  @override
  State<DefaultSettingsScreen> createState() => _DefaultSettingsScreenState();
}

class _DefaultSettingsScreenState extends State<DefaultSettingsScreen> {
  late Color _selectedBoarderColor;
  late Color _selectedBgColor;
  late Color _selectedFgColor;

  late double _boarderWidthValue;
  late double _paddingValue;
  late double _edgeValue;

  late bool _enableBoarder;
  late bool _continuesScan;
  late bool _autoRedirect;

  late Color _oldBoarderColor;
  late Color _oldBgColor;
  late Color _oldFgColor;

  late double _oldBoarderWidth;
  late double _oldPadding;
  late double _oldEdge;

  late bool _oldEnableBoarder;
  late bool _oldContinuesScan;
  late bool _oldAutoRedirect;

  int? _id;

  bool loading = false;
  bool _isUpdate = true;
  bool loadingSaveBtn = false;
  bool enableSaveBtn = false;

  Future<void> loadSettings() async{
    if (loading) return;
    setState(() => loading = true);
    context.read<SettingsBloc>().add(FetchSettingsEvent());
    setState(() => loading = false);
  }

  void setData(){
    Settings? settings = context.read<SettingsBloc>().settings;
    setState(() {
      _id = settings?.id;
      _selectedBgColor = HelperFunctions.decodeColor(settings?.bgColor) ?? AppColors.white;
      _selectedFgColor = HelperFunctions.decodeColor(settings?.fgColor) ??AppColors.black;
      _selectedBoarderColor = HelperFunctions.decodeColor(settings?.boarderColor) ?? AppColors.black;

      _boarderWidthValue = settings?.boarderWidth ?? 1.0;
      _paddingValue = settings?.padding ?? Sizes.sm;
      _edgeValue =  settings?.edge ?? 0.0;

      _enableBoarder = settings?.enableBoarder ?? false;
      _continuesScan = settings?.continuesScan ?? false;
      _autoRedirect = settings?.autoRedirect ?? false;

      setOldValue();
    });
  }

  void setOldValue(){
    setState(() {
      _oldBoarderColor = _selectedBoarderColor;
      _oldBgColor = _selectedBgColor;
      _oldFgColor = _selectedFgColor;

      _oldBoarderWidth = _boarderWidthValue;
      _oldPadding = _paddingValue;
      _oldEdge = _edgeValue;

      _oldEnableBoarder = _enableBoarder;
      _oldContinuesScan = _continuesScan;
      _oldAutoRedirect = _autoRedirect;

      loading = false;
    });
  }

  bool checkSaveBtn(){
     if(_oldBoarderColor != _selectedBoarderColor){
       return true;
     }else if(_oldBgColor != _selectedBgColor){
       return true;
     }else if(_oldFgColor != _selectedFgColor){
       return true;
     }else if(_oldBoarderWidth != _boarderWidthValue){
       return true;
     }else if(_oldPadding != _paddingValue){
       return true;
     }else if(_oldEdge != _edgeValue){
       return true;
     }else if(_oldEnableBoarder != _enableBoarder){
       return true;
     }else if(_oldContinuesScan != _continuesScan){
       return true;
     }else if(_oldAutoRedirect != _autoRedirect){
       return true;
     }else{
       return false;
     }

  }

  void setLoadedData({required LoadedSettingsState state}){
    setState(() {
      _id = state.settings.id;
      _selectedBgColor = HelperFunctions.decodeColor(state.settings.bgColor) ?? AppColors.white;
      _selectedFgColor = HelperFunctions.decodeColor(state.settings.fgColor) ?? AppColors.black;
      _paddingValue = state.settings.padding ?? Sizes.sm;
      _edgeValue =  state.settings.edge ?? 0.0;
      _enableBoarder =  state.settings.enableBoarder ?? false;
      _selectedBoarderColor =  HelperFunctions.decodeColor(state.settings.boarderColor) ?? AppColors.black;
      _boarderWidthValue =   state.settings.boarderWidth ?? 1.0;
      _continuesScan = state.settings.continuesScan ?? false;
      _autoRedirect = state.settings.autoRedirect ?? false;
      setOldValue();
      loading = false;
    });
  }

  @override
  void initState() {
    setData();
    Future.microtask(() => loadSettings());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state){
        if(state is LoadingSettingsState){
          if(state.isFetch) setState(() => loading = true);
          if(state.isSave) setState(() => loadingSaveBtn = true);
        }else if(state is ErrorSettingsState){
          setState(() => loading = false);
          customSnackBar(context, state.error);
        }else if(state is LoadedSettingsState){
          if(state.settings.id != null) {
            // setLoadedData(state: state);
            setData();
          }else{
            setState(() {
              _isUpdate = false;
              loading = false;
            });
          }
        }else if(state is SuccessSettingsState){
          if(state.success) {
            customSnackBar(context, 'Settings Saved Successfully!', backgroundColor: AppColors.success);
            context.read<SettingsBloc>().add(FetchSettingsEvent());
            setState(() => enableSaveBtn = false);
          }else{
            customSnackBar(context, 'Settings Saving Failed!');
          }
          setState(() => loadingSaveBtn = false);
        }
      },
      child: PopScope(
        canPop: !enableSaveBtn,
        onPopInvoked: (popDisposition) async {
          if(popDisposition)return;
          bool? exit = await showDialog(
            context: context,
            builder: (context) => const ShowConfirmPopup(
              title: 'Exit',
              content: 'Leave Without Save?',
              rightBtn: 'Exit',
              leftBtn: 'Stay',
            ),
          );
          return ((exit != null) && exit && context.mounted) ? Navigator.of(context).pop() : null;
        },

        child: Scaffold(
          appBar: AppBar(
            title: const Text('Default Settings'),
            centerTitle: true,
            actions: [
              Visibility(
                visible: !loadingSaveBtn,
                replacement: const CCircularProgressIndicator(color: AppColors.white, rightMargin: 15.0, radius: 15,),
                child: IconButton(
                  color: AppColors.white,
                  onPressed: enableSaveBtn ? (){
                    Settings setting = Settings(
                      id: _id,
                      bgColor: HelperFunctions.encodeColor(_selectedBgColor),
                      fgColor: HelperFunctions.encodeColor(_selectedFgColor),
                      padding: _paddingValue,
                      edge: _edgeValue,
                      enableBoarder: _enableBoarder,
                      boarderWidth: _boarderWidthValue,
                      boarderColor: HelperFunctions.encodeColor(_selectedBoarderColor),
                      continuesScan: _continuesScan,
                      autoRedirect: _autoRedirect,
                    );
                    context.read<SettingsBloc>().add(UpdateSettingsEvent(settings: setting, isUpdate: _isUpdate));
                    setOldValue();
                  } : null,
                  icon: const Icon(Icons.save),
                ),
              )
            ],
          ),
          body:  Visibility(
            visible: !loading,
            replacement: const Center(child: CCircularProgressIndicator()),
            child: Column(
              children: [
                buildHeader(title: 'Generate Settings'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
                  child: Column(
                    children: [
                      CColorPicker(
                        title: 'Background Color',
                        selectedColor: _selectedBgColor,
                        onPressed: (color) => setState(() {
                          _selectedBgColor = color;
                          enableSaveBtn = checkSaveBtn();
                        }),
                      ),
                      CColorPicker(
                        title: 'Foreground Color',
                        selectedColor: _selectedFgColor,
                        onPressed: (color) => setState(() {
                          if(color != _selectedFgColor){
                            _selectedFgColor = color;
                            enableSaveBtn = checkSaveBtn();
                          }
                        }),
                      ),
                      CSlider(
                        title: 'Padding',
                        value: _paddingValue,
                        max: 30.0,
                        onChanged: (value) => setState((){
                          _paddingValue = value;
                          enableSaveBtn = checkSaveBtn();
                        }),
                      ),
                      CSlider(
                        title: 'Edge',
                        value: _edgeValue,
                        onChanged: (value) => setState(() {
                          _edgeValue = value;
                          enableSaveBtn = checkSaveBtn();
                        }),
                      ),
                      CheckboxListTile(
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text(
                          "Add Border",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        value: _enableBoarder,
                        onChanged: (newValue) => setState(() {
                          _enableBoarder = newValue!;
                          enableSaveBtn = checkSaveBtn();
                        }),
                      ),
                      CColorPicker(
                        title: 'Boarder Color',
                        selectedColor: _selectedBoarderColor,
                        onPressed: (color) => setState(() {
                          if(color != _selectedBoarderColor) {
                            _selectedBoarderColor = color;
                          }
                        }),
                      ),
                      CSlider(
                        title: 'Boarder Width',
                        value: _boarderWidthValue,
                        min: 1.0,
                        max: 10.0,
                        onChanged: (value) => setState(() {
                          _boarderWidthValue = value;
                          enableSaveBtn = checkSaveBtn();
                        }),
                      ),
                    ],
                  ),
                ),

                buildHeader(title: 'Scan Settings'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
                  child: Column(
                    children: [
                      // CheckboxListTile(
                      //   visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      //   dense: true,
                      //   contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      //   controlAffinity: ListTileControlAffinity.trailing,
                      //   title: Text(
                      //     "Continuous Scan",
                      //     style: Theme.of(context).textTheme.titleMedium,
                      //   ),
                      //
                      //   value: _continuesScan,
                      //   onChanged: (newValue) => setState(() {
                      //     _continuesScan = newValue!;
                      //     enableSaveBtn = checkSaveBtn();
                      //   }),
                      // ),
                      CheckboxListTile(
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text(
                          "Auto Redirect",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        value: _autoRedirect,
                        onChanged: (newValue) => setState(() {
                          _autoRedirect = newValue!;
                          enableSaveBtn = checkSaveBtn();
                        }),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader({required String title}){
    return Container(
      width: HelperFunctions.screenWidth(context),
      padding: const EdgeInsets.symmetric(horizontal:Sizes.sm, vertical: Sizes.xs),
      margin: const EdgeInsets.only(bottom: Sizes.sm),
      color: AppColors.darkGrey,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.black),
      ),
    );
  }
}
