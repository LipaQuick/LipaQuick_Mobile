
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/models/quick_action_model.dart';
import 'package:lipa_quick/core/view_models/base_viewmodel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper extends BaseModel{
  static const _databaseName = "LipaQuick.db";
  static const _databaseVersion = 1;

  static const table = 'quickAction';

  static const columnID = 'Id';
  static const columnImagePath = 'iconPath';
  static const columnQuickActionName = 'quickActionTitle';
  static const columnEnabled = 'isEnabled';

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);

  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnID TEXT NOT NULL PRIMARY KEY,
            $columnQuickActionName TEXT NOT NULL,
            $columnImagePath TEXT NOT NULL,
            $columnEnabled BIT(1) NOT NULL
          )
          ''');
    print("db was created");
  }

  Future<void> inseryItems(List<QuickActionModel> data) async {

    final Database db = await database;
    print("inserting");
    for (QuickActionModel i in data){
      final List<Map<String, dynamic>> res = await db.query(table, where: '${DBHelper.columnQuickActionName} = ?'
          , whereArgs: [i.quickActionTitle]);
      if (!res.isNotEmpty) {
        print("Not inserted, inserting");
        Map<String, dynamic> row = i.toJson();
        await db.insert(table, row);
      } else {
        print("Data inserted, exiting");
        break;
      }
    }

  }

  //Delete a street from the DB
  Future<void> deletePos(String street) async {
    Database db = await DBHelper.instance.database;
    await db.delete(table, where: 'street = ?', whereArgs: [street]);
  }

  //Update the notification boolean
  Future<int> updateQuickAction(String id, bool value) async {
    // Get a reference to the database.
    Database db = await DBHelper.instance.database;

    Map<String, dynamic> row = {
      DBHelper.columnEnabled  : value?1:0,
    };
    int data = await db.update(table, row, where: '${DBHelper.columnID} = ?', whereArgs: [id]);
    return data;
  }

  //Return a String list of all street's name in the DB
  Future<List<QuickActionModel>> getQuickActions() async {
    setState(ViewState.Loading);
    // Get a reference to the database.
    Database db = await DBHelper.instance.database;

    List<Map<String, dynamic>> res = await db.query(table);
    List<QuickActionModel> list = [];
    print("Loading Data from Local DB ${res.length}");
    for (Map<String, dynamic> i in res){
      list.add(QuickActionModel.fromJson(i));
    }
    setState(ViewState.Idle);
    return list;
  }

  //Return a String list of all street's name in the DB
  Future<List<QuickActionModel>> getEnabledQuickActions() async {
    // Get a reference to the database.
    Database db = await DBHelper.instance.database;

    List<Map<String, dynamic>> res = await db.query(table, where: '${DBHelper.columnEnabled} = 1');
    //print("Fetch Data, ${res.length}");
    List<QuickActionModel> list = [];
    for (Map<String, dynamic> i in res){
      //print("Data, ${i.toString()}");
      list.add(QuickActionModel.fromJson(i));
    }
    return list;
  }

}