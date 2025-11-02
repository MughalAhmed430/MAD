import 'package:flutter/material.dart';

class FadeScaleTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double beginScale;
  final double endScale;

  const FadeScaleTransition({
    Key? key,
    required this.animation,
    required this.child,
    this.beginScale = 0.95,
    this.endScale = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, childWidget) {
        final value = animation.value;
        final scale = beginScale + (endScale - beginScale) * value;
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: scale,
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}

/// [scrollPercent] should be -1.0 .. 1.0 where 0.0 means centered.
class ParallaxContainer extends StatelessWidget {
  final double scrollPercent;
  final Widget child;
  final double depth;

  const ParallaxContainer({
    Key? key,
    required this.scrollPercent,
    required this.child,
    this.depth = 30.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dx = scrollPercent * depth;
    return Transform.translate(
      offset: Offset(dx, 0),
      child: child,
    );
  }
}

class SimpleGradientOverlay extends StatelessWidget {
  final double progress;
  final Widget child;

  const SimpleGradientOverlay({
    Key? key,
    required this.progress,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.12),
        Colors.white.withOpacity(0.0),
      ],
      stops: [0.0, 0.5 + (progress * 0.5), 1.0],
      begin: Alignment(-1.0 - progress, -0.3),
      end: Alignment(1.0 - progress, 0.3),
    );

    return Stack(
      children: [
        child,
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
            ),
          ),
        )
      ],
    );
  }
}
