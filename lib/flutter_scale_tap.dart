library flutter_scale_tap;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ScaleTapConfig {
  static double scaleMinValue = 0.95;
  static Curve scaleCurve = CurveSpring();
  static double opacityMinValue = 0.90;
  static Curve opacityCurve = Curves.ease;
  static Duration scaleOpacityAnimationDuration = const Duration(milliseconds: 300);
  static Duration buttonAnimationDuration = const Duration(milliseconds: 300);
}

class ScaleTap extends StatefulWidget {
  final Function() onPressed;
  final Function() onLongPress;
  final Widget child;
  final Duration scaleOpacityAnimationDuration;
  final Duration buttonAnimationDuration;
  final double scaleMinValue;
  final Curve scaleCurve;
  final Curve opacityCurve;
  final double opacityMinValue;
  final VisualDensity visualDensity;
  final TextStyle textStyle;
  final MouseCursor mouseCursor;
  final bool autofocus;
  final FocusNode focusNode;
  final bool enableFeedback;
  final Clip clipBehavior;
  final Color fillColor;
  final EdgeInsets padding;
  final ShapeBorder shape;
  final MaterialTapTargetSize materialTapTargetSize;
  final BoxConstraints constraints;
  final double elevation;
  final Color focusColor;
  final double focusElevation;
  final Color highlightColor;
  final double highlightElevation;
  final double hoverElevation;
  final Color hoverColor;
  final double disabledElevation;
  final ValueChanged<bool> onHighlightChanged;
  final Color splashColor;

  ScaleTap({
    this.onPressed,
    this.onLongPress,
    this.child,
    this.scaleMinValue,
    this.opacityMinValue,
    this.scaleCurve,
    this.opacityCurve,
    this.visualDensity,
    this.textStyle,
    this.mouseCursor,
    this.autofocus = false,
    this.focusNode,
    this.enableFeedback = true,
    this.clipBehavior,
    this.scaleOpacityAnimationDuration,
    this.buttonAnimationDuration,
    this.fillColor,
    this.focusColor,
    this.padding,
    this.shape,
    this.materialTapTargetSize,
    this.constraints,
    this.focusElevation,
    this.elevation,
    this.disabledElevation,
    this.highlightColor,
    this.hoverElevation,
    this.hoverColor,
    this.highlightElevation,
    this.onHighlightChanged,
    this.splashColor,
  });

  @override
  _ScaleTapState createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scale;
  Animation<double> _opacity;

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
    _animationController?.dispose();
    super.dispose();
  }

  Curve get _computedScaleCurve {
    return widget.scaleCurve ?? ScaleTapConfig.scaleCurve ?? CurveSpring();
  }

  Curve get _computedOpacityCurve {
    return widget.opacityCurve ?? ScaleTapConfig.opacityCurve ?? Curves.ease;
  }

  Duration get _computedScaleOpacityAnimationDuration {
    return widget.scaleOpacityAnimationDuration ?? ScaleTapConfig.scaleOpacityAnimationDuration ?? Duration.zero;
  }

  Duration get _computedButtonAnimationDuration {
    return widget.buttonAnimationDuration ?? ScaleTapConfig.buttonAnimationDuration ?? Duration.zero;
  }

  Future<void> anim({double scale, double opacity, Duration duration}) {
    _animationController?.stop();
    _animationController.duration = duration ?? Duration.zero;

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
    _animationController?.reset();
    return _animationController?.forward();
  }

  Future<void> _onTapDown(_) {
    return anim(
      scale: widget.scaleMinValue ?? ScaleTapConfig.scaleMinValue,
      opacity: widget.opacityMinValue ?? ScaleTapConfig.opacityMinValue,
      duration: _computedScaleOpacityAnimationDuration,
    );
  }

  Future<void> _onTapUp(_) {
    return anim(
      scale: 1.0,
      opacity: 1.0,
      duration: _computedScaleOpacityAnimationDuration,
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
      builder: (_, Widget child) {
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
        child: RawMaterialButton(
          padding: widget.padding ?? EdgeInsets.zero,
          shape: widget.shape,
          materialTapTargetSize: widget.materialTapTargetSize ?? MaterialTapTargetSize.shrinkWrap,
          clipBehavior: widget.clipBehavior ?? Clip.none,
          constraints: widget.constraints ?? BoxConstraints(),
          animationDuration: _computedButtonAnimationDuration,
          fillColor: widget.fillColor ?? Colors.transparent,
          focusColor: widget.focusColor ?? Colors.transparent,
          focusElevation: widget.focusElevation ?? 0.0,
          elevation: widget.elevation ?? 0.0,
          highlightColor: widget.highlightColor ?? Colors.transparent,
          highlightElevation: widget.highlightElevation ?? 0.00,
          hoverElevation: widget.hoverElevation ?? 0.0,
          hoverColor: widget.hoverColor ?? Colors.transparent,
          splashColor: widget.splashColor ?? Colors.transparent,
          onPressed: isTapEnabled ? widget.onPressed : null,
          onLongPress: isTapEnabled ? widget.onLongPress : null,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          enableFeedback: widget.enableFeedback,
          mouseCursor: widget.mouseCursor,
          textStyle: widget.textStyle,
          visualDensity: widget.visualDensity,
          disabledElevation: widget.disabledElevation ?? 0.0,
          child: widget.child,
          onHighlightChanged: widget.onHighlightChanged,
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
