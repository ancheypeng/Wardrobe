import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wardrobe/database/db_helper.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/models/outfit_model.dart';
import 'package:wardrobe/screens/image_capture_screen.dart';
import 'package:wardrobe/screens/insights_screen.dart';
import 'package:wardrobe/screens/items_screen.dart';
import 'package:wardrobe/screens/outfit_screen.dart';
import 'package:wardrobe/widgets/bottom_bar.dart';
import 'package:wardrobe/screens/outfit_add_items_screen.dart';
import 'package:wardrobe/screens/item_details_screen.dart';

import 'outfit_details_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Widget> _screens;
  void _onBottomBarTap(int index) {
    setState(() => _selectedIndex = index);
  }

  final DbHelper _dbHelper = DbHelper();
  List<Item> _items = [];

  List<Outfit> _outfits = [];

  @override
  void initState() {
    super.initState();
    _screens = <Widget>[
      ItemScreen(
        items: _items,
        onItemCardTap: _showItemDetails,
      ),
      OutfitScreen(
        items: _items,
        outfits: _outfits,
        onOutfitCardTap: _showOutfitDetails,
      ),
      InsightsScreen(
        items: _items,
        outfits: _outfits,
      ),
    ];
    _refreshItems();
  }

  @override
  void dispose() {
    _dbHelper.close();
    super.dispose();
  }

  void _refreshItems() {
    _dbHelper.getItems().then((items) {
      _dbHelper.getOutfits().then((outfits) {
        setState(() {
          _outfits.clear();
          _outfits.addAll(outfits);

          _items.clear();
          _items.addAll(items);

          _updateItemImages();

          //sort in order of newest to oldest
          _outfits.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
          _items.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

          _screens = <Widget>[
            ItemScreen(
              items: _items,
              onItemCardTap: _showItemDetails,
            ),
            OutfitScreen(
              items: _items,
              outfits: _outfits,
              onOutfitCardTap: _showOutfitDetails,
            ),
            InsightsScreen(
              items: _items,
              outfits: _outfits,
            ),
          ];
        });
      });
      //setState(() {
      // _items.clear();
      // _items.addAll(items);

      // _updateItemImages();

      // _screens = <Widget>[
      //   ItemScreen(
      //     items: _items,
      //     onItemCardTap: _showItemDetails,
      //   ),
      //   OutfitScreen(
      //     items: _items,
      //     outfits: _outfits,
      //     onOutfitCardTap: _showOutfitDetails,
      //   ),
      // ];
      //});
    });
  }

  void _updateItemImages() {
    for (Item item in _items) {
      item.imageWidget = Image.memory(
        base64Decode(item.image),
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }
  }

  void _showItemDetails(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailsScreen(
          dbHelper: _dbHelper,
          item: item,
        ),
      ),
    ).then((val) {
      if (val == 'refresh') {
        _refreshItems();
      }
    });
  }

  void _showOutfitDetails(Outfit outfit, List<Item> itemsInOutfit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OutfitDetailsScreen(
          dbHelper: _dbHelper,
          outfit: outfit,
          itemsInOutfit: itemsInOutfit.toList(),
        ),
      ),
    ).then((val) {
      if (val == 'refresh') {
        _refreshItems();
      }
    });
  }

  void _onFABPress() {
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageCaptureScreen(
            dbHelper: _dbHelper,
          ),
        ),
      ).then((_) {
        _refreshItems();
      });
    } else if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OutfitAddItemsScreen(
            dbHelper: _dbHelper,
            items: _items,
          ),
        ),
      ).then((_) {
        _refreshItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onBottomBarTap: _onBottomBarTap,
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    if (_selectedIndex == 0 || _selectedIndex == 1) {
      return FloatingActionButton(
        onPressed: _onFABPress,
        child: Icon(Icons.add),
      );
    } else {
      return null;
    }
  }
}
