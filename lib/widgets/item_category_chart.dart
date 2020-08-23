import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:wardrobe/models/item_category_data_model.dart';
import 'package:wardrobe/models/item_model.dart';

class ItemCategoryChart extends StatefulWidget {
  final List<Item> items;
  ItemCategoryChart({Key key, this.items}) : super(key: key);

  @override
  _CategoryChart createState() => _CategoryChart();
}

class _CategoryChart extends State<ItemCategoryChart> {
  List<Item> _items;

  List<ItemCategoryData> itemCategoryData = [];

  @override
  void initState() {
    _items = widget.items;

    for (Item item in _items) {
      String itemCategory = item.category.toLowerCase();
      bool categoryLogged = itemCategoryData.firstWhere(
              (element) => element.category == itemCategory,
              orElse: () => null) !=
          null;
      if (categoryLogged) {
        itemCategoryData
            .firstWhere((element) => element.category == itemCategory)
            .increment();
      } else {
        switch (itemCategory) {
          case "tops":
            {
              itemCategoryData
                  .add(new ItemCategoryData(itemCategory, 1, Colors.blue[900]));
            }
            break;
          case "bottoms":
            {
              itemCategoryData
                  .add(new ItemCategoryData(itemCategory, 1, Colors.blue[200]));
            }
            break;
          case "accessories":
            {
              itemCategoryData
                  .add(new ItemCategoryData(itemCategory, 1, Colors.grey));
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
      new charts.Series<ItemCategoryData, String>(
        id: 'Item Categories',
        domainFn: (ItemCategoryData data, _) => data.category,
        measureFn: (ItemCategoryData data, _) => data.count,
        colorFn: (ItemCategoryData data, _) => data.graphColor,
        data: itemCategoryData,
      ),
    ];

    Widget chart = new charts.BarChart(
      series,
      animate: true,
    );

    return chart;
  }
}
