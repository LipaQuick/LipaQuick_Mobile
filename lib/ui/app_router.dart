import 'dart:async';


class AppRouter {

  Future<bool> onBackPressed(bool canPop) {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(true);

    return completer.future;
  }

}