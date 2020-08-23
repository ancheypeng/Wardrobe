import 'package:flutter/material.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/models/outfit_model.dart';

class OutfitCard extends StatelessWidget {
  final List<Item> itemsInOutfit;
  final Outfit outfit;

  const OutfitCard({Key key, this.itemsInOutfit, this.outfit})
      : super(key: key);

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
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceAround, //remove maybe
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: Colors.grey[100],
                margin: EdgeInsets.all(4.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  padding: EdgeInsets.all(4.0),
                  itemCount:
                      itemsInOutfit.length <= 4 ? itemsInOutfit.length : 4,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: itemsInOutfit[index]
                            .imageWidget, //not sure about BoxFit.cover - maybe remove later
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(6, 4, 6, 0),
                child: Text(
                  outfit != null ? outfit.name : "",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
