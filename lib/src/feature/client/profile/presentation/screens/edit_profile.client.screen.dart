
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_bottom_sheet.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text_field.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/entity/client.entity.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/auth.bloc.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/auth.event.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/auth.state.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/session.state.dart';

class EditProfileClientScreen extends StatefulWidget {
  const EditProfileClientScreen({super.key});

  @override
  State<EditProfileClientScreen> createState() => _EditProfileClientScreenState();
}

class _EditProfileClientScreenState extends State<EditProfileClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();


  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  late UserEntity user;

  bool enableBtn = false;
  final _isLoadingNotifier = ValueNotifier<bool>(false);
  double screenWidth = 0.0;

  @override
  void initState() {
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) {
      user = sessionState.user;
      _initValues();
    }

    super.initState();
  }

  void _initValues(){
    _nameController.text = user.fullName;
    _phoneController.text = user.phoneNumber;
    _emailController.text = user.email;
    _nicController.text = user.nic;
  }

  void _validateNewValues(){
    setState(() {
      if((_nameController.text != user.fullName) && (_nameController.text.isNotEmpty)){
        enableBtn = true;
      }else if((_phoneController.text != user.phoneNumber) && (_phoneController.text.isNotEmpty)){
        enableBtn = true;
      }else if((_emailController.text != user.email) && (_emailController.text.isNotEmpty)){
        enableBtn = true;
      }else if((_nicController.text != user.nic) && (_nicController.text.isNotEmpty)){
        enableBtn = true;
      }else{
        enableBtn = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = HelperFunctions.screenWidth(context);
    return Scaffold(
      appBar: customAppBar(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icons.arrow_back_ios_new_rounded,
        title: "Edit Profile",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Sizes.sm, Sizes.lg, Sizes.sm, Sizes.sm),
          child: CCard(
            child: Form(
              key: _formKey,
              child: Column(
                spacing: Sizes.spaceBtwInputField,
                children: [
                  CTextField(
                    controller: _nameController,
                    label: 'Name',
                    hint: 'John Doe',
                    keyboardType: TextInputType.text,
                    prefixIcon: Icons.person_outline_rounded,
                    onChanged: (v) {
                      _validateNewValues();
                      return;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your name';
                      return null;
                    },
                  ),
                  CTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: '7xxxxxxxxxx',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.phone_android,
                    onChanged: (v) {
                      _validateNewValues();
                      return;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter mobile number';
                      return null;
                    },
                  ),
                  CTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                    onChanged: (v) {
                      _validateNewValues();
                      return;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter email address';
                      return null;
                    },
                  ),
                  CTextField(
                    controller: _nicController,
                    label: 'NIC / ID Number',
                    hint: '123456789V',
                    keyboardType: TextInputType.text,
                    prefixIcon: Icons.credit_card,
                    onChanged: (v) {
                      _validateNewValues();
                      return;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your NIC / ID card';
                      return null;
                    },
                  ),

                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      _isLoadingNotifier.value = state is AuthLoading;

                      if (state is AuthFailureState) {
                        AppSnackbar.showError(context, state.message, showUp: true); // wrong password, etc.
                      } else if (state is ReauthenticationSuccess) {
                        Navigator.of(context).pop();
                        // context.read<AuthBloc>().add(
                        //     UserEntity(
                        //   fullName: _nameController.text.trim(),
                        //   phoneNumber: _phoneController.text.trim(),
                        //   email: _emailController.text.trim(),
                        //   nic: _nicController.text.trim(),
                        // ),
                        // );

                        // context.read<ProfileBloc>().add(
                        //   ProfileUpdateRequested(
                        //     fullName: fullNameController.text,
                        //     phoneNumber: phoneController.text,
                        //     nic: nicController.text,
                        //   ),
                        // );
                      }
                    },
                    child: ElevatedButton(
                      onPressed: !enableBtn ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          AppBottomSheet.showForm(
                            context,
                            title: 'Enter Amount',
                            form: Form(
                              key: _passwordFormKey,
                              child: CTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: '•••••••••',
                                isPassword: true,
                                keyboardType: TextInputType.visiblePassword,
                                prefixIcon: Icons.lock_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Please enter password';
                                  return null;
                                },
                              ),
                            ),
                            buttonText: 'Continue',
                            isLoading: _isLoadingNotifier,
                            onSubmit: () {
                              if(_passwordFormKey.currentState!.validate()){
                                FocusManager.instance.primaryFocus?.unfocus();
                                context.read<AuthBloc>().add(ReauthenticateRequested(password: _passwordController.text));
                              }
                            },
                          );
                        }
                      },

                      style: ElevatedButton.styleFrom(minimumSize: Size(screenWidth, Sizes.buttonHeight)),
                      child: Text("Update"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
