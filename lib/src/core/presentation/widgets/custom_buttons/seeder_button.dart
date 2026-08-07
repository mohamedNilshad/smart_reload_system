import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/constants/app_colors.dart';
import 'package:smart_reload_system/src/core/presentation/screens/seeder.screen.dart';

class FloatingButtonOverlay {
  static OverlayEntry? _overlay;

  static void show(BuildContext context) {
    if (_overlay != null) return;

    _overlay = OverlayEntry(
      builder: (_) => const _DraggableFloatingButton(),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlay!);
  }

  static void hide() {
    _overlay?.remove();
    _overlay = null;
  }
}

class _DraggableFloatingButton extends StatefulWidget {
  const _DraggableFloatingButton();

  @override
  State<_DraggableFloatingButton> createState() =>
      _DraggableFloatingButtonState();
}

class _DraggableFloatingButtonState extends State<_DraggableFloatingButton> {
  double top = 120;
  double left = 300;
  bool enable = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Visibility(
      visible: enable,
      child: Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              left += details.delta.dx;
              top += details.delta.dy;

              // Keep inside screen bounds
              left = left.clamp(0.0, size.width - 56);
              top = top.clamp(0.0, size.height - 56);
            });
          },
          child: IconButton(
            onPressed: () {
              setState(() => enable = false);
              Navigator.of(context).push(MaterialPageRoute(builder: (_)=> SeederScreen())).then((_){
                setState(() => enable = true);
              });
            },
            icon: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.5),
              child: const Icon(Icons.add_circle_outline_rounded, color: AppColors.white, size: 30,),
            ),
          ),
        ),
      ),
    );
  }
}