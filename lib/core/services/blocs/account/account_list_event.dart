import 'package:lipa_quick/core/models/accounts/account_model.dart';

import '../../../models/banks/bloc/bank_event.dart';

class AccountFetched extends ApiEvent {

}

class DefaultPaymentFetchEvent extends ApiEvent {

}

class AccountDeleteEvent extends ApiEvent {
  final AccountDetails? accountDetails;

  AccountDeleteEvent(this.accountDetails);
}

class AccountDefaultEvent extends ApiEvent {
  final AccountDetails? accountDetails;

  AccountDefaultEvent(this.accountDetails);
}


