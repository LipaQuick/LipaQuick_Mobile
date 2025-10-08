import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/crypto/encryption.dart';
import 'package:lipa_quick/core/local_db/repository/pin_repository.dart';
import 'package:lipa_quick/core/models/app_pin/app_pin_lock.dart';
import 'package:lipa_quick/core/models/password_login.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';

// Define User Event
abstract class PinEvent {}

class CreateAppLock extends PinEvent {
  final String enteredPin;

  CreateAppLock(this.enteredPin);
}

class AppPinStatus extends PinEvent {}

class EnableAppLock extends PinEvent {}

class DisableAppLock extends PinEvent {}

class VerifyPin extends PinEvent {
  final String enteredPin;

  VerifyPin(this.enteredPin);
}

// Define User State
abstract class PinState {}

class Initial extends PinState {}

class AppPinEnabled extends PinState {
  final bool enabled;
  AppPinEnabled(this.enabled);
}

class AppLockNotCreated extends PinState {}

class AppLockEnabled extends PinState {}

class AppLockDisabled extends PinState {}

class PinStateVerifying extends PinState {
  final String pin;

  PinStateVerifying({required this.pin});

  int get pinCount => pin.length;
}

class PinVerified extends PinState {}

class PinVerificationFailed extends PinState {}

// Define User Bloc
class AppPinBloc extends Bloc<PinEvent, PinState> {
  final AppPinRepository _userRepository;

  AppPinBloc(this._userRepository) : super(Initial()){
    on<CreateAppLock>(_createAppLock);
    on<EnableAppLock>(_enableAppLock);
    on<AppPinStatus>(_appLockEnabled);
    on<DisableAppLock>(_disableAppLock);
    on<VerifyPin>(_onPinVerify);
  }

  _createAppLock(CreateAppLock event, Emitter<PinState> emit) async {
    List<AppLockPin?> appLockPin = await _userRepository.getAppLockPins();
    final prefs = await LocalSharedPref().getUserDetails();
    UserDetails details = UserDetails.fromJson(jsonDecode(prefs));

    print('Create App Lock Pin: ${appLockPin.toString()}');

    var passwordDto = PasswordDto(event.enteredPin,
        DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));

    var newAppLock = AppLockPin(id: details.phoneNumber
        , username: "${details.firstName} ${details.lastName}"
        ,isAppLockEnabled: true
        , pinHash: encryptAESCryptoJS(jsonEncode(passwordDto.toJson())));
    if(appLockPin.isEmpty){
      print('Create App Lock Pin Null');
      await _userRepository.insertAppLock(newAppLock);
    }else{
      print('Create App Lock Pin Not Null');
      await _userRepository.updateAppLock(
          appLockPin.first!
              .copyWithPin(newPinhash:
          encryptAESCryptoJS(jsonEncode(passwordDto.toJson())))
      );
    }

    emit(AppPinEnabled(true));
  }

  _enableAppLock(EnableAppLock event, Emitter<PinState> emit) async {

    final prefs = await LocalSharedPref().getUserDetails();
    UserDetails details = UserDetails.fromJson(jsonDecode(prefs));

    List<AppLockPin?> appLockPin = await _userRepository.getUserPin(details.phoneNumber);

    print('_enableAppLock : ${appLockPin.toString()}');

    if(appLockPin.isEmpty){
      emit(AppLockNotCreated());
      return;
    }

    var update = appLockPin.first!.copyWith(isAppLockEnabled: true);

    await _userRepository.updateAppLock(update);

    emit(AppPinEnabled(true));
  }

  _disableAppLock(DisableAppLock event, Emitter<PinState> emit) async {
    final prefs = await LocalSharedPref().getUserDetails();
    UserDetails details = UserDetails.fromJson(jsonDecode(prefs));

    List<AppLockPin?> appLockPin = await _userRepository.getUserPin(details.phoneNumber);

    var update = appLockPin.first!.copyWith(isAppLockEnabled: false);

    await _userRepository.updateAppLock(update);

    emit(AppPinEnabled(false));
  }

  _onPinVerify(VerifyPin event, Emitter<PinState> emit) async {
    final prefs = await LocalSharedPref().getUserDetails();
    UserDetails details = UserDetails.fromJson(jsonDecode(prefs));

    List<AppLockPin?>? appLockPin = await _userRepository.getUserPin(details.phoneNumber);
    print(appLockPin.length);
    if(appLockPin.isEmpty){
      emit(PinVerificationFailed());
    }

    var passwordDto = PasswordDto(event.enteredPin,
        DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));

    var decryptedJSON = jsonDecode(decryptAESCryptoJS(appLockPin.first!.pinHash));

    var savedPasswordDTO = PasswordDto.fromJson(decryptedJSON);

    print('Pin Verify JSON ${savedPasswordDTO.toJson()}');

    if(savedPasswordDTO.Password == passwordDto.Password){
      emit(PinVerified());
    }else{
      emit(PinVerificationFailed());
    }
  }

   _appLockEnabled(AppPinStatus event, Emitter<PinState> emit) async {

     List<AppLockPin?> appLockPins = await _userRepository.getAppLockPins();
     print('_appLockEnabled: ${appLockPins.toString()}');
     try{
       final prefs = await LocalSharedPref().getUserDetails();
       UserDetails details = UserDetails.fromJson(jsonDecode(prefs));

       List<AppLockPin?> appLockPin = await _userRepository.getUserPin(details.phoneNumber);
       print(appLockPin.toString());
       if(appLockPin.isNotEmpty){
         emit(AppPinEnabled(appLockPin.first!.isAppLockEnabled));
       }else{
         emit(AppPinEnabled(false));
       }
     }catch(e){
       emit(AppPinEnabled(false));
     }
  }
}
