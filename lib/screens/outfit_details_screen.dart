import 'package:flutter/material.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/models/outfit_model.dart';
import 'package:wardrobe/widgets/outfit_card.dart';

class OutfitDetailsScreen extends StatelessWidget {
  final List<Item> itemsInOutfit;
  final Outfit outfit;

  const OutfitDetailsScreen({Key key, this.outfit, this.itemsInOutfit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(outfit.name),
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
}
