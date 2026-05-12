
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/constants/svg_strings.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text_field.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/svg_builder.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

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
    return SafeArea(
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Sizes.lg),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          spreadRadius: 70,
                          blurRadius: 70,
                          offset: Offset(0, 60),
                        ),
                      ],
                    ),
                    child: Column(
                      spacing: Sizes.md,
                      children: [
                        CSvgBuilder(path: SvgStrings.logoAngle),
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) {
                            return AppColors.linerGradient.createShader(bounds);
                          },
                          child: Text(
                            AppStrings.brandName,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          "Manage your bills",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.darkerGrey,
                          ),
                        )

                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Sizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(Sizes.borderRadiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.15),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        spacing: Sizes.spaceBtwInputField,
                        children: [
                          CTextField(
                            controller: _phoneNumberController,
                            label: 'Mobile Number',
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
