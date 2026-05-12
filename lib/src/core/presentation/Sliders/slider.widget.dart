import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';

class CSlider extends StatelessWidget {
  final String title;
  final String unit;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final Color thumbColor;
  final Color activeColor;
  final Function(double)? onChanged;
  const CSlider({
    super.key,
    required this.title,
    required this.value,
    this.unit = 'pxl',
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.thumbColor = AppColors.primary,
    this.activeColor = AppColors.secondary,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    int? division = (divisions == null) ?((max * 2).round()).toInt() : divisions;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Expanded(
          child: Slider(
            thumbColor: AppColors.primary,
            activeColor: AppColors.secondary,
            value: value,
            min: min,
            max: max,
            divisions: division,
            onChanged: onChanged,
          ),
        ),
        Text('${value.toStringAsFixed(1)} $unit', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: 10.0),
      ],
    );
  }
}
