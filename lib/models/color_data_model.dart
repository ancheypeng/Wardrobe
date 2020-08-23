import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class ColorData {
  final String color;
  int count;
  final charts.Color graphColor;

  ColorData(this.color, this.count, Color graphColor)
      : this.graphColor = new charts.Color(
            r: graphColor.red,
            g: graphColor.green,
            b: graphColor.blue,
            a: graphColor.alpha);

  void increment() {
    count += 1;
  }
}
