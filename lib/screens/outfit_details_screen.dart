import 'package:flutter/material.dart';
import 'package:wardrobe/database/db_helper.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/models/outfit_model.dart';
import 'package:wardrobe/widgets/outfit_card.dart';

class OutfitDetailsScreen extends StatelessWidget {
  final DbHelper dbHelper;
  final List<Item> itemsInOutfit;
  final Outfit outfit;

  const OutfitDetailsScreen(
      {Key key, this.outfit, this.itemsInOutfit, this.dbHelper})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(outfit.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {},
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

    Navigator.popUntil(context, ModalRoute.withName('/homeScreen'));
  }
}
