import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/bloc/theme/theme.bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeState) {
        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.settingsLabel), centerTitle: true,),
          body: Padding(
            padding: const EdgeInsets.all(Sizes.sm),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: Sizes.sm, right: Sizes.sm),
                  titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                  title: const Text('Theme'),
                  subtitle: Text(themeState.name),
                  trailing: Switch(
                    value: themeState == ThemeMode.dark,
                    onChanged: (value) {
                      context.read<ThemeBloc>().add(ChangeThemeEvent(value));
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: Sizes.sm, right: Sizes.sm),
                  titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                  title: const Text('Default Settings'),
                  subtitle: const Text('Change default values'),
                  trailing: const Icon(Icons.arrow_forward_ios_outlined),
                  onTap: (){
                    Navigator.pushNamed(context, RouteConstants.defaultSettingsScreen);
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
