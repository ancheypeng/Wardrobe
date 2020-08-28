import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wardrobe/database/db_helper.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/models/outfit_model.dart';
import 'package:wardrobe/widgets/outfit_card.dart';

class OutfitFormScreen extends StatefulWidget {
  final DbHelper dbHelper;
  final List<Item> selectedItems;

  final Outfit outfit;
  final List<Item> itemsInOutfit;

  OutfitFormScreen(
      {Key key,
      this.dbHelper,
      this.selectedItems,
      this.outfit,
      this.itemsInOutfit})
      : super(key: key);

  @override
  _OutfitFormScreenState createState() => _OutfitFormScreenState();
}

class _OutfitFormScreenState extends State<OutfitFormScreen> {
  DbHelper _dbHelper;

  List<Item> _selectedItems;

  final _formKey = GlobalKey<FormState>();
  String _outfitName;
  String _outfitCategory = 'Casual';
  List<String> seasons = ['Summer', 'Fall', 'Spring', 'Winter'];
  List<bool> seasonsSelected = [false, false, false, false];

  Outfit _outfit;
  bool _editMode;

  @override
  void initState() {
    super.initState();
    _dbHelper = widget.dbHelper;
    _selectedItems = widget.selectedItems;

    _outfit = widget.outfit;
    _editMode = _outfit != null ? true : false;
    if (_editMode) {
      _selectedItems = widget.itemsInOutfit;
      _outfitCategory = _outfit.category;
      _outfitName = _outfit.name;
      seasonsSelected = _outfit.seasons;
    }
  }

  void _confirm(BuildContext context) async {
    final rng = new Random();
    final id = _editMode ? _outfit.id : rng.nextInt(10000000);
    final outfit = Outfit(
      id: id,
      name: _outfitName,
      category: _outfitCategory,
      itemsInOutfit: _selectedItems.map((item) => item.id).toList(),
      dateAdded: new DateTime.now().millisecondsSinceEpoch,
      seasons: seasonsSelected,
    );
    await _dbHelper.saveOutfit(outfit);

    if (_editMode) {
      Navigator.of(context).pop('refresh');
    } else {
      Navigator.popUntil(context, ModalRoute.withName('/homeScreen'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Outfit Info'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 60.0),
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: 40.0),
                _buildOutfitPreview(context),
                SizedBox(height: 20.0),
                _buildOutfitForm(),
                SizedBox(height: 50.0),
              ],
            )
          ],
        ),
      ),
    );
  }

  Container _buildOutfitPreview(BuildContext context) {
    return Container(
      height: 200,
      child: OutfitCard(itemsInOutfit: _selectedItems),
    );
  }

  Form _buildOutfitForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: _editMode ? _outfit.name : null,
            autofocus: false,
            //textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a name for this item.';
              }
              return null;
            },
            onSaved: (val) => setState(() => _outfitName = val),
          ),
          SizedBox(height: 20.0),
          _buildDropdown(),
          SizedBox(height: 20.0),
          _buildCheckboxes(),
          SizedBox(height: 20.0),
          _buildButtonRow(),
        ],
      ),
    );
  }

  Row _buildDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(width: 20),
        DropdownButton<String>(
          value: _outfitCategory,
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
          underline: Container(
            height: 1,
            color: Colors.grey,
          ),
          onChanged: (String newValue) {
            setState(() {
              _outfitCategory = newValue;
            });
          },
          items: <String>['Athletic', 'Casual', 'Formal', 'Other']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  // _buildCheckboxes() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Expanded(
  //         child: Column(
  //           children: [
  //             buildFilterChip('Summer'),
  //             buildFilterChip('Fall'),
  //           ],
  //         ),
  //       ),
  //       Expanded(
  //         child: Column(
  //           children: [
  //             buildFilterChip('Spring'),
  //             buildFilterChip('Winter'),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  _buildCheckboxes() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 220,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 15.0, // gap between adjacent chips
        runSpacing: 4.0, // gap between lines
        children: [
          buildFilterChip('Summer'),
          buildFilterChip('Spring'),
          buildFilterChip('Fall'),
          buildFilterChip('Winter'),
        ],
      ),
    );
  }

  // CheckboxListTile buildCheckboxListTile(String season) {
  //   return CheckboxListTile(
  //     title: Text(
  //       season,
  //       style: TextStyle(
  //         fontSize: 16.0,
  //         color: Colors.grey[600],
  //       ),
  //     ),
  //     controlAffinity: ListTileControlAffinity.leading,
  //     contentPadding: EdgeInsets.all(0),
  //     dense: true,
  //     value: seasonsSelected[seasons.indexOf(season)],
  //     onChanged: (bool value) => setState(() {
  //       seasonsSelected[seasons.indexOf(season)] = value;
  //     }),
  //   );
  // }

  Widget buildFilterChip(String season) {
    return Theme(
      data: ThemeData.dark(),
      child: FilterChip(
        label: Text(
          season,
          style: TextStyle(
            fontSize: 16.0,
            color: seasonsSelected[seasons.indexOf(season)]
                ? Colors.white
                : Colors.grey[600],
          ),
        ),
        backgroundColor: Colors.grey[300],
        selectedColor: Colors.blue,
        selected: seasonsSelected[seasons.indexOf(season)],
        onSelected: (bool value) => setState(() {
          seasonsSelected[seasons.indexOf(season)] = value;
        }),
      ),
    );
  }

  Row _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              _confirm(context);
            }
          },
          child: Text('Save'),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
