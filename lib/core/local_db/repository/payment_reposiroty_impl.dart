import 'package:lipa_quick/core/local_db/database/database.dart';
import 'package:lipa_quick/core/local_db/repository/payment_method_repository.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';
import 'package:lipa_quick/core/provider/DBProvider.dart';
import 'package:lipa_quick/main.dart';

class PaymentMethodsRepositoryImpl extends PaymentMethodRepository{
  late AppDatabase appDatabase;

  PaymentMethodsRepositoryImpl(){
    initDb();
  }

  initDb() async {
    appDatabase = await locator<DBProvider>().database;
    //locator.signalReady(this);
  }

  @override
  Future<List<UserPaymentMethods>> getAllUserPaymentMethods() {
    return appDatabase.userPaymentDao.getAllPaymentMethods();
  }

  @override
  Future<UserPaymentMethods?> getDefaultUserPayment() {
    return appDatabase.userPaymentDao.getDefaultPaymentId();
  }

  @override
  Future<void> insertUserPaymentMethod(UserPaymentMethods userPayment) async {
    return appDatabase.userPaymentDao.insertUserPaymentMethod(userPayment);
  }

  @override
  Future<void> updateUserPaymentMethod(UserPaymentMethods userPayment) {
    return appDatabase.userPaymentDao.updateUserPaymentMethod(userPayment);
  }

  @override
  Future<void> updatePaymentMethod(String id) {
    return appDatabase.userPaymentDao.updatePaymentMethod(id);
  }

  @override
  Future<void> deletePaymentMethod(String methodName) {
    return appDatabase.userPaymentDao.deletePaymentMethod(methodName);
  }


}