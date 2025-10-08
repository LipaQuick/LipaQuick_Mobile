import 'package:lipa_quick/core/models/cards/cards_model.dart';

import '../../banks/bloc/bank_event.dart';

class CardsFetched extends ApiEvent {

}

class AddCardEvent extends ApiEvent{

}

class CardDefaultEvent extends ApiEvent{
  final CardDetailsModel? _model;


  CardDetailsModel get model => _model!;

  CardDefaultEvent(this._model);
}


class CardDeleteEvent extends ApiEvent{
  final CardDetailsModel? _model;


  CardDetailsModel get model => _model!;

  CardDeleteEvent(this._model);
}

