import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';

abstract class PaymentMethodRepository{
  Future<List<UserPaymentMethods>> getAllUserPaymentMethods();

  Future<UserPaymentMethods?> getDefaultUserPayment();

  Future<void> insertUserPaymentMethod(UserPaymentMethods contact);

  Future<void> updateUserPaymentMethod(UserPaymentMethods contact);

  Future<void> updatePaymentMethod(String id);

  Future<void> deletePaymentMethod(String methodName);
}