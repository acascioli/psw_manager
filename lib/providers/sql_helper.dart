import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:psw_manager/models/psw.dart';

class SQLHelper {
  static Future createTables() async {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    var appDocDir = await getApplicationDocumentsDirectory();
    var dbPath = appDocDir.absolute.path + '\\Dbs' + '\\psws.db';

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase(dbPath);
    await db.execute("""CREATE TABLE IF NOT EXISTS Psws(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        username TEXT,
        password TEXT,
        pswIcon TEXT,
        pswColor TEXT,
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
      String? pswIcon, String? pswColor) async {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    var appDocDir = await getApplicationDocumentsDirectory();
    var dbPath = appDocDir.absolute.path + '\\Dbs' + '\\psws.db';

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase(dbPath);
    final data = {
      'title': title,
      'username': username,
      'password': password,
      'pswIcon': pswIcon,
      'pswColor': pswColor,
      'pinned': 'FALSE'
    };

    final id = await db.insert('Psws', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    var result = await db.query('Psws');
    print(result);
    // prints [{id: 1, title: Product 1}, {id: 2, title: Product 1}]
    await db.close();
  }

  static Future updateItem(int id, String title, String? username,
      String? password, String? pswIcon, String? pswColor) async {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    var appDocDir = await getApplicationDocumentsDirectory();
    var dbPath = appDocDir.absolute.path + '\\Dbs' + '\\psws.db';

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase(dbPath);
    final data = {
      'title': title,
      'username': username,
      'password': password,
      'pswIcon': pswIcon,
      'pswColor': pswColor,
      'createdOn': DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())
    };

    await db.update('Psws', data, where: "id = ?", whereArgs: [id]);
    var result = await db.query('Psws');
    print(result);
    // prints [{id: 1, title: Product 1}, {id: 2, title: Product 1}]
    await db.close();
  }

  static Future togglePinned(Psw psw) async {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    var appDocDir = await getApplicationDocumentsDirectory();
    var dbPath = appDocDir.absolute.path + '\\Dbs' + '\\psws.db';

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase(dbPath);

    final data = {
      'title': psw.title,
      'username': psw.username,
      'password': psw.password,
      'pswIcon': psw.pswIcon,
      'pswColor': psw.pswColor,
      'pinned': psw.pinned ? 'FALSE' : 'TRUE',
      'createdOn': psw.createdOn
    };

    await db.update('Psws', data, where: "title = ?", whereArgs: [psw.title]);
    var result = await db.query('Psws');
    print(result);
    // prints [{id: 1, title: Product 1}, {id: 2, title: Product 1}]
    await db.close();
  }

  static Future deleteItem(String title) async {
    // static Future deleteItem(int id) async {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    var appDocDir = await getApplicationDocumentsDirectory();
    var dbPath = appDocDir.absolute.path + '\\Dbs' + '\\psws.db';

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase(dbPath);
    try {
      await db.delete("Psws", where: "title = ?", whereArgs: [title]);
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

    var appDocDir = await getApplicationDocumentsDirectory();
    var dbPath = appDocDir.absolute.path + '\\Dbs' + '\\psws.db';

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase(dbPath);
    return db.query('Psws', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    sqfliteFfiInit();

    var appDocDir = await getApplicationDocumentsDirectory();
    var dbPath = appDocDir.absolute.path + '\\Dbs' + '\\psws.db';

    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase(dbPath);
    return db.query('Psws', where: "id = ?", whereArgs: [id], limit: 1);
  }
}
