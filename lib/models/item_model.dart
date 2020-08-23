import 'package:flutter/material.dart';

class Item {
  int id;
  String image;
  String name;
  String color;
  String category;
  int dateAdded;

  Image imageWidget;

  Item({
    this.id,
    this.image,
    this.name,
    this.color,
    this.category,
    this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'color': color,
      'category': category,
      'dateAdded': dateAdded,
    };
  }

  Item.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    image = map['image'];
    name = map['name'];
    color = map['color'];
    category = map['category'];
    dateAdded = map['dateAdded'];
  }

  bool contains(String str) {
    if (this.name.toLowerCase().contains(str.toLowerCase()) ||
        this.color.toLowerCase().contains(str.toLowerCase()) ||
        this.category.toLowerCase().contains(str.toLowerCase())) {
      return true;
    }
    return false;
  }

}
