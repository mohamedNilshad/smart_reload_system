
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

class LoginVendorScreen extends StatefulWidget {
  const LoginVendorScreen({super.key});

  @override
  State<LoginVendorScreen> createState() => _LoginVendorScreenState();
}

class _LoginVendorScreenState extends State<LoginVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
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
                    AppHeader(subtitle: "Login with your Vendor account"),
                    CCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          spacing: Sizes.spaceBtwInputField,
                          children: [
                            CTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'you@example.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.mail_outline_rounded,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter email address';
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
                              onPressed: (){},
                              title: "Login as Vendor",
                            ),
                            COutlineButton(
                              onPressed: () => Navigator.pop(context),
                              title: "Login as Client",
                            ),
                          ],
                        ),
                      ),
                    ),

                    CRichTextButton(
                      onPressed: (){
                        Navigator.pushNamed(context, RouteConstants.registerVendorScreen);
                      },
                      title: "Don't have an vendor account?",
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
