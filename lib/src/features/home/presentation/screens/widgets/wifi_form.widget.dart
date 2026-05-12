import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_dropdown.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/encoder_functions.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class WifiForm extends StatefulWidget {
  final Function(String) onChanged;
  final String label;
  final String defaultValue;
  final bool isUpdate;

  const WifiForm({
    super.key,
    required this.onChanged,
    required this.label,
    this.isUpdate = false,
    this.defaultValue = '',
  });

  @override
  State<WifiForm> createState() => _WifiFormState();
}

class _WifiFormState extends State<WifiForm> {
  final TextEditingController _networkNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<String> wifiNetworkType = ['WEP','WPA/WPA2', 'No Encryption'];

  late String _selectedNetworkType;

  bool checkedValue = false;
  bool obscurePass = false;

  String buildWifiFormat(){
    String result = EncoderFunctions.encodeWifi(
      netWorkName: _networkNameController.text.trim(),
      selectedNetworkType: _selectedNetworkType,
      password: _passwordController.text.trim(),
      checkedValue: checkedValue,
    );
    return result;
  }

  void updateSettings(){

    Map<String, String> result = EncoderFunctions.decodeWifi(value: widget.defaultValue);

    setState(() {
      _networkNameController.text = result['SSID']!;
      _selectedNetworkType = result['Type']!;
      _passwordController.text = result['Password']!;
      checkedValue = bool.parse(result['Hidden']!);
    });
  }

  @override
  void initState() {
    _selectedNetworkType = wifiNetworkType.first;
    if(widget.isUpdate)updateSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = HelperFunctions.isDarkMode(context);
    return Column(
      children: [
        TextField(
          controller: _networkNameController,
          enableSuggestions: true,
          decoration: InputDecoration(
            labelText: "Network name",
            labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.grey: AppColors.darkerGrey
            ),
            alignLabelWithHint: true,
          ),
          onChanged: (v){
            String result = buildWifiFormat();
            widget.onChanged(result);
          },
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: Sizes.spaceBtwInputField),
        CDropDown(
          label: 'Select Network type',
          selectedType: _selectedNetworkType,
          items: wifiNetworkType,
          onChanged: (String? newValue) {
            setState(() => _selectedNetworkType = newValue!);
            String result = buildWifiFormat();
            widget.onChanged(result);
          },
        ),
        const SizedBox(height: Sizes.spaceBtwInputField),
        TextField(
          controller: _passwordController,
          enableSuggestions: true,
          obscureText: obscurePass,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.grey: AppColors.darkerGrey
            ),
            suffixIcon: IconButton(
              onPressed: ()=> setState(() {
                obscurePass = !obscurePass;
              }),
              icon: Icon(obscurePass ? Icons.visibility_rounded : Icons.visibility_off_rounded),
            ),
            alignLabelWithHint: true,
          ),
          onChanged: (v){
            String result = buildWifiFormat();
            widget.onChanged(result);
          },
          keyboardType: TextInputType.multiline,
        ),
        CheckboxListTile(
          visualDensity: const VisualDensity(horizontal: -4),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
          title: const Text("Hidden"),
          splashRadius: 0,
          value: checkedValue,
          onChanged: (newValue) {
            setState(() => checkedValue = newValue!);
            String result = buildWifiFormat();
            widget.onChanged(result);
          },
          controlAffinity: ListTileControlAffinity.platform,
        ),
      ],
    );
  }
}
