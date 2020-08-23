import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wardrobe/models/item_model.dart';
import 'package:wardrobe/models/outfit_model.dart';

class DbHelper {
  static Database _database;

  Future<Database> get _getDatabase async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _initDb();
      return _database;
    }
  }

  Future<Database> _initDb() async {
    final Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'item_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE items(id INTEGER PRIMARY KEY, image TEXT, name TEXT, color TEXT, category TEXT, dateAdded INTEGER)",
        );
        await db.execute(
            "CREATE TABLE outfits(id INTEGER PRIMARY KEY, name TEXT, category TEXT, dateAdded INTEGER)");
        await db.execute('''
          CREATE TABLE outfitItems(
            itemId INTEGER REFERENCES items(id),
            outfitId INTEGER REFERENCES outfits(id),
            PRIMARY KEY (itemId, outfitId)
          )
        ''');
        return db;
      },
      version: 1,
    );
    return database;
  }

  Future<void> close() async {
    final Database db = await _getDatabase;
    db.close();
  }

  Future<void> saveItem(Item item) async {
    final Database db = await _getDatabase;
    await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future getItems() async {
    final Database db = await _getDatabase;

    final List<Map<String, dynamic>> maps = await db.query('items');

    final items = List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });

    return items;
  }

  Future<void> saveOutfit(Outfit outfit) async {
    final Database db = await _getDatabase;
    await db.insert(
      'outfits',
      outfit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (int itemId in outfit.itemsInOutfit){
      await db.rawInsert('INSERT INTO outfitItems VALUES ($itemId, ${outfit.id})');
    }
  }

  Future getOutfits() async {
    final Database db = await _getDatabase;

    final List<Map<String, dynamic>> maps = await db.query('outfits');
    final outfits = List.generate(maps.length, (i) {
      return Outfit.fromMap(maps[i]);
    });

    for (Outfit outfit in outfits){
      final itemsInOutfit = await db.rawQuery("SELECT items.id FROM outfitItems JOIN items on outfitItems.itemId = items.id WHERE outfitItems.outfitId = ${outfit.id}");
      outfit.itemsInOutfit = itemsInOutfit.map((itemInOutfit) => itemInOutfit['id'] as int).toList();
      //print(outfit);
    }

    //"SELECT items.* FROM outfitItems as oi JOIN items WHERE oi.outfitId = ${outfit.id}"

    // SELECT ITEMS.* FROM outfitItems 
    //  JOIN ITEMS ON outfitItems.itemId = ITEMS.id 
    //  WHERE outfitItems.outfitId = 154

    return outfits;
    
  }
}