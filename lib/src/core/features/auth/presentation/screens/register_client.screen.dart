
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/primary_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/rich_text_button.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text_field.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_status_bar.widget.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/auth.bloc.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/auth.event.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/auth.state.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                AppSnackbar.showSuccess(context, "Registration successful!");
              }
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CAppBar(
                    onPressed: () => Navigator.pop(context),
                    title: "Create account",
                    subtitle: "Join as a Client",
                  ),
                  Padding(
                    padding: const EdgeInsets.all(Sizes.sm),
                    child: Align(
                      alignment: AlignmentGeometry.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: Sizes.spaceBtwSections,
                        children: [
                          CCard(
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Please enter your NIC / ID card';
                                      return null;
                                    },
                                  ),
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
                                  CTextField(
                                    controller: _confirmPassController,
                                    label: 'Confirm Password',
                                    hint: '•••••••••',
                                    isPassword: true,
                                    keyboardType: TextInputType.visiblePassword,
                                    prefixIcon: Icons.lock_outline,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Please enter confirm password';
                                      return null;
                                    },
                                  ),

                                  BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        if (state is AuthLoading) return const CircularProgressIndicator();
                                        return PrimaryButton(
                                          onPressed: (){
                                            if (_formKey.currentState!.validate()) {
                                              context.read<AuthBloc>().add(RegisterRequested(
                                                fullName: _nameController.text.trim(),
                                                phoneNumber: _phoneController.text.trim(),
                                                email: _emailController.text.trim(),
                                                nic: _nicController.text.trim(),
                                                password: _passwordController.text.trim(),
                                              ));
                                            }
                                          },
                                          title: "Register Account",
                                        );
                                      }
                                  ),
                                ],
                              ),
                            ),
                          ),

                          CRichTextButton(
                            onPressed: ()=> Navigator.pop(context),
                            title: "Already have an account?",
                            btnLabel: "Login",
                          ),
                        ],
                      ),
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
