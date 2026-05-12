import 'package:flutter/material.dart';

class MeasurementWidget extends StatelessWidget {
  final Widget widget;
  final double defaultWidth;
  final double width;
  final double height;
  final bool enable;

  const MeasurementWidget({
    super.key,
    required this.widget,
    required this.defaultWidth,
    required this.height,
    required this.width,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget,
              Visibility(
                visible: enable,
                child: Column(
                  children: [
                    const Expanded(
                      child: VerticalDivider(
                        color: Colors.red,
                        thickness: 2,
                      ),
                    ),
                    RotatedBox(quarterTurns: 1, child: Text(' ${height.toStringAsFixed(1)} mm ')),
                    const Expanded(
                      child: VerticalDivider(
                        color: Colors.red,
                        thickness: 2,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Visibility(
          visible: enable,
          child: Container(
            margin: const EdgeInsets.only(right: 18),
            width: defaultWidth,
            child: Row(
              children: [
                const Expanded(
                  child: Divider(
                    color: Colors.red,
                    thickness: 2,
                  ),
                ),
                Text(' ${width.toStringAsFixed(1)} mm '),
                const Expanded(
                  child: Divider(
                    color: Colors.red,
                    thickness: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
