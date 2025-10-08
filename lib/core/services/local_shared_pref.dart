import 'package:lipa_quick/core/managers/language/language_bloc.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/core/view_models/contact_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSharedPref{
  Future<bool> clearLoginDetails() async{
    locator<ContactsDBViewModel>().deleteContacts();
    await locator<AccountViewModel>().logout();

    return true;
  }

  Future<bool> setToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('token', value);
  }

  Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token')??'';
  }
  Future<bool> setFcmToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('fcmToken') != value) {
      prefs.setString('oldFcmToken', value);
    }
    return prefs.setString('fcmToken', value);
  }

  Future<String> getFcmToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcmToken')??'';
  }

  Future<String> getOldFcmToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('oldFcmToken') ? prefs.getString('oldFcmToken')??'' : '';
  }


  Future<String> getUserDetails() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userDetails')??'';
  }
  void setUserDetails(String userDetails) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userDetails', userDetails);
  }

  Future<bool> setNotification(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('notification', value);
  }

  Future<bool> getNotification() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification')??false;
  }

  Future<bool> setTwoFactor(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('twoFactorAuthentication', value);
  }

  Future<bool> getTwoFactor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('twoFactorAuthentication')??false;
  }

  Future<String> getCurrency() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(currencyPrefsKey)??'';
  }

  Future<String> getCurrentChatReceiversId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(receiverPrefsKey)??'';
  }

  Future<bool> setCurrentChatId(String receiversChatId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(receiverPrefsKey, receiversChatId);
  }

}
