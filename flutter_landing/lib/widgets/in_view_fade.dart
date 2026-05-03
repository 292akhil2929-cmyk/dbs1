import 'package:animate_do/animate_do.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class InViewFade extends StatefulWidget {
  const InViewFade({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 18,
  });

  final Widget child;
  final Duration delay;
  final double offsetY;

  @override
  State<InViewFade> createState() => _InViewFadeState();
}

class _InViewFadeState extends State<InViewFade> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.key ?? widget.child.hashCode),
      onVisibilityChanged: (info) {
        if (_shown) return;
        if (info.visibleFraction > 0.12) setState(() => _shown = true);
      },
      child: _shown
          ? FadeInUp(
              from: widget.offsetY,
              duration: const Duration(milliseconds: 520),
              delay: widget.delay,
              child: widget.child,
            )
          : Opacity(opacity: 0, child: widget.child),
    );
  }
}

