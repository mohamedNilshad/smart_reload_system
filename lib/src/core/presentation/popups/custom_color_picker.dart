import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';

Future<Color?> showColorPicker({required BuildContext context, required Color selectedColor}) async  {
  Color tempColor = selectedColor;
  return showDialog<Color>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Pick a Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (color) => tempColor = color,
            enableAlpha: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, tempColor),
            child: const Text(AppStrings.okLabel),
          ),
        ],
      );
    },
  );
}

class CColorPicker extends StatefulWidget {
  final String title;
  final Function(Color) onPressed;
  final Color selectedColor;
  const CColorPicker({super.key, required this.title, required this.onPressed, required this.selectedColor});

  @override
  State<CColorPicker> createState() => _CColorPickerState();
}

class _CColorPickerState extends State<CColorPicker> {
  late Color selectedColor;

  @override
  void initState() {
    selectedColor = widget.selectedColor;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium,),
          GestureDetector(
            onTap: () async {
              Color? pickedColor = await showColorPicker(context: context, selectedColor: widget.selectedColor);
              if (pickedColor != null) {
                setState(() => selectedColor = pickedColor);
                widget.onPressed(selectedColor);

              }
            },
            child: Container(
              width: 25,
              height: 25,
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.only(right: 10.0),
              decoration: BoxDecoration(
                color: selectedColor.alpha == 0 ? null : selectedColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                image: selectedColor.alpha == 0 ? const DecorationImage(image: AssetImage('assets/transparent_bg.png')) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
