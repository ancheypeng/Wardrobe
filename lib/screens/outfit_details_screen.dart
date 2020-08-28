import 'package:flutter/material.dart';
import 'package:wardrobe/database/db_helper.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/models/outfit_model.dart';
import 'package:wardrobe/widgets/outfit_card.dart';

import 'item_details_screen.dart';
import 'outfit_form_screen.dart';

class OutfitDetailsScreen extends StatelessWidget {
  final DbHelper dbHelper;
  final List<Item> itemsInOutfit;
  final Outfit outfit;

  const OutfitDetailsScreen(
      {Key key, this.outfit, this.itemsInOutfit, this.dbHelper})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(outfit.seasonNames);
    return Scaffold(
      appBar: AppBar(
        title: Text(outfit.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              edit(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 60.0),
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: 40.0),
                _buildImagePreview(context),
                SizedBox(height: 20.0),
                Text(
                  outfit.name,
                  style: TextStyle(fontSize: 22.0),
                ),
                Text(
                  "Category: " + outfit.category,
                  style: TextStyle(fontSize: 22.0),
                ),
                Text(
                  "Seasons: ",
                  style: TextStyle(fontSize: 22.0),
                ),
                buildSeasonChips(),
                SizedBox(height: 20.0),
                Text(
                  "Items in This Outfit: ",
                  style: TextStyle(fontSize: 22.0),
                ),
                SizedBox(height: 20.0),
                buildItemTiles(context),
                SizedBox(height: 50.0),
              ],
            )
          ],
        ),
      ),
    );
  }

  GestureDetector _buildImagePreview(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 200,
        child: OutfitCard(
          outfit: outfit,
          itemsInOutfit: itemsInOutfit,
        ),
      ),
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => FullImageScreen(
        //       item: item,
        //     ),
        //   ),
        // );
      },
    );
  }

  Wrap buildSeasonChips() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 15.0, // gap between adjacent chips
      runSpacing: 0, // gap between lines
      children: outfit.seasonNames
          .map(
            (name) => Chip(
              label: Text(
                name,
                style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget buildItemTiles(BuildContext context) {
    return Column(
      children: itemsInOutfit
          .map(
            (item) => Card(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: item.imageWidget,
                  ),
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                subtitle: Text(
                  item.color,
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  _showItemDetails(context, item);
                },
              ),
            ),
          )
          .toList(),
    );
  }

  void _showItemDetails(BuildContext context, Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailsScreen(
          dbHelper: dbHelper,
          item: item,
        ),
      ),
    ).then((val) {
      if (val == 'refresh') {
        Navigator.of(context).pop('refresh');
      }
    });
  }

  void edit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OutfitFormScreen(
          dbHelper: dbHelper,
          outfit: outfit,
          itemsInOutfit: itemsInOutfit,
        ),
      ),
    ).then((val) {
      if (val == 'refresh') {
        Navigator.of(context).pop('refresh');
      }
    });
  }

  void showDeleteDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline),
              SizedBox(width: 10.0),
              Text('Delete this item?'),
            ],
          ),
          content: Text('Deleting this item will remove it from all outfits.'),
          actions: <Widget>[
            RaisedButton(
              child: Text('Confirm'),
              onPressed: () {
                delete(context);
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void delete(BuildContext context) async {
    await dbHelper.deleteOutfit(outfit.id);

    //Navigator.popUntil(context, ModalRoute.withName('/homeScreen'));
    Navigator.pop(context); //pop to close dialog
    Navigator.of(context).pop('refresh'); //pop to previous screen
  }
}
