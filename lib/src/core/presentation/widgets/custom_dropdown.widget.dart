import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';

class CDropDown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String selectedType;
  final Function(String?) onChanged;

  const CDropDown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.selectedType,

  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedType,
      borderRadius: BorderRadius.circular(Sizes.sm),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Sizes.sm),
            borderSide: const BorderSide(color: AppColors.secondary)
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Sizes.sm),
            borderSide: const BorderSide(color: AppColors.secondary)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Sizes.sm),
            borderSide: const BorderSide(color: AppColors.success)
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.md),
      ),
    );
  }
}
