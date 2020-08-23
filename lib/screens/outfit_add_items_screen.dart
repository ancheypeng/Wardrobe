import 'package:flutter/material.dart';
import 'package:wardrobe/database/db_helper.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/screens/items_screen.dart';

import 'outfit_form_screen.dart';

class OutfitAddItemsScreen extends StatefulWidget {
  final DbHelper dbHelper;
  final List<Item> items;
  OutfitAddItemsScreen({Key key, this.items, this.dbHelper}) : super(key: key);

  @override
  _OutfitAddItemsScreenState createState() => _OutfitAddItemsScreenState();
}

class _OutfitAddItemsScreenState extends State<OutfitAddItemsScreen> {
  DbHelper _dbHelper;

  List<Item> _items;
  List<Item> _selectedItems;

  @override
  initState() {
    super.initState();
    _dbHelper = widget.dbHelper;

    _items = widget.items ??
        [Item(id: 1, name: 'TEST ITEM', color: 'White', category: 'Tops')];
    _selectedItems = [];
  }

  void _onItemCardTap(Item item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Items'),
      ),
      backgroundColor: Colors.grey[200],
      body: ItemScreen(
        items: _items,
        onItemCardTap: _onItemCardTap,
        selectedItems: _selectedItems,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          color: Colors.white,
        ),
        height: 60,
        child: Row(
          children: <Widget>[
            SizedBox(width: 5),
            Flexible(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItemTile(_selectedItems[index]);
                },
              ),
            ),
            SizedBox(width: 5),
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OutfitFormScreen(
                      dbHelper: _dbHelper,
                      selectedItems: _selectedItems,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildItemTile(Item item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedItems.remove(item);
        });
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: item.imageWidget,
          ),
        ),
      ),
    );
  }
}
