
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/utils/helpers/encoder_functions.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class EmailForm extends StatefulWidget {
  final Function(String) onChanged;
  final String label;
  final String defaultValue;
  final bool isUpdate;

  const EmailForm({
    super.key,
    required this.onChanged,
    required this.label,
    this.isUpdate = false,
    this.defaultValue = '',
  });

  @override
  State<EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _sentToController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  String buildEmailFormat(){
    String result = EncoderFunctions.encodeEmail(
      bodyValue: _bodyController.text.trim(),
      sub: _subjectController.text.trim(),
      sentTo: _sentToController.text.trim(),
    );
    return result;
  }

  void updateSettings(){
    Map<String, String> result = EncoderFunctions.decodeEmail(value: widget.defaultValue);
    setState(() {
      _bodyController.text = result['Body']!;
      _sentToController.text = result['SendTo']!;
      _subjectController.text = result['Subject']!;
    });
  }

  @override
  void initState() {
    if(widget.isUpdate)updateSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = HelperFunctions.isDarkMode(context);
    return Column(
      children: [
        TextField(
          controller: _sentToController,
          enableSuggestions: true,
          onChanged: (v){
            String result = buildEmailFormat();
            widget.onChanged(result);
          },
          decoration: InputDecoration(
            labelText: "Send to",
            labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.grey: AppColors.darkerGrey
            ),
            alignLabelWithHint: true,
          ),
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: Sizes.spaceBtwInputField),
        TextField(
          controller: _subjectController,
          enableSuggestions: true,
          onChanged: (v){
            String result = buildEmailFormat();
            widget.onChanged(result);
          },
          decoration: InputDecoration(
            labelText: "Subject",
            labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.grey: AppColors.darkerGrey
            ),
            alignLabelWithHint: true,
          ),
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: Sizes.spaceBtwInputField),
        TextField(
          controller: _bodyController,
          maxLines: 5,
          minLines: 4,
          enableSuggestions: true,
          onChanged: (v){
            String result = buildEmailFormat();
            widget.onChanged(result);
          },
          decoration: InputDecoration(
            labelText: "Enter body",
            labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.grey: AppColors.darkerGrey
            ),
            alignLabelWithHint: true,
          ),
          keyboardType: TextInputType.multiline,
        )
      ],
    );
  }
}
