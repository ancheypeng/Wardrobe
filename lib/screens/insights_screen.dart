import 'package:flutter/material.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/models/outfit_model.dart';
import 'package:wardrobe/widgets/color_chart.dart';
import 'package:wardrobe/widgets/item_category_chart.dart';

class InsightsScreen extends StatefulWidget {
  final List<Item> items;
  final List<Outfit> outfits;

  const InsightsScreen({Key key, this.items, this.outfits}) : super(key: key);

  @override
  _InsightsScreenState createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<Item> _items;
  List<Outfit> _outfits;

  @override
  void initState() {
    _items = widget.items;
    _outfits = widget.outfits;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(28.0, 60.0, 28.0, 10.0),
      children: [
        Center(
          child: Text(
            'Welcome to Insights!',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Text(
          'Here, you can learn about your clothing habits, wardrobe diversity, and tips for improving your style.',
          style: TextStyle(
            fontSize: 18.0,
          ),
          textAlign: TextAlign.center,
        ),
        _buildChartTitle('Color Breakdown'),
        _buildChart(
          ColorChart(
            items: _items,
          ),
          'circle',
          'Low Color Diveristy',
          'Adding more colors to your wardrobe can create more variation and interesting outfits!',
        ),
        _buildChartTitle('Clothing Breakdown'),
        _buildChart(
          ItemCategoryChart(
            items: _items,
          ),
          'rectangle',
          'Clothing Ratio',
          'We recommend a ratio of about 3-4 tops to each bottom for more outfit diversity!',
        ),
        SizedBox(
          height: 50,
        )
      ],
    );
  }

  Padding _buildChartTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 40.0, 0, 0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w300,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Padding _buildChart(
      Widget chart, String shape, String alertTitle, String alertContent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 30, 20, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 240,
            width: 240,
            child: Container(
              decoration: BoxDecoration(
                shape: shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
                borderRadius:
                    shape == 'circle' ? null : BorderRadius.circular(15.0),
                color: Colors.grey[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 5), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: shape == 'circle'
                    ? EdgeInsets.all(0)
                    : EdgeInsets.all(10.0),
                child: chart,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              _showDialog(alertTitle, alertContent);
            },
          )
        ],
      ),
    );
  }

  void _showDialog(String title, String content) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline),
              SizedBox(width: 10.0),
              Text(title),
            ],
          ),
          content: Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
