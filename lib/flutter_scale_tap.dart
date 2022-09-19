library flutter_scale_tap;

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const double _DEFAULT_SCALE_MIN_VALUE = 0.95;
const double _DEFAULT_OPACITY_MIN_VALUE = 0.90;
// ignore: non_constant_identifier_names
final Curve _DEFAULT_SCALE_CURVE = CurveSpring();
const Curve _DEFAULT_OPACITY_CURVE = Curves.ease;
const Duration _DEFAULT_DURATION = Duration(milliseconds: 300);

class ScaleTapConfig {
  static double? scaleMinValue;
  static Curve? scaleCurve;
  static double? opacityMinValue;
  static Curve? opacityCurve;
  static Duration? duration;
}

class ScaleTapInfo {
  ScaleTapInfo({
    required this.tag,
    this.consumed = false,
  });

  final String tag;
  bool consumed;

  static final _default = ScaleTapInfo(tag: "default");
}

class ScaleTap extends StatefulWidget {
  final ScaleTapInfo? info;
  final Function()? onPressed;
  final Function()? onLongPress;
  final Widget? child;
  final Duration? duration;
  final double? scaleMinValue;
  final Curve? scaleCurve;
  final Curve? opacityCurve;
  final double? opacityMinValue;
  final bool enableFeedback;

  const ScaleTap({
    Key? key,
    this.info,
    this.enableFeedback = true,
    this.onPressed,
    this.onLongPress,
    required this.child,
    this.duration,
    this.scaleMinValue,
    this.opacityMinValue,
    this.scaleCurve,
    this.opacityCurve,
  }) : super(key: key);

  @override
  State<ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  ScaleTapInfo get _info => widget.info ?? ScaleTapInfo._default;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 1.0).animate(_animationController);
    _opacity = Tween<double>(begin: 1.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> anim({double? scale, double? opacity, Duration? duration}) {
    _animationController.stop();
    _animationController.duration = duration ?? Duration.zero;

    _scale = Tween<double>(
      begin: _scale.value,
      end: scale,
    ).animate(CurvedAnimation(
      curve: widget.scaleCurve ?? ScaleTapConfig.scaleCurve ?? _DEFAULT_SCALE_CURVE,
      parent: _animationController,
    ));
    _opacity = Tween<double>(
      begin: _opacity.value,
      end: opacity,
    ).animate(CurvedAnimation(
      curve: widget.opacityCurve ?? ScaleTapConfig.opacityCurve ?? _DEFAULT_OPACITY_CURVE,
      parent: _animationController,
    ));
    _animationController.reset();
    return _animationController.forward();
  }

  Future<void> _onTapDown(_) {
    if (_info.consumed == true) return Future.value();
    _info.consumed = true;

    return anim(
      scale: widget.scaleMinValue ?? ScaleTapConfig.scaleMinValue ?? _DEFAULT_SCALE_MIN_VALUE,
      opacity: widget.opacityMinValue ?? ScaleTapConfig.opacityMinValue ?? _DEFAULT_OPACITY_MIN_VALUE,
      duration: widget.duration ?? ScaleTapConfig.duration ?? _DEFAULT_DURATION,
    );
  }

  Future<void> _onTapUp(_) {
    _info.consumed = false;

    return anim(
      scale: 1.0,
      opacity: 1.0,
      duration: widget.duration ?? ScaleTapConfig.duration ?? _DEFAULT_DURATION,
    );
  }

  Future<void> _onTapCancel(_) {
    return _onTapUp(_);
  }

  @override
  Widget build(BuildContext context) {
    final bool isTapEnabled = widget.onPressed != null || widget.onLongPress != null;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, Widget? child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            alignment: Alignment.center,
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: Listener(
        onPointerDown: isTapEnabled ? _onTapDown : null,
        onPointerCancel: _onTapCancel,
        onPointerUp: _onTapUp,
        child: GestureDetector(
          onTap: isTapEnabled
              ? () {
                  if (widget.enableFeedback) {
                    SystemSound.play(SystemSoundType.click);
                  }
                  widget.onPressed?.call();
                }
              : null,
          onLongPress: isTapEnabled ? widget.onLongPress : null,
          child: widget.child,
        ),
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
