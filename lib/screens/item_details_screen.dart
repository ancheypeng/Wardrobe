import 'package:flutter/material.dart';
import 'package:wardrobe/database/db_helper.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/widgets/item_card.dart';

import 'full_image_screen.dart';
import 'item_form_screen.dart';

class ItemDetailsScreen extends StatelessWidget {
  final DbHelper dbHelper;
  final Item item;
  const ItemDetailsScreen({Key key, this.item, this.dbHelper})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
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
                  item.name,
                  style: TextStyle(fontSize: 22.0),
                ),
                Text(
                  "Color: " + item.color,
                  style: TextStyle(fontSize: 22.0),
                ),
                Text(
                  "Category: " + item.category,
                  style: TextStyle(fontSize: 22.0),
                ),
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
        height: 250,
        child: Hero(
          tag: item.id,
          child: ItemCard(
            itemImage: item.imageWidget,
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullImageScreen(
              item: item,
            ),
          ),
        );
      },
    );
  }

  void edit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(
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
    await dbHelper.deleteItem(item.id);

    //Navigator.popUntil(context, ModalRoute.withName('/homeScreen'));
    Navigator.pop(context); //pop to close dialog
    Navigator.of(context).pop('refresh'); //pop to previous screen
  }
}
