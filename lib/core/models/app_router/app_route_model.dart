import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/payment/payment.dart';

class TransactionPageItems{
  PaymentRequest? paymentRequest;
  ContactsAPI? contact;

  TransactionPageItems(this.paymentRequest, this.contact);
}