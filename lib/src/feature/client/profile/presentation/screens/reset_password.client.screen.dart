
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_bottom_sheet.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_elevated_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text_field.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/auth.bloc.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/auth.event.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/auth.state.dart';
import 'package:smart_reload_system/src/feature/client/profile/presentation/bloc/profile.bloc.dart';
import 'package:smart_reload_system/src/feature/client/profile/presentation/bloc/profile.event.dart';
import 'package:smart_reload_system/src/feature/client/profile/presentation/bloc/profile.state.dart';

class ResetPasswordClientScreen extends StatefulWidget {
  const ResetPasswordClientScreen({super.key});

  @override
  State<ResetPasswordClientScreen> createState() => _ResetPasswordClientScreenState();
}

class _ResetPasswordClientScreenState extends State<ResetPasswordClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool enableBtn = false;
  bool loadingBtn = false;
  final _isLoadingNotifier = ValueNotifier<bool>(false);
  double screenWidth = 0.0;
  String btnText = "Update";

  @override
  void initState() {
    super.initState();
  }

  void _validateField(){
    setState(() {
      enableBtn = (_passwordController.text.trim() == _confirmPassController.text.trim());
    });


  }

  @override
  Widget build(BuildContext context) {
    screenWidth = HelperFunctions.screenWidth(context);
    return Scaffold(
      appBar: customAppBar(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icons.arrow_back_ios_new_rounded,
        title: "Reset Password",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Sizes.sm, Sizes.lg, Sizes.sm, Sizes.sm),
          child: CCard(
            child: Form(
              key: _formKey,
              child:  BlocListener<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  loadingBtn = state is PasswordLoading;

                  if (state is PasswordFailure) {
                    AppSnackbar.showError(context, state.message);

                  } else if (state is PasswordUpdateSuccess) {
                    loadingBtn = false;
                    _passwordController.clear();
                    _confirmPassController.clear();
                    AppSnackbar.showSuccess(context, "Password successfully updated!");
                  }
                },
                child: Column(
                  spacing: Sizes.spaceBtwInputField,
                  children: [
                    CTextField(
                      controller: _passwordController,
                      label: 'New Password',
                      hint: '•••••••••',
                      isPassword: true,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock_outline,
                      onChanged: (v){
                        _validateField();
                        return;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter password';
                        return null;
                      },
                    ),
                    CTextField(
                      controller: _confirmPassController,
                      label: 'Confirm New Password',
                      hint: '•••••••••',
                      isPassword: true,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock_outline,
                      onChanged: (v){
                        _validateField();
                        return;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter confirm password';
                        return null;
                      },
                    ),

                    BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        _isLoadingNotifier.value = state is AuthLoading;

                        if (state is AuthFailureState) {
                          AppSnackbar.showError(context, state.message, showUp: true); // wrong password, etc.
                        } else if (state is ReauthenticationSuccess) {

                          if(_passwordController.text.trim() == _oldPassController.text.trim()){
                            _isLoadingNotifier.value = false;
                            AppSnackbar.showError(context, "New password can't be current password!", showUp: true);
                          }else{
                            context.read<ProfileBloc>().add(
                              PasswordUpdateRequested(password: _passwordController.text.trim()),
                            );
                            setState(() {
                              enableBtn = true;
                              btnText = "Update";
                            });
                            Navigator.of(context).pop();

                          }
                        }
                      },
                      child: CElevatedButton(
                        onPressed: !enableBtn || loadingBtn ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              enableBtn = false;
                              btnText = "Waiting for confirm";
                            });

                            await AppBottomSheet.showForm(
                              context,
                              title: 'Enter Password',
                              form: Form(
                                key: _passwordFormKey,
                                child: CTextField(
                                  controller: _oldPassController,
                                  label: 'Password',
                                  hint: '•••••••••',
                                  isPassword: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  prefixIcon: Icons.lock_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Please enter current password';
                                    return null;
                                  },
                                ),
                              ),
                              buttonText: 'Continue',
                              isLoading: _isLoadingNotifier,
                              onSubmit: () {
                                if(_passwordFormKey.currentState!.validate()){
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  context.read<AuthBloc>().add(ReauthenticateRequested(password: _oldPassController.text));
                                }
                              },
                            );

                            setState(() {
                              enableBtn = true;
                              btnText = "Update";
                            });
                          }
                        },
                        isLoading: loadingBtn,
                        label: btnText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
