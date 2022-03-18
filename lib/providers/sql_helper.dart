import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SQLHelper {
  static Future createTables() async {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase('psws.db');
    await db.execute("""CREATE TABLE IF NOT EXISTS Psws(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        username TEXT,
        password TEXT,
        userAvatar TEXT,
        pinned BOOL,
        createdOn TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);

    var result = await db.query('Psws');
    print(result);
    // prints [{id: 1, title: Product 1}, {id: 2, title: Product 1}]
    await db.close();
  }

  static Future createItem(String title, String? username, String? password,
      String? userAvatar) async {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase('psws.db');
    final data = {
      'title': title,
      'username': username,
      'password': password,
      'userAvatar': userAvatar,
      'pinned': false
    };

    final id = await db.insert('Psws', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    var result = await db.query('Psws');
    print(result);
    // prints [{id: 1, title: Product 1}, {id: 2, title: Product 1}]
    await db.close();
  }

  static Future updateItem(int id, String title, String? username,
      String? password, String? userAvatar) async {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase('psws.db');
    final data = {
      'title': title,
      'username': username,
      'password': password,
      'userAvatar': userAvatar,
      'createdAt': DateTime.now().toString()
    };

    await db.update('Psws', data, where: "id = ?", whereArgs: [id]);
    var result = await db.query('Psws');
    print(result);
    // prints [{id: 1, title: Product 1}, {id: 2, title: Product 1}]
    await db.close();
  }

  static Future deleteItem(int id) async {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase('psws.db');
    try {
      await db.delete("Psws", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
    var result = await db.query('Psws');
    print(result);
    // prints [{id: 1, title: Product 1}, {id: 2, title: Product 1}]
    await db.close();
  }

  // Read all items (psws)
  static Future<List<Map<String, dynamic>>> getItems() async {
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase('psws.db');
    return db.query('Psws', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase('psws.db');
    return db.query('Psws', where: "id = ?", whereArgs: [id], limit: 1);
  }
}
