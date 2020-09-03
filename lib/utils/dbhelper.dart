import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';


class Databasehelper {
  // database name
  static final _databasename = "mjklfrgee.db";
  static final _databaseversion = 1;

  // the table name
  static final Master = "master";
  static final GroceryList = "grocerylist";
  static final GroceryItem = "groceryitem";

  // column names of master table
  static final MasterId = 'masterid';
  static final Item = "item";

  // column names of Grocery List  table
  static final GroceryId = "groceryid";
  static final ListName = "listname";

  // column names of Grocery Item table
  static final GroceryItemId = "groceryitemid";
  static final ItemName = "itemname";
  static final ItemId = "itemid";

  // a database
  static Database _database;

  // privateconstructor
  Databasehelper._privateConstructor();
  static final Databasehelper instance = Databasehelper._privateConstructor();

  // asking for a database
  Future<Database> get databse async {
    if (_database != null) return _database;

    // create a database if one doesn't exist
    _database = await _initDatabase();
    return _database;
  }

  // function to return a database
  _initDatabase() async {
    Directory documentdirecoty = await getApplicationDocumentsDirectory();
    String path = join(documentdirecoty.path, _databasename);
    return await openDatabase(path,
        version: _databaseversion, onCreate: _onCreate);
  }

  // create a database since it doesn't exist
  Future _onCreate(Database db, int version) async {
    // sql code
    await db.execute('''
      CREATE TABLE $Master (
        $MasterId INTEGER PRIMARY KEY,
        $Item TEXT NOT NULL
      );
      ''');

    await db.execute('''
      CREATE TABLE $GroceryList (
        $GroceryId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        $ListName TEXT NOT NULL
      );
      ''');

    await db.execute('''
      CREATE TABLE $GroceryItem (
        $GroceryItemId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        $ItemName TEXT NOT NULL,
        $ItemId INTEGER,
        FOREIGN KEY($ItemId) REFERENCES $GroceryList($GroceryId)
      );
      ''');
  }

  // functions to insert data
  Future<int> insert(String tablename, Map<String, dynamic> row) async {
    Database db = await instance.databse;
    return await db.insert(tablename, row);
  }

  // function to query all the rows
  Future<List<Map<String, dynamic>>> queryall(String tablename) async {
    Database db = await instance.databse;
    return await db.query(tablename);
  }

  Future<List<Map<String, dynamic>>> queryspecific(String id) async {
    Database db = await instance.databse;
    return await db.rawQuery('SELECT * FROM  groceryitem WHERE itemid = $id');
  }

  // function to delete some data
  Future<int> deleteList(int id) async {
    Database db = await instance.databse;
    var res =
        await db.delete(GroceryList, where: "groceryid = ?", whereArgs: [id]);
    return res;
  }

  Future<int> deleteItem(int id) async {
    Database db = await instance.databse;
    var res = await db.delete(GroceryItem, where: "groceryitemid = ?", whereArgs: [id]);
    return res;
  }

//  Future<List<Map<String, dynamic>>> queryspecific() async {
//    Database db = await instance.databse;
//    var res = await db.rawQuery('SELECT groceryitem.groceryItemId , groceryitem.itemname, groceryitem.itemid '
//        'FROM master, groceryItem '
//        'WHERE master.masterid = groceryitem.itemid');
//    return res;
//  }
}
