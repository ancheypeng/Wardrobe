class Outfit {
  int id;
  String name;
  String category;
  List<int> itemsInOutfit;
  int dateAdded;
  List<bool> seasons;
  List<String> seasonNames = [];

  Outfit({
    this.id,
    this.name,
    this.category,
    this.itemsInOutfit,
    this.dateAdded,
    this.seasons,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'dateAdded': dateAdded,
      'summer': boolToInt(seasons[0]),
      'spring': boolToInt(seasons[1]),
      'fall': boolToInt(seasons[2]),
      'winter': boolToInt(seasons[3]),
    };
  }

  Outfit.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    category = map['category'];
    dateAdded = map['dateAdded'];
    seasons = [
      intToBool(map['summer']),
      intToBool(map['spring']),
      intToBool(map['fall']),
      intToBool(map['winter']),
    ];
    if (seasons[0]) {
      seasonNames.add('Summer');
    }
    if (seasons[1]) {
      seasonNames.add('Spring');
    }
    if (seasons[2]) {
      seasonNames.add('Fall');
    }
    if (seasons[3]) {
      seasonNames.add('Winter');
    }
  }

  int boolToInt(bool b) {
    return b ? 1 : 0;
  }

  bool intToBool(int x) {
    return x == 1 ? true : false;
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
    return (id.toString() +
        " " +
        name +
        " " +
        category +
        " " +
        itemsInOutfit.toString());
  }
}
