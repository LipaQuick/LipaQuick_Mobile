import 'dart:ffi';

import 'package:lipa_quick/core/models/contacts/contacts_model.dart';
import 'package:lipa_quick/core/models/quick_action_model.dart';
import 'package:lipa_quick/core/view_models/base_viewmodel.dart';
import 'package:lipa_quick/main.dart';

import '../../locator.dart';
import '../app_states.dart';
import '../services/db_helper.dart';

class LocalDbViewModel extends BaseModel{
  final DBHelper _localDatabase = locator<DBHelper>();
  late List<QuickActionModel> _allQuickActions, _enabledQuickAction;
  List<QuickActionModel> get quickActionModels => [..._allQuickActions];
  List<QuickActionModel> get homeActionModels => [..._enabledQuickAction];

  //Quick Actions
  Future<void> insertQuickActions(List<QuickActionModel> actionData) async{
    _localDatabase.inseryItems(actionData);
  }

  Future<int> updateItem(QuickActionModel model) async {
    setState(ViewState.Loading);
    Future<int> data = _localDatabase.updateQuickAction(
        model.Id!, model.isEnabled! == 1);
    //_allQuickActions = data as List<QuickActionModel>;
    setState(ViewState.Idle);
    return data;
  }

  Future<List<QuickActionModel>> getAllQuickActions() async{
    return _localDatabase.getQuickActions();
  }

  Future<List<QuickActionModel>> getHomeQuickActions() async{
    setState(ViewState.Loading);
    final Future<List<QuickActionModel>> data = _localDatabase.getEnabledQuickActions();
    setState(ViewState.Idle);
    return data;
  }

  //Contacts
  Future<void> insertContacts(List<Contacts> actionData) async{
    //_localDatabase.inseryItems(actionData);
  }

}