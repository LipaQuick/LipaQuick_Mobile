import 'package:floor/floor.dart';
import 'package:lipa_quick/core/models/payment/payment_methods.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';

import '../../models/contacts/contacts.dart';

@dao
abstract class UserPaymentDao{
  @Query('Select * from UserPaymentMethods')
  Future<List<UserPaymentMethods>> getAllPaymentMethods();

  @Query('Select * from UserPaymentMethods WHERE isDefault == true')
  Future<UserPaymentMethods?> getDefaultPaymentId();

  @insert
  Future<void> insertUserPaymentMethod(UserPaymentMethods contact);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUserPaymentMethods(List<UserPaymentMethods> contacts);

  @Update()
  Future<void> updateUserPaymentMethod(UserPaymentMethods contact);

  @Query('Update UserPaymentMethods SET isDefault = false WHERE id <> :id')
  Future<void> updatePaymentMethod(String id);

  @Query('Delete FROM UserPaymentMethods WHERE methodName = :methodName')
  Future<void> deletePaymentMethod(String methodName);
}