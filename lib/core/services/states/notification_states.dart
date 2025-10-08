import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatState with ChangeNotifier {
  bool _isChatPageOpen = false;

  bool get isChatPageOpen => _isChatPageOpen;

  Future<void> openChatPage() async {
    _isChatPageOpen = true;
    notifyListeners();
  }

  void closeChatPage() {
    _isChatPageOpen = false;
    notifyListeners();
  }
}

class AuthState with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> loggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('login') ?? false;
    notifyListeners();
  }
}