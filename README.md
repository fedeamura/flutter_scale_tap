# ScaleTap

Scale and opacity animated Button for Flutter

## Getting Started

Wrap your widget with ScaleTap

```Dart
ScaleTap(
  onPressed: (){
    //Tap
  },
  onLongPress: (){
    //Long press
  },
  child: Container(
    child: Text("Tap Me"),
  ),
)
```

You can change the default behaviour with the ScaleTapConfig class

```Dart
class ScaleTapConfig {
  static double scaleMinValue = 0.95;
  static Curve scaleCurve = CurveSpring();
  static double opacityMinValue = 0.90;
  static Curve opacityCurve = Curves.ease;
  static Duration scaleOpacityAnimationDuration = const Duration(milliseconds: 300);
  static Duration buttonAnimationDuration = const Duration(milliseconds: 300);
}
```

