import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/utils/helpers/encoder_functions.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class TextForm extends StatefulWidget {

  final Function(String) onChanged;
  final bool isText;
  final String label;
  final String defaultValue;

  const TextForm({
    super.key,
    this.isText = true,
    required this.label,
    required this.defaultValue,
    required this.onChanged,
  });

  @override
  State<TextForm> createState() => _TextFormState();
}

class _TextFormState extends State<TextForm> {
  final TextEditingController _textController = TextEditingController();

  String ensureUrl() {
    String result = EncoderFunctions.encodeLink(value: _textController.text.trim());
    return result;
  }

  @override
  void initState() {
    _textController.text = widget.defaultValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = HelperFunctions.isDarkMode(context);
    return TextField(
      controller: _textController,
      maxLines: widget.isText ? 5 : 1,
      minLines: widget.isText ? 4 : 1,
      maxLength: widget.isText ? 2000 : null,
      enableSuggestions: true,
      onChanged: (v){
        String result = widget.isText ? v : ensureUrl();
        widget.onChanged(result);
      },
      decoration: InputDecoration(
        labelText: "Enter ${widget.label}",
        labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isDark ? AppColors.grey: AppColors.darkerGrey
        ),
        alignLabelWithHint: true,
      ),
      keyboardType: TextInputType.multiline,
    );
  }
}
