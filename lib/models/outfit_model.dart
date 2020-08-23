import 'item_model.dart';

class Outfit {
  int id;
  String name;
  String category;
  List<int> itemsInOutfit;
  int dateAdded;

  Outfit({
    this.id,
    this.name,
    this.category,
    this.itemsInOutfit,
    this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'dateAdded': dateAdded,
    };
  }

  Outfit.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    category = map['category'];
    dateAdded = map['dateAdded'];
  }

  bool contains(String str) {
    if (this.name.toLowerCase().contains(str.toLowerCase()) ||
        this.category.toLowerCase().contains(str.toLowerCase())) {
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return (id.toString() + " " + name + " " + category + " " + itemsInOutfit.toString());
  }
}
