// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ContactsDao? _contactsDaoInstance;

  UserPaymentDao? _userPaymentDaoInstance;

  AppSettingsDao? _appSettingsDaoInstance;

  AppPinsDao? _appLockDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ContactsAPI` (`id` TEXT, `name` TEXT, `phoneNumber` TEXT, `role` TEXT, `bank` TEXT, `accountHolderName` TEXT, `swiftCode` TEXT, `accountNumber` TEXT, PRIMARY KEY (`phoneNumber`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UserPaymentMethods` (`id` TEXT, `methodId` TEXT, `methodName` TEXT, `cardNumber` TEXT, `validTill` TEXT, `nameOnCard` TEXT, `bank` TEXT, `swiftCode` TEXT, `accountNumber` TEXT, `accountHolderName` TEXT, `phoneNumber` TEXT, `isDefault` INTEGER, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AppSettings` (`userId` TEXT NOT NULL, `id` TEXT NOT NULL, `settingsTitle` TEXT NOT NULL, `settingsValue` INTEGER NOT NULL, `twoFactorPin` TEXT NOT NULL, PRIMARY KEY (`userId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AppLockPin` (`id` TEXT NOT NULL, `username` TEXT NOT NULL, `pinHash` TEXT NOT NULL, `isAppLockEnabled` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ContactsDao get contactsDao {
    return _contactsDaoInstance ??= _$ContactsDao(database, changeListener);
  }

  @override
  UserPaymentDao get userPaymentDao {
    return _userPaymentDaoInstance ??=
        _$UserPaymentDao(database, changeListener);
  }

  @override
  AppSettingsDao get appSettingsDao {
    return _appSettingsDaoInstance ??=
        _$AppSettingsDao(database, changeListener);
  }

  @override
  AppPinsDao get appLockDao {
    return _appLockDaoInstance ??= _$AppPinsDao(database, changeListener);
  }
}

class _$ContactsDao extends ContactsDao {
  _$ContactsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _contactsAPIInsertionAdapter = InsertionAdapter(
            database,
            'ContactsAPI',
            (ContactsAPI item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'phoneNumber': item.phoneNumber,
                  'role': item.role,
                  'bank': item.bank,
                  'accountHolderName': item.accountHolderName,
                  'swiftCode': item.swiftCode,
                  'accountNumber': item.accountNumber
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ContactsAPI> _contactsAPIInsertionAdapter;

  @override
  Future<List<ContactsAPI>> getAllContacts() async {
    return _queryAdapter.queryList('Select * from ContactsAPI',
        mapper: (Map<String, Object?> row) => ContactsAPI(
            row['id'] as String?,
            row['name'] as String?,
            row['phoneNumber'] as String?,
            row['bank'] as String?,
            row['accountHolderName'] as String?,
            row['swiftCode'] as String?,
            row['accountNumber'] as String?));
  }

  @override
  Future<List<ContactsAPI>> getContactsByQuery(String query) async {
    return _queryAdapter.queryList(
        'SELECT * from ContactsAPI WHERE name LIKE ?1 OR phoneNumber LIKE ?1',
        mapper: (Map<String, Object?> row) => ContactsAPI(
            row['id'] as String?,
            row['name'] as String?,
            row['phoneNumber'] as String?,
            row['bank'] as String?,
            row['accountHolderName'] as String?,
            row['swiftCode'] as String?,
            row['accountNumber'] as String?),
        arguments: [query]);
  }

  @override
  Future<void> deleteContacts() async {
    await _queryAdapter.queryNoReturn('Delete from ContactsAPI');
  }

  @override
  Future<void> insertContact(ContactsAPI contact) async {
    await _contactsAPIInsertionAdapter.insert(
        contact, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertContacts(List<ContactsAPI> contacts) async {
    await _contactsAPIInsertionAdapter.insertList(
        contacts, OnConflictStrategy.replace);
  }
}

class _$UserPaymentDao extends UserPaymentDao {
  _$UserPaymentDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userPaymentMethodsInsertionAdapter = InsertionAdapter(
            database,
            'UserPaymentMethods',
            (UserPaymentMethods item) => <String, Object?>{
                  'id': item.id,
                  'methodId': item.methodId,
                  'methodName': item.methodName,
                  'cardNumber': item.cardNumber,
                  'validTill': item.validTill,
                  'nameOnCard': item.nameOnCard,
                  'bank': item.bank,
                  'swiftCode': item.swiftCode,
                  'accountNumber': item.accountNumber,
                  'accountHolderName': item.accountHolderName,
                  'phoneNumber': item.phoneNumber,
                  'isDefault':
                      item.isDefault == null ? null : (item.isDefault! ? 1 : 0)
                }),
        _userPaymentMethodsUpdateAdapter = UpdateAdapter(
            database,
            'UserPaymentMethods',
            ['id'],
            (UserPaymentMethods item) => <String, Object?>{
                  'id': item.id,
                  'methodId': item.methodId,
                  'methodName': item.methodName,
                  'cardNumber': item.cardNumber,
                  'validTill': item.validTill,
                  'nameOnCard': item.nameOnCard,
                  'bank': item.bank,
                  'swiftCode': item.swiftCode,
                  'accountNumber': item.accountNumber,
                  'accountHolderName': item.accountHolderName,
                  'phoneNumber': item.phoneNumber,
                  'isDefault':
                      item.isDefault == null ? null : (item.isDefault! ? 1 : 0)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserPaymentMethods>
      _userPaymentMethodsInsertionAdapter;

  final UpdateAdapter<UserPaymentMethods> _userPaymentMethodsUpdateAdapter;

  @override
  Future<List<UserPaymentMethods>> getAllPaymentMethods() async {
    return _queryAdapter.queryList('Select * from UserPaymentMethods',
        mapper: (Map<String, Object?> row) => UserPaymentMethods(
            row['id'] as String?,
            row['methodId'] as String?,
            row['methodName'] as String?,
            row['cardNumber'] as String?,
            row['validTill'] as String?,
            row['nameOnCard'] as String?,
            row['bank'] as String?,
            row['swiftCode'] as String?,
            row['accountNumber'] as String?,
            row['accountHolderName'] as String?,
            row['phoneNumber'] as String?,
            row['isDefault'] == null ? null : (row['isDefault'] as int) != 0));
  }

  @override
  Future<UserPaymentMethods?> getDefaultPaymentId() async {
    return _queryAdapter.query(
        'Select * from UserPaymentMethods WHERE isDefault == true',
        mapper: (Map<String, Object?> row) => UserPaymentMethods(
            row['id'] as String?,
            row['methodId'] as String?,
            row['methodName'] as String?,
            row['cardNumber'] as String?,
            row['validTill'] as String?,
            row['nameOnCard'] as String?,
            row['bank'] as String?,
            row['swiftCode'] as String?,
            row['accountNumber'] as String?,
            row['accountHolderName'] as String?,
            row['phoneNumber'] as String?,
            row['isDefault'] == null ? null : (row['isDefault'] as int) != 0));
  }

  @override
  Future<void> updatePaymentMethod(String id) async {
    await _queryAdapter.queryNoReturn(
        'Update UserPaymentMethods SET isDefault = false WHERE id <> ?1',
        arguments: [id]);
  }

  @override
  Future<void> deletePaymentMethod(String methodName) async {
    await _queryAdapter.queryNoReturn(
        'Delete FROM UserPaymentMethods WHERE methodName = ?1',
        arguments: [methodName]);
  }

  @override
  Future<void> insertUserPaymentMethod(UserPaymentMethods contact) async {
    await _userPaymentMethodsInsertionAdapter.insert(
        contact, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertUserPaymentMethods(
      List<UserPaymentMethods> contacts) async {
    await _userPaymentMethodsInsertionAdapter.insertList(
        contacts, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateUserPaymentMethod(UserPaymentMethods contact) async {
    await _userPaymentMethodsUpdateAdapter.update(
        contact, OnConflictStrategy.abort);
  }
}

class _$AppSettingsDao extends AppSettingsDao {
  _$AppSettingsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _appSettingsInsertionAdapter = InsertionAdapter(
            database,
            'AppSettings',
            (AppSettings item) => <String, Object?>{
                  'userId': item.userId,
                  'id': item.id,
                  'settingsTitle': item.settingsTitle,
                  'settingsValue': item.settingsValue ? 1 : 0,
                  'twoFactorPin': item.twoFactorPin
                }),
        _appSettingsUpdateAdapter = UpdateAdapter(
            database,
            'AppSettings',
            ['userId'],
            (AppSettings item) => <String, Object?>{
                  'userId': item.userId,
                  'id': item.id,
                  'settingsTitle': item.settingsTitle,
                  'settingsValue': item.settingsValue ? 1 : 0,
                  'twoFactorPin': item.twoFactorPin
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AppSettings> _appSettingsInsertionAdapter;

  final UpdateAdapter<AppSettings> _appSettingsUpdateAdapter;

  @override
  Future<AppSettings?> getCurrentSettings() async {
    return _queryAdapter.query('Select TOP 1 from AppSettings',
        mapper: (Map<String, Object?> row) => AppSettings(
            id: row['id'] as String,
            userId: row['userId'] as String,
            settingsTitle: row['settingsTitle'] as String,
            twoFactorPin: row['twoFactorPin'] as String,
            settingsValue: (row['settingsValue'] as int) != 0));
  }

  @override
  Future<AppSettings?> checkUserPin(String userId) async {
    return _queryAdapter.query(
        'Select TOP 1 from AppSettings where userId = ?1',
        mapper: (Map<String, Object?> row) => AppSettings(
            id: row['id'] as String,
            userId: row['userId'] as String,
            settingsTitle: row['settingsTitle'] as String,
            twoFactorPin: row['twoFactorPin'] as String,
            settingsValue: (row['settingsValue'] as int) != 0),
        arguments: [userId]);
  }

  @override
  Future<void> insertSetting(AppSettings appSettings) async {
    await _appSettingsInsertionAdapter.insert(
        appSettings, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertSettings(List<AppSettings> appSettings) async {
    await _appSettingsInsertionAdapter.insertList(
        appSettings, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateSetting(AppSettings appSettings) async {
    await _appSettingsUpdateAdapter.update(
        appSettings, OnConflictStrategy.abort);
  }
}

class _$AppPinsDao extends AppPinsDao {
  _$AppPinsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _appLockPinInsertionAdapter = InsertionAdapter(
            database,
            'AppLockPin',
            (AppLockPin item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'pinHash': item.pinHash,
                  'isAppLockEnabled': item.isAppLockEnabled ? 1 : 0
                }),
        _appLockPinUpdateAdapter = UpdateAdapter(
            database,
            'AppLockPin',
            ['id'],
            (AppLockPin item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'pinHash': item.pinHash,
                  'isAppLockEnabled': item.isAppLockEnabled ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AppLockPin> _appLockPinInsertionAdapter;

  final UpdateAdapter<AppLockPin> _appLockPinUpdateAdapter;

  @override
  Future<List<AppLockPin>> getAppLockPins() async {
    return _queryAdapter.queryList('Select * from AppLockPin',
        mapper: (Map<String, Object?> row) => AppLockPin(
            id: row['id'] as String,
            username: row['username'] as String,
            pinHash: row['pinHash'] as String,
            isAppLockEnabled: (row['isAppLockEnabled'] as int) != 0));
  }

  @override
  Future<List<AppLockPin?>> getUserPin(String userId) async {
    return _queryAdapter.queryList('Select * from AppLockPin where id LIKE ?1',
        mapper: (Map<String, Object?> row) => AppLockPin(
            id: row['id'] as String,
            username: row['username'] as String,
            pinHash: row['pinHash'] as String,
            isAppLockEnabled: (row['isAppLockEnabled'] as int) != 0),
        arguments: [userId]);
  }

  @override
  Future<void> insertAppLock(AppLockPin appLockPin) async {
    await _appLockPinInsertionAdapter.insert(
        appLockPin, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateAppLock(AppLockPin appLockPin) async {
    await _appLockPinUpdateAdapter.update(appLockPin, OnConflictStrategy.abort);
  }
}
