
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_header.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_outline_button.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/primary_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/rich_text_button.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text_field.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_status_bar.widget.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/auth.bloc.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/auth.event.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/auth.state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CStatusBar(
      child: SafeArea(
        child: Scaffold(
          body: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailureState) {
                AppSnackbar.showError(context, state.message);
              } else if (state is AuthSuccess) {
                if(state.isClient){
                  Navigator.pushNamedAndRemoveUntil(context, RouteConstants.mainClientScreen, (r) => false);
                }else{
                  Navigator.pushNamedAndRemoveUntil(context, RouteConstants.mainVendorScreen, (r) => false);
                }

              }
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.sm),
                child: Align(
                  alignment: AlignmentGeometry.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: Sizes.spaceBtwSections,
                    children: [
                      AppHeader(subtitle: "Login with your account"),
                      CCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            spacing: Sizes.spaceBtwInputField,
                            children: [
                              CTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                hint: '7xxxxxxxxxx',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.phone_android,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Please enter mobile number';
                                  return null;
                                },
                              ),
                              Column(
                                children: [
                                  CTextField(
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
                                  Align(
                                    alignment: AlignmentGeometry.centerRight,
                                    child: TextButton(
                                      onPressed: (){

                                        //Navigator.pushNamed(context, RouteConstants.forgotPasswordScreen);
                                      },
                                      child: Text("Forgot Password?"),
                                    ),
                                  ),
                                ],
                              ),
                              BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    if (state is AuthLoading) return const CircularProgressIndicator();

                                    return Column(
                                      spacing: Sizes.spaceBtwInputField,
                                      children: [
                                        PrimaryButton(
                                          onPressed: (){
                                            if (_formKey.currentState!.validate()) {
                                              context.read<AuthBloc>().add(LoginRequested(
                                                phoneNumber: _phoneController.text.trim(),
                                                password: _passwordController.text.trim(),
                                                isClient: true,
                                              ));
                                            }
                                          },
                                          title: "Login as Client",
                                        ),

                                        COutlineButton(
                                          onPressed: (){
                                            if (_formKey.currentState!.validate()) {
                                              context.read<AuthBloc>().add(LoginRequested(
                                                phoneNumber: _phoneController.text.trim(),
                                                password: _passwordController.text.trim(),
                                              ));
                                            }
                                          },
                                          title: "Login as Vendor",
                                        ),
                                      ],
                                    );
                                  }
                              ),

                            ],
                          ),
                        ),
                      ),

                      CRichTextButton(
                        onPressed: (){
                          Navigator.pushNamed(context, RouteConstants.registerClientScreen);
                        },
                        title: "Don't have an client account?",
                        btnLabel: "Create Account",
                      ),
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
