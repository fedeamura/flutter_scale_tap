library flutter_scale_tap;

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

class ScaleTap extends StatefulWidget {
  final Function()? onTap;
  final Function()? onLongPress;
  final Widget? child;
  final Duration duration;
  final double scaleMinValue;
  final Curve? scaleCurve;
  final Curve? opacityCurve;
  final double opacityMinValue;

  ScaleTap({
    this.onTap,
    this.onLongPress,
    this.child,
    this.duration = const Duration(milliseconds: 300),
    this.scaleMinValue = 0.95,
    this.opacityMinValue = 0.9,
    this.scaleCurve,
    this.opacityCurve,
  });

  @override
  _ScaleTapState createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(_animationController);
    _opacity = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Curve get _computedScaleCurve {
    return widget.scaleCurve ?? CurveSpring();
  }

  Curve get _computedOpacityCurve {
    return widget.opacityCurve ?? Curves.ease;
  }

  Duration get _computedDuration {
    return widget.duration;
  }

  Future<void> anim({
    required double scale,
    required double opacity,
    required Duration duration,
  }) {
    _animationController.stop();
    _animationController.duration = duration;

    _scale = Tween<double>(
      begin: _scale.value,
      end: scale,
    ).animate(CurvedAnimation(
      curve: _computedScaleCurve,
      parent: _animationController,
    ));
    _opacity = Tween<double>(
      begin: _opacity.value,
      end: opacity,
    ).animate(CurvedAnimation(
      curve: _computedOpacityCurve,
      parent: _animationController,
    ));
    _animationController.reset();
    return _animationController.forward();
  }

  Future<void> _onTapDown(_) {
    return anim(
      scale: widget.scaleMinValue,
      opacity: widget.opacityMinValue,
      duration: _computedDuration,
    );
  }

  Future<void> _onTapUp(_) {
    return anim(
      scale: 1.0,
      opacity: 1.0,
      duration: _computedDuration,
    );
  }

  Future<void> _onTapCancel(_) {
    return _onTapUp(_);
  }

  Widget _container({required Widget child}) {
    if (widget.onTap != null || widget.onLongPress != null) {
      return Listener(
        onPointerDown: _onTapDown,
        onPointerCancel: _onTapCancel,
        onPointerUp: _onTapUp,
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: child,
        ),
      );
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    return _container(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, child) {
          return Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              alignment: Alignment.center,
              scale: _scale.value,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class CurveSpring extends Curve {
  final SpringSimulation sim;

  CurveSpring() : this.sim = _sim(70, 20);

  @override
  double transform(double t) => sim.x(t) + t * (1 - sim.x(1.0));
}

_sim(double stiffness, double damping) => SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: stiffness,
        ratio: 0.7,
      ),
      0.0,
      1.0,
      0.0,
    );
