import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/enums/connection_data.enum.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_elevated_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_dropdown.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text_field.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/core/utils/validators/con_number_validations.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.bloc.dart' as con_bloc;

import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.event.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.state.dart' as con_state;


class AddNewConnectionClientScreen extends StatefulWidget {
  final String clientVendorId;
  final List<Map<String, String>> connectionNumbers;
  const AddNewConnectionClientScreen({super.key, required this.clientVendorId, required this.connectionNumbers});

  @override
  State<AddNewConnectionClientScreen> createState() => _AddNewConnectionClientScreenState();
}

class _AddNewConnectionClientScreenState extends State<AddNewConnectionClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conNumberController = TextEditingController();
  final _conNameController = TextEditingController();
  
  bool updated = false;
  bool loadingBtn = false;

  String selectedCategory = "";
  List<String> categoryList = [];

  String selectedType = "";
  List<String> typeList = [];
  List<String> utilTypeList = [];
  List<String> telecomTypeList = [];

  String selectedServiceProvider = "";
  List<String> serviceProviderList = [];
  List<String> serviceProviderHBB = [];
  List<String> serviceProviderMobile = [];
  List<String> serviceProviderTv = [];
  bool showProvider = true;

  String selectedBillingType = "";
  List<String> billingTypeList = [];

  @override
  void initState() {
    initValues();
    super.initState();
  }

  void initValues(){
    //category
    categoryList = HelperFunctions.makeEnumList(ConCategory.values);
    selectedCategory = categoryList.first;

    //type
    utilTypeList = HelperFunctions.makeEnumList(UtilType.values);
    telecomTypeList = HelperFunctions.makeEnumList(TelecomType.values);

    typeList = telecomTypeList;
    selectedType = typeList.first;

    //service provider
    serviceProviderHBB = HelperFunctions.makeEnumList(ServiceProviderHBB.values);
    serviceProviderHBB = HelperFunctions.removeUnderscore(serviceProviderHBB);

    serviceProviderMobile = HelperFunctions.makeEnumList(ServiceProviderMobile.values);
    serviceProviderMobile = HelperFunctions.removeUnderscore(serviceProviderMobile);

    serviceProviderTv = HelperFunctions.makeEnumList(ServiceProviderTv.values);
    serviceProviderTv = HelperFunctions.removeUnderscore(serviceProviderTv);

    serviceProviderList = serviceProviderHBB; // because selectedType is HBB
    selectedServiceProvider = serviceProviderList.first;
    showProvider = true;

    //billing type
    billingTypeList = HelperFunctions.makeEnumList(BillingType.values);
    selectedBillingType = billingTypeList.first;

    _conNameController.clear();
    _conNumberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return  PopScope(
      canPop: !updated,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, updated);
      },
      child: Scaffold(
        appBar: customAppBar(
          onPressed: () => Navigator.of(context).pop(updated),
          icon: Icons.arrow_back_ios_new_rounded,
          title: "Add New Connection",
        ),
        body: BlocListener<con_bloc.ConnectionBloc, con_state.ConnectionState>(
          listener: (context, state) {
            loadingBtn = state is con_state.ConnectionLoading;

            if (state is con_state.ConnectionSuccess) {
              setState(() => loadingBtn = false);
              initValues();
              AppSnackbar.showSuccess(context, 'Connection added successfully!');

            } else if (state is con_state.ConnectionFailure) {
              AppSnackbar.showError(context, state.message);
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.sm),
              child: CCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: Sizes.spaceBtwInputField,
                    children: [
                      CDropDown(
                        onChanged: (v) {
                          setState(() {
                            selectedCategory = v!;
                            if(selectedCategory.toLowerCase() == ConCategory.Utility.name.toLowerCase()){
                              typeList = utilTypeList;
                              showProvider = false;
                            }else{
                              typeList = telecomTypeList;
                              showProvider = true;
                              serviceProviderList = serviceProviderHBB;
                              selectedBillingType = billingTypeList.first;
                            }

                            selectedType = typeList.first;
                          });
                        },
                        label: "Select Category",
                        items: categoryList,
                        selectedType: selectedCategory,
                      ),

                      CDropDown(
                        onChanged: (v){
                          setState(() {
                            selectedType = v!;
                            if(selectedCategory.toLowerCase() == ConCategory.Telecom.name.toLowerCase()){
                              if(selectedType.toLowerCase() == TelecomType.HBB.name.toLowerCase()){
                                serviceProviderList = serviceProviderHBB;
                              }else if(selectedType.toLowerCase() == TelecomType.Mobile.name.toLowerCase()){
                                serviceProviderList = serviceProviderMobile;
                              }else if(selectedType.toLowerCase() == TelecomType.TV.name.toLowerCase()){
                                serviceProviderList = serviceProviderTv;
                              }
                            }
                          });
                        },
                        label: "Select Type",
                        items: typeList,
                        selectedType: selectedType,
                      ),

                      if(showProvider)...[
                        CDropDown(
                          onChanged: (v) => selectedServiceProvider = v!,
                          label: "Select Service Provider",
                          items: serviceProviderList,
                          selectedType: selectedServiceProvider,
                        ),

                        CDropDown(
                          onChanged: (v) => selectedBillingType = v!,
                          label: "Select Billing Type",
                          items: billingTypeList,
                          selectedType: selectedBillingType,
                        ),
                      ],

                      CTextField(
                        controller: _conNumberController,
                        label: 'Connection Number',
                        hint: '7xxxxxxxxxx',
                        keyboardType: (selectedType.toLowerCase() == UtilType.NWSDB.name.toLowerCase()) ? TextInputType.text : TextInputType.number,
                        prefixIcon: Icons.numbers,


                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter connection number';

                          final isValid = ConnectionValidator.validate(
                            category: selectedCategory,     // e.g., 'Telecom'
                            serviceType: selectedType,   // e.g., 'HBB'
                            provider: selectedServiceProvider,     // e.g., 'SLT'
                            connectionNo: value,
                          );

                          if (!isValid) {
                            return 'Invalid connection number format for $selectedServiceProvider $selectedType';
                          }

                          bool isAlreadyHave = widget.connectionNumbers
                              .any((conn) => conn['number'] == _conNumberController.text.trim() && conn['category'] == selectedCategory);

                          if(isAlreadyHave){
                            return 'This connection number is already added';
                          }

                          return null;
                        },

                      ),

                      CTextField(
                        controller: _conNameController,
                        label: 'Connection Name',
                        hint: 'Connection',
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.person,

                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter connection name';
                          return null;
                        },

                      ),

                      CElevatedButton(
                        onPressed: loadingBtn ? null : () async {

                          if (_formKey.currentState!.validate()) {

                            setState(() => updated = true);
                            FocusManager.instance.primaryFocus?.unfocus();

                            final connectionModel = ConnectionModel(
                              clientVendorId: widget.clientVendorId,
                              connectionCategory: selectedCategory,
                              connectionType: selectedType,
                              serviceProvider: selectedServiceProvider,
                              billingType: selectedBillingType,
                              connectionNumber: _conNumberController.text.trim(),
                              connectionName: _conNameController.text.trim(),
                            );
                            context.read<con_bloc.ConnectionBloc>().add(AddNewConnectionRequested(connectionModel));
                          }
                        },
                        isLoading: loadingBtn,
                        label: "Add",
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      
      ),
    );
  }
}
