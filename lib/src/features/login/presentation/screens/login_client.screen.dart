
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_header.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_outline_button.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/primary_button.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/rich_text_button.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text_field.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_status_bar.widget.dart';

class LoginClientScreen extends StatefulWidget {
  const LoginClientScreen({super.key});

  @override
  State<LoginClientScreen> createState() => _LoginClientScreenState();
}

class _LoginClientScreenState extends State<LoginClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = HelperFunctions.isDarkMode(context);
    return CStatusBar(
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.sm),
              child: Align(
                alignment: AlignmentGeometry.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: Sizes.spaceBtwSections,
                  children: [
                    AppHeader(subtitle: "Login with your Client account"),
                    CCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          spacing: Sizes.spaceBtwInputField,
                          children: [
                            CTextField(
                              controller: _phoneNumberController,
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
                                    onPressed: (){},
                                    child: Text("Forgot Password?"),
                                  ),
                                ),
                              ],
                            ),
                            PrimaryButton(
                              onPressed: (){
                                Navigator.pushNamedAndRemoveUntil(context, RouteConstants.mainClientScreen, (r) => false);
                              },
                              title: "Login as Client",
                            ),
                            COutlineButton(
                              onPressed: (){
                                Navigator.pushNamed(context, RouteConstants.loginVendorScreen);
                              },
                              title: "Login as Vendor",
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
    );
  }
}
