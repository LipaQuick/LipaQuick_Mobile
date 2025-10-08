import 'dart:async';

import 'package:floor/floor.dart';
import 'package:lipa_quick/core/local_db/dao/app_setting_dao.dart';
import 'package:lipa_quick/core/local_db/dao/contacts_dao.dart';
import 'package:lipa_quick/core/local_db/dao/pin_repo_dao.dart';
import 'package:lipa_quick/core/local_db/dao/user_payment_dao.dart';
import 'package:lipa_quick/core/models/app_pin/app_pin_lock.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../models/settings/UserSettings.dart';

part 'database.g.dart';

@Database(version: 1, entities: [ContactsAPI, UserPaymentMethods
  , AppSettings, AppLockPin])
abstract class AppDatabase extends FloorDatabase {
  ContactsDao get contactsDao;
  UserPaymentDao get userPaymentDao;
  AppSettingsDao get appSettingsDao;
  AppPinsDao get appLockDao;
}