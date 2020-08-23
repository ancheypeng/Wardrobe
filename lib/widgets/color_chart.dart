import 'package:flutter/material.dart';
import 'package:wardrobe/models/color_data_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:wardrobe/models/item_model.dart';

class ColorChart extends StatefulWidget {
  final List<Item> items;
  ColorChart({Key key, this.items}) : super(key: key);

  @override
  _ColorChart createState() => _ColorChart();
}

class _ColorChart extends State<ColorChart> {
  List<Item> _items;

  //final List<String> colors = ['Black', 'Grey', 'White', 'Navy', 'Blue'];
  List<ColorData> colorData = [];

  @override
  void initState() {
    _items = widget.items;

    for (Item item in _items) {
      String itemColor = item.color.toLowerCase();
      bool colorLogged = colorData.firstWhere(
              (element) => element.color == itemColor,
              orElse: () => null) !=
          null;
      if (colorLogged) {
        colorData
            .firstWhere((element) => element.color == itemColor)
            .increment();
      } else {
        switch (itemColor) {
          case "black":
            {
              colorData.add(new ColorData(itemColor, 1, Colors.black));
            }
            break;
          case "grey":
            {
              colorData.add(new ColorData(itemColor, 1, Colors.grey));
            }
            break;
          case "white":
            {
              colorData.add(new ColorData(itemColor, 1, Colors.white));
            }
            break;
          case "navy":
            {
              colorData.add(new ColorData(itemColor, 1, Colors.blue[900]));
            }
            break;
          case "blue":
            {
              colorData.add(new ColorData(itemColor, 1, Colors.blue[200]));
            }
            break;
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var series = [
      new charts.Series<ColorData, String>(
        id: 'Colors',
        domainFn: (ColorData data, _) => data.color,
        measureFn: (ColorData data, _) => data.count,
        colorFn: (ColorData data, _) => data.graphColor,
        data: colorData,
      ),
    ];

    Widget chart = new charts.PieChart(
      series,
      animate: true,
    );

    return chart;
  }
}
