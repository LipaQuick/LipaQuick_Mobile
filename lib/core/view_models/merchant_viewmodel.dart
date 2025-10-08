import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/local_db/database/database.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/contacts/contacts_model.dart';
import 'package:lipa_quick/core/models/nearby/merchant_nearby_model.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/view_models/base_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/main.dart';

class MerchantViewModel extends BaseModel {
  Api? contactsDatabase;
  static final MerchantViewModel _instance = MerchantViewModel._internal();
  var currentDeviceLocation;

  factory MerchantViewModel() {
    return _instance;
  }

  MerchantViewModel._internal() {
    initializeDb();
  }

  void initializeDb() {
    // initialization logic
    contactsDatabase = locator<Api>();
  }

  Future<dynamic> getNearByMerchant() async {
    //print('get nearby merchant');
    setState(ViewState.Loading);

    debugPrint('LOCATION: Location process start');

    currentDeviceLocation = await getCurrentLocation();



    if (currentDeviceLocation is APIException) {
      debugPrint('LOCATION: Exception ${(currentDeviceLocation as APIException).apiError.name}');
      setState(ViewState.Idle);
      return currentDeviceLocation;
    }

    debugPrint('LOCATION: Received LatLng: ${(currentDeviceLocation as Position).latitude},${(currentDeviceLocation as Position).longitude}');

    var currentPosition = currentDeviceLocation as Position;

    var response = await contactsDatabase!.getNearByMerchant(
        currentPosition.latitude, currentPosition.longitude, 10);

    if (response != null && response is NearByResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          setState(ViewState.Idle);
          return response;
        }
      }
    } else if (response is APIException) {
      setState(ViewState.Error);
      return response;
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    //print('get current location');

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    //print('get current location ${serviceEnabled}');
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return const APIException('Location services are disabled.', 2,
          APIError.PERMISSION_UNAVAILABLE);
    }

    permission = await Geolocator.checkPermission();
    //print('get current location${permission}');
    if (permission == LocationPermission.denied) {
      //print('get current location${permission}');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return const APIException(
            'Location services are disabled.', 2, APIError.PERMISSION_DENIED);
      }
      else if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return await Geolocator.getLastKnownPosition(
            forceAndroidLocationManager: true);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return const APIException('Location services are disabled.', 2,
          APIError.PERMISSION_DENIED_FOREVER);
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: true);
  }
}
