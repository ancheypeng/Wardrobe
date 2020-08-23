import 'package:flutter/material.dart';
import 'package:wardrobe/models/item_model.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final Image itemImage;

  final bool selected;

  const ItemCard({
    Key key,
    this.item,
    @required this.itemImage,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.all(6.0),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 8.0 / 10.0,
        child: selected ? _buildSelected() : _buildUnselected(),
      ),
    );
  }

  Image _buildUnselected() {
    return itemImage;
  }

  Stack _buildSelected() {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: <Widget>[
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.blue[300],
            BlendMode.color,
          ),
          child: itemImage,
        ),
        Icon(
          Icons.check,
          color: Colors.white,
          size: 30.0,
        ),
      ],
    );
  }
}
