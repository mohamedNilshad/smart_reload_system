import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

class DefaultTextForm extends StatefulWidget {

  final Function(String) onChanged;
  final int maxLength;
  final String label;
  final String defaultValue;

  const DefaultTextForm({
    super.key,
    required this.maxLength,
    required this.label,
    required this.defaultValue,
    required this.onChanged,
  });

  @override
  State<DefaultTextForm> createState() => _DefaultTextFormState();
}

class _DefaultTextFormState extends State<DefaultTextForm> {
  final TextEditingController _textController = TextEditingController();

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
      maxLines: widget.maxLength > 100 ? 5 : 1,
      minLines: widget.maxLength > 100 ? 4 : 1,
      maxLength: widget.maxLength,
      enableSuggestions: true,
      onChanged: widget.onChanged,
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
