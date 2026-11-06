import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/constants/sizes.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/body_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/label_text.widget.dart';
import 'package:smart_reload_system/src/core/presentation/widgets/custom_text/title_text.widget.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

///USAGE
// AppBottomSheet.showInfo(
//   context,
//   title: 'Reload Successful',
//   subtitle: 'Your connection has been topped up successfully.',
//   buttonText: 'Done',
// );

///--------------------------------------------------------------->
// AppBottomSheet.showForm(
//   context,
//   title: 'Enter Amount',
//   form: TextFormField(
//     controller: amountController,
//     keyboardType: TextInputType.number,
//     decoration: const InputDecoration(labelText: 'Amount'),
//   ),
//   buttonText: 'Continue',
//   onSubmit: () {
//     Navigator.of(context).pop();
//     // proceed with amountController.text
//   },
// );

///--------------------------------------------------------------->
// final result = await AppBottomSheet.showRadioSelect(
//   context,
//   title: 'Select Package Type',
//   options: ['Data', 'Voice', 'SMS', 'Combo'],
//   selectedValue: 'Data',
// );
// if (result != null) {
//   // use result
//   debugPrint(result);
// }


class AppBottomSheet {
  AppBottomSheet._();

  /// 1. Title + subtitle + single OK/action button.
  static Future<void> showInfo(
      BuildContext context, {
        required String title,
        required String subtitle,
        bool isDark = false,
        String buttonText = 'OK',
        List<String>? points,
        VoidCallback? onPressed,
        ValueNotifier<bool>? isLoading,
      }) {

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetShell(
        isDark: isDark,
        child: _InfoContent(
          title: title,
          subtitle: subtitle,
          buttonText: buttonText,
          points: points ?? [],
          isLoading: isLoading ?? ValueNotifier<bool>(false),
          onPressed: onPressed,
        ),
      ),
    );
  }

  /// 2. Title + custom form content + submit button.
  static Future<T?> showForm<T>(
      BuildContext context, {
        bool isDark = false,
        required String title,
        required Widget form,
        required String buttonText,
        required VoidCallback onSubmit,
        ValueListenable<bool>? isLoading,
      }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetShell(
        isDark: isDark,
        child: _FormContent(
          isDark: isDark,
          title: title,
          form: form,
          buttonText: buttonText,
          onSubmit: onSubmit,
          isLoading: isLoading ?? ValueNotifier(false),
        ),
      ),
    );
  }

  /// 3. Title + outline-pill style single-select options.
  /// Returns the selected option, or null if dismissed without confirming.
  static Future<String?> showRadioSelect(
      BuildContext context, {
        required String title,
        bool askConfirm = true,
        required List<String> options,
        bool isDark = false,
        String? selectedValue,
      }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetShell(
        isDark: isDark,
        child: _RadioSelectContent(
          isDark: isDark,
          title: title,
          askConfirm: askConfirm,
          options: options,
          selectedValue: selectedValue,
        ),
      ),
    );
  }
}

class _BottomSheetShell extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _BottomSheetShell({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkContainers : theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final List<String> points;
  final ValueNotifier<bool> isLoading;
  final VoidCallback? onPressed;

  const _InfoContent({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.points,
    this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText(text: title),
        const SizedBox(height: Sizes.sm),

        BodyText(text: subtitle, textAlign: TextAlign.center, color: AppColors.darkerGrey),

        if(points.isNotEmpty)...{
          Padding(
            padding: EdgeInsetsGeometry.only(left: Sizes.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: points.map((p){
                return Row(
                  children: [
                    Icon(Icons.arrow_right_outlined, size: 20,),
                    Flexible(child: BodyText(text: p, color: AppColors.darkGrey, size: 11,)),
                  ],
                );
              }).toList(),
            ),
          ),
        },

        const SizedBox(height: 24),

        ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, _) {

              return ElevatedButton(
                onPressed: loading ? null : (onPressed ?? () => Navigator.of(context).pop()),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(HelperFunctions.screenWidth(context), Sizes.buttonHeight),
                ),
                child:  loading ?
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ) : Text(buttonText),
              );
            }
        ),
      ],
    );
  }
}

class _FormContent extends StatelessWidget {
  final String title;
  final Widget form;
  final String buttonText;
  final VoidCallback onSubmit;
  final ValueListenable<bool> isLoading;
  final bool isDark;

  const _FormContent({
    required this.title,
    required this.form,
    required this.buttonText,
    required this.onSubmit,
    required this.isLoading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText(text: title, color: isDark ? AppColors.white : null,),
        const SizedBox(height: 16),

        form,
        const SizedBox(height: 20),

        ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, _) {

            return ElevatedButton(
              onPressed: loading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(HelperFunctions.screenWidth(context), Sizes.buttonHeight),
              ),
              child:  loading ?
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ) : Text(buttonText),
            );
          }
        ),
      ],
    );
  }
}

class _RadioSelectContent extends StatefulWidget {
  final String title;
  final bool askConfirm;
  final List<String> options;
  final String? selectedValue;
  final bool isDark;

  const _RadioSelectContent({
    required this.title,
    required this.askConfirm,
    required this.options,
    this.selectedValue,
    required this.isDark,
  });

  @override
  State<_RadioSelectContent> createState() => _RadioSelectContentState();
}

class _RadioSelectContentState extends State<_RadioSelectContent> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText(text: widget.title, color: widget.isDark ? AppColors.white : AppColors.black),
        const SizedBox(height: 16),
        ...widget.options.map((option) {
          final isSelected = option == _selected;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() => _selected = option);
                if(!widget.askConfirm) {
                  Navigator.of(context).pop(option);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.secondary : theme.colorScheme.outline.withValues(alpha: 0.5),
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? AppColors.secondary.withValues(alpha: 0.08) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: LabelText(
                        text: option,
                        isBold: isSelected,
                        size: 13,
                        color: isSelected ? AppColors.secondary : widget.isDark ? AppColors.white : AppColors.black,
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: isSelected ? AppColors.secondary : widget.isDark ? AppColors.white : AppColors.black,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        if(widget.askConfirm)...{
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _selected == null ? null : () => Navigator.of(context).pop(_selected),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(HelperFunctions.screenWidth(context), Sizes.buttonHeight),
            ),
            child: const Text('Confirm'),
          ),

        }
      ],
    );
  }
}