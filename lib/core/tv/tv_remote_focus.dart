import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class TvFocusableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSelect;
  final double scaleFactor;
  final BorderRadius? borderRadius;

  const TvFocusableWidget({
    super.key,
    required this.child,
    this.onSelect,
    this.scaleFactor = 1.05,
    this.borderRadius,
  });

  @override
  State<TvFocusableWidget> createState() => _TvFocusableWidgetState();
}

class _TvFocusableWidgetState extends State<TvFocusableWidget> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    return Focus(
      onFocusChange: (focused) {
        setState(() => _isFocused = focused);
      },
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.onSelect?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onSelect,
        child: AnimatedScale(
          scale: _isFocused ? widget.scaleFactor : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: _isFocused ? AppColors.gold400 : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.gold400.withOpacity(0.35),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
