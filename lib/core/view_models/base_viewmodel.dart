import 'package:flutter/cupertino.dart';
import 'package:lipa_quick/core/app_states.dart';

class BaseModel extends ChangeNotifier{
  ViewState _viewState = ViewState.Idle;

  ViewState get state => _viewState;

  void setState(ViewState viewState){
    _viewState = viewState;
    notifyListeners();
  }
}