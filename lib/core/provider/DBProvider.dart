import 'package:floor/floor.dart';
import 'package:lipa_quick/core/local_db/database/database.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqdatabase;

class DBProvider {
  // Create a singleton
  DBProvider._();

  static final DBProvider db = DBProvider._();
  AppDatabase? _database;

  Future<AppDatabase> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDB();
    print('DB Init Successful for Floor');
    return _database!;
  }

  Future<AppDatabase> initDB() async {
    // Get the location of our apps directory. This is where files for our app, and only our app, are stored.
    // Files in this directory are deleted when the app is deleted.
    final migration1to2 = Migration(1, 2, imgrate1to2);
    final migration2to3 = Migration(2, 3, imgrate1to2);
    return await $FloorAppDatabase.databaseBuilder('app_database.db')
        //.addMigrations([migration1to2, migration2to3])
        .build();
  }

  Future<void> imgrate1to2(sqdatabase.Database database) async {
    {
      //database.execute('Drop Table ContactsAPI');
      //database.execute('Drop Table UserPaymentMethods');
    }
  }
}
