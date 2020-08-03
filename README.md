# ScaleTap

Scale/opacity button gesture detector

## Getting Started

Wrap your widget with ScaleTap

```Dart
ScaleTap(
  onTap: (){
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

## Parameters

ScaleTap

| Parameter name | Type | Description | Required | Default value |
|---|---|---|---|---|
| child | Widget | your child | yes | - |
| onTap | Function() | On tap callback | no | - |
| onLongPress | Function() | On long press callback | no | - |
| duration | Duration | Animation duration | no | Duration(milliseconds:300) |
| scaleMinValue | double | Min scale value | no | 0.95 |
| scaleCurve | Curve | Curve for scaling | no | Spring curve |
| opacityMinValue | double | Min opacity value | no | 0.9 |
| opacityCurve | Curve | Curve for opacity | no | Curve.ease |