import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/constants/svg_strings.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/app_snackbar.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_app_bars/custom_app_bar_2.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_buttons/custom_outline_button.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_card.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/headline_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/label_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/sub_title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/svg_builder.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/core/domain/entity/user.entity.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/auth.bloc.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/auth.event.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/auth.state.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.state.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDark;
  const ProfileScreen({super.key, this.isDark = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserEntity user;

  bool isDark = false;

  @override
  void initState() {
    isDark = widget.isDark;
    _initValues();
    super.initState();
  }

  void _initValues(){
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) {
      user = sessionState.user;
    }

  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          AppSnackbar.showError(context, state.message);
        } else if (state is AuthLogoutSuccess) {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteConstants.loginScreen,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldVendor : null,
        appBar: customAppBar(title: "Profile", isDark: isDark),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.ssm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 55.0,
                  backgroundColor: AppColors.secondary,
                  child: HeadlineText(
                    text: HelperFunctions.getInitials(user.fullName),
                    color: AppColors.white,
                    size: 45,
                  ),
                ),
                SizedBox(height: 10),
                HeadlineText(text: user.fullName, color: isDark ? AppColors.white : null,),
                SubTitleText(
                  text: HelperFunctions.maskPhoneNumber(user.phoneNumber),
                  color: isDark ? AppColors.grey : AppColors.darkerGrey,
                ),
                SizedBox(height: 20),
                CCard(
                  isDark: isDark,
                  child: Column(
                    spacing: 5,
                    children: [
                      buildOption(
                        onTap: () {
                          Navigator.of(context).pushNamed(RouteConstants.editProfileScreen, arguments: isDark).then((_){
                            _initValues();
                          });
                        },
                        context,
                        icon: SvgStrings.user,
                        leadColor: AppColors.secondary,
                        title: "Edit Profile",
                        subtitle: "Update your details",
                      ),
                      Divider(),
                      buildOption(
                        onTap: () {
                          Navigator.of(context).pushNamed(RouteConstants.resetPasswordScreen, arguments: isDark);
                        },
                        context,
                        icon: SvgStrings.shield,
                        leadColor: AppColors.purple,
                        title: "Security",
                        subtitle: "Change password",
                      ),
                      Divider(),
                      buildOption(
                        onTap: () => Navigator.of(context).pushNamed(RouteConstants.notificationScreen, arguments: isDark),
                        context,
                        icon: SvgStrings.notification,
                        leadColor: AppColors.accent,
                        title: "Notifications",
                        subtitle: "Manage alerts",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return COutlineButton(
                      onPressed: isLoading ? () {} : () => context.read<AuthBloc>().add(LogoutRequested()),
                      title: isLoading ? "Logging out..." : "Logout",
                      icon: SvgStrings.logout,
                      fgColor: isLoading ? AppColors.buttonDisabled : AppColors.red,
                      bgColor: isLoading ? AppColors.darkerGrey : AppColors.red,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOption(BuildContext context, {required String icon, required Color leadColor, required String title, required String subtitle, void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        spacing: 10.0,
        children: [
          Container(
            padding: EdgeInsets.all(Sizes.md),
            decoration: BoxDecoration(
              color: leadColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
            ),
            child: CSvgBuilder(
              path: icon,
              width: 20,
              colorFilter: ColorFilter.mode(leadColor, BlendMode.srcIn),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5.0,
            children: [
              TitleText(
                text: title,
                color: isDark ? AppColors.white : null,
              ),
              LabelText(
                text: subtitle,
                color: isDark ? AppColors.grey : AppColors.darkerGrey,
              ),
            ],
          ),
          Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: isDark ? AppColors.grey : AppColors.darkGrey,
          ),
        ],
      ),
    );
  }
}
