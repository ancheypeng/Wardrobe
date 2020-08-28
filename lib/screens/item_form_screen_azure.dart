import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wardrobe/database/db_helper.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/screens/full_image_screen.dart';
import 'package:wardrobe/widgets/item_card.dart';

class ItemFormScreen extends StatefulWidget {
  final DbHelper dbHelper;
  final File imageFile;
  final List recognitions;

  ItemFormScreen({
    Key key,
    @required this.dbHelper,
    @required this.imageFile,
    this.recognitions,
  }) : super(key: key);

  @override
  _ItemFormScreenState createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  DbHelper _dbHelper;
  File _imageFile;
  List _recognitions;

  final _formKey = GlobalKey<FormState>();
  String _itemName;
  String _itemColor;
  String _itemCategory = 'Tops';

  var _nameController = TextEditingController();
  var _colorController = TextEditingController();

  bool _noRecognitions = false;

  @override
  initState() {
    super.initState();
    _dbHelper = widget.dbHelper;
    _imageFile = widget.imageFile;
    _recognitions = widget.recognitions;
  }

  void _confirm(BuildContext context) async {
    final rng = new Random();
    final num = rng.nextInt(10000000);
    final String encodedImage = base64Encode(_imageFile.readAsBytesSync());
    final item = Item(
      id: num,
      image: encodedImage,
      name: _itemName,
      color: _itemColor,
      category: _itemCategory,
      dateAdded: new DateTime.now().millisecondsSinceEpoch,
    );
    await _dbHelper.saveItem(item);

    Navigator.popUntil(context, ModalRoute.withName('/homeScreen'));
  }

  void _predict() {
    List<String> tops = ['T-Shirt', 'Shirt', 'Hoodie'];
    List<String> bottoms = ['Jeans'];
    List<String> accessories = ['Sneakers'];
    List<String> clothes =
        [tops, bottoms, accessories].expand((x) => x).toList();

    List<String> colors = ['Black', 'Blue', 'Navy', 'White', 'Grey', 'Maroon'];

    var firstNameRecognition = _recognitions
        .firstWhere((recognition) => clothes.contains(recognition['tagName']));
    var firstColorRecognition = _recognitions
        .firstWhere((recognition) => colors.contains(recognition['tagName']));

    bool nameRecognized = firstNameRecognition['probability'] > 0.7;
    bool colorRecognized = firstColorRecognition['probability'] > 0.5;

    if (nameRecognized) {
      String newName = firstNameRecognition['tagName'];
      //set item name
      _nameController.value = TextEditingValue(
        text: newName,
        selection: TextSelection.fromPosition(
          TextPosition(offset: newName.length),
        ),
      );
      //set item category
      if (tops.contains(newName)) {
        setState(() {
          _itemCategory = 'Tops';
        });
      } else if (bottoms.contains(newName)) {
        setState(() {
          _itemCategory = 'Bottoms';
        });
      } else if (accessories.contains(newName)) {
        setState(() {
          _itemCategory = 'Accessories';
        });
      }
    }
    if (colorRecognized) {
      String newColor = firstColorRecognition['tagName'];
      _colorController.value = TextEditingValue(
        text: newColor,
        selection: TextSelection.fromPosition(
          TextPosition(offset: newColor.length),
        ),
      );
    }
    if (!nameRecognized && !colorRecognized) {
      setState(() {
        _noRecognitions = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Info'),
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
                _buildItemForm(),
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
        height: 150,
        child: Hero(
          tag: 'imageHero',
          child: ItemCard(
            itemImage: Image.file(
              _imageFile,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullImageScreen(
              itemImage: Image.file(
                _imageFile,
              ),
            ),
          ),
        );
      },
    );
  }

  Form _buildItemForm() {
    final colorFocus = FocusNode();

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _buildPredictionField(),
          AnimatedOpacity(
            opacity: _noRecognitions ? 1.0 : 0.0,
            duration: Duration(milliseconds: 150),
            child: _noRecognitions
                ? Text(
                    'No predictions could be made.',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.red,
                    ),
                  )
                : SizedBox.shrink(),
          ),
          _buildNameField(colorFocus),
          SizedBox(height: 20.0),
          _buildColorField(colorFocus),
          SizedBox(height: 20.0),
          _buildDropdown(),
          SizedBox(height: 30.0),
          _buildButtonRow(),
        ],
      ),
    );
  }

  Widget _buildPredictionField() {
    if (_recognitions != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'AI Predictions',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                splashRadius: 28.0,
                onPressed: _predict,
              ),
            ),
          ],
        ),
      );
    } else
      return SizedBox.shrink();
  }

  TextFormField _buildNameField(FocusNode colorFocus) {
    return TextFormField(
      controller: _nameController,
      autofocus: false,
      textInputAction: TextInputAction.next,
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
      onSaved: (val) => setState(() => _itemName = val),
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(colorFocus);
      },
    );
  }

  TextFormField _buildColorField(FocusNode colorFocus) {
    return TextFormField(
      controller: _colorController,
      autofocus: false,
      focusNode: colorFocus,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Color',
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a color for this item.';
        }
        return null;
      },
      onSaved: (val) => setState(() => _itemColor = val),
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
        DropdownButton<String>(
          value: _itemCategory,
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
            FocusScope.of(context).requestFocus(FocusNode());
            setState(() {
              _itemCategory = newValue;
            });
          },
          items: <String>['Tops', 'Bottoms', 'Accessories', 'Other']
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
