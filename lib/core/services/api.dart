import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/crypto/encryption.dart';
import 'package:lipa_quick/core/global/Application.dart';
import 'package:lipa_quick/core/local_db/repository/payment_reposiroty_impl.dart';
import 'package:lipa_quick/core/models/IdentityResponse.dart';
import 'package:lipa_quick/core/models/accounts/add_account_model.dart';
import 'package:lipa_quick/core/models/address.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/banks/bloc/bank_bloc.dart';
import 'package:lipa_quick/core/models/cards/add_card_model.dart';
import 'package:lipa_quick/core/models/cards/cards_model.dart';
import 'package:lipa_quick/core/models/change_password_model.dart';
import 'package:lipa_quick/core/models/chats/chat_message_response.dart';
import 'package:lipa_quick/core/models/chats/file_upload_response.dart';
import 'package:lipa_quick/core/models/chats/recent_chat/recent_chat_response.dart';
import 'package:lipa_quick/core/models/contacts/contacts_model.dart';
import 'package:lipa_quick/core/models/contacts/contacts_response_model.dart';
import 'package:lipa_quick/core/models/discount/discount_model.dart';
import 'package:lipa_quick/core/models/nearby/merchant_nearby_model.dart';
import 'package:lipa_quick/core/models/password_login.dart';
import 'package:lipa_quick/core/models/payment/default_payments.dart';
import 'package:lipa_quick/core/models/payment/payment.dart';
import 'package:lipa_quick/core/models/payment/payment_status_response.dart';
import 'package:lipa_quick/core/models/payment/paymentresponse.dart';
import 'package:lipa_quick/core/models/payment/recent_transaction.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';
import 'package:lipa_quick/core/models/profile/profile_list_reponse.dart';
import 'package:lipa_quick/core/models/profile/user_details.dart';
import 'package:lipa_quick/core/models/recent_user_transaction.dart';
import 'package:lipa_quick/core/models/request_header_dto.dart';
import 'package:lipa_quick/core/models/reset_password_request.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/models/service/service_response.dart';
import 'package:lipa_quick/core/models/social_post/social_post_react.dart';
import 'package:lipa_quick/core/models/social_post/social_post_request.dart';
import 'package:lipa_quick/core/models/social_post/social_post_response.dart';
import 'package:lipa_quick/core/services/device_details.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/utils/jwt_utils.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:uuid/uuid.dart';
import '../models/accounts/account_model.dart';
import '../models/requests.dart';
import '../models/user.dart';
import 'package:image_picker/image_picker.dart';

/// The service responsible for networking requests
class Api {
  http.Client? client;

  Api() {
    client = http.Client();
  }

  Future<dynamic> login(dynamic loginDetails,
      {String? fcmToken, String? oldFcmToken}) async {
    final url = Uri.parse('${ApplicationData().API_URL}/account/login');
    // Get user profile for id
    http.Response response;
    print(url);
    try {

      var details = (loginDetails as LoginRequest).toJson();
      var passwordDto = PasswordDto(loginDetails.password,
          DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));

      var token = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        token = value;
      });
      RequestHeaderDto requestHeaderDto =
      RequestHeaderDto(token['Source'], token['Device'], token['Version']);
      String headerEn =
      encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      String encryptedPassword = encryptAESCryptoJS(jsonEncode(passwordDto));
      details['password'] = encryptedPassword;
      //print(jsonEncode(requestHeaderDto.toJson()));
      print(jsonEncode(details));
      // print(decryptAESCryptoJS('Y16fH+QWWrrc+smbUCCMFIL+ZxGcC+FzdzE7ajdxNKG3UEFzXqV8lIGzF67W/zXjAkgbDAaKKRJ08yfpOylWRyZoRh+J8oSlmSWL/1ijI8Wrgw46LOjDzJZqQWXPJywE'));
      Map<String, String> headers = {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn
      };
      headers.putIfAbsent('newFcmToken', () => fcmToken!);
      headers.putIfAbsent('oldFcmToken', () => '');
      response = await client!
          .post(url, body: jsonEncode(details), headers: headers)
          .timeout(const Duration(seconds: 50));

      debugPrint(
          'Response: ${response.statusCode}\nHeader: ${response.headers}\nBody: ${response.body}');
      if (response.statusCode == 200) {
        Map<String, dynamic> reponse = jsonDecode(response.body)['data'];
        // if (reponse.containsKey('profilePicture'))
        //   reponse.remove('profilePicture');
            ;
        // print(
        //     '\nBody: ${(jsonDecode(response.body) as Map<String, dynamic>).remove('data')}');
        // Convert and return
        var data = LoginApiResponse.fromJson(jsonDecode(response.body));
        // print(
        //     'Response: ${response.statusCode}\nBody: ${data.userData!.phoneNumberConfirmed}');
        return data;
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        // print(
        //     'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
              ? APIError.UN_AUTHORIZED
              : response.statusCode == 403
              ? APIError.FORBIDDEN
              : response.statusCode == 404
              ? APIError.NOT_FOUND
              : response.statusCode == 500
              ? APIError.INTERNAL_SERVER_ERROR
              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData =
          LoginApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }else{
          return const APIException(
              "Its seems something is broken, please check back again after some time.",
              0,
              APIError.NONE);
        }
      } else {
        return const APIException(
            "Op's, something went, please restart application",
            0,
            APIError.NONE);
      }

    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> changePassword(dynamic request) async {
    final url =
        Uri.parse('${ApplicationData().API_URL}/account/changePassword');
    // Get user profile for id
    http.Response response;
    // print(url);
    try {
      var details = (request as ChangePasswordRequest).toJson();
      //var passwordDto = PasswordDto(request.password, DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));
      String authtoken = "";
      await LocalSharedPref().getToken().then((value) {
        authtoken = value;
      });

      var token = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        token = value;
      });
      RequestHeaderDto requestHeaderDto =
          RequestHeaderDto(token['Source'], token['Device'], token['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      //String encryptedPassword = encryptAESCryptoJS(jsonEncode(passwordDto));
      // details['password'] = encryptedPassword;
      // print(jsonEncode(requestHeaderDto.toJson()));
      //print(details);
      //print(decryptAESCryptoJS(headerEn));
      response = await client!.put(url, body: jsonEncode(details), headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $authtoken'
      }).timeout(const Duration(seconds: 50));
      //print(          'Response: ${response.statusCode}\nHeader: ${response.headers}\nBody: ${jsonDecode(response.body)['data']}');
      if (response.statusCode == 200) {
        // Convert and return
        return ChangePasswordResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData =
              ChangePasswordResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Op's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException {
      return APIException(
          'Request timed-out, Please check your internet connection.',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> forgotPassword(dynamic request) async {
    final url = Uri.parse('${ApplicationData().API_URL}/account/resetpassword');
    // Get user profile for id
    http.Response response;
    //print(url);
    try {
      //var passwordDto = PasswordDto(request.password, DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));
      String authtoken = "";
      await LocalSharedPref().getToken().then((value) {
        authtoken = value;
      });

      var token = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        token = value;
      });
      RequestHeaderDto requestHeaderDto =
          RequestHeaderDto(token['Source'], token['Device'], token['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      //String encryptedPassword = encryptAESCryptoJS(jsonEncode(passwordDto));
      // details['password'] = encryptedPassword;
      // print(jsonEncode(requestHeaderDto.toJson()));
      print(jsonEncode((request as ResetPasswordRequest).toJson()));
      //print(decryptAESCryptoJS(headerEn));
      response = await client!.post(url,
          body: jsonEncode((request as ResetPasswordRequest).toJson()),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'User-Agent': headerEn,
            'Authorization': 'Bearer $authtoken'
          }).timeout(const Duration(seconds: 50));
      //print(
      //'Response: ${response.statusCode}\nHeader: ${response.headers}\nBody: ${jsonDecode(response.body)['data']}');
      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message,
              response.statusCode,
              apiErrorCode,
              responseData.errors != null && responseData.errors!.isNotEmpty
                  ? responseData.errors
                  : []);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException {
      return APIException(
          'Request timed-out, Please check your internet connection.',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> getUserProfile() async {
    final url = Uri.parse('${ApplicationData().API_URL}/Profile');

    String token = "";
    await LocalSharedPref().getToken().then((value) {

      token = value;
    });
    var deviceData = <String, dynamic>{};
    await DeviceInfo().getDeviceInfo().then((value) {
      deviceData = value;
    });
    RequestHeaderDto requestHeaderDto = RequestHeaderDto(
        deviceData['Source'], deviceData['Device'], deviceData['Version']);
    String headerEn =
    encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
    // Get user profile for id
    //print('Calling API');
    var response = await client!.get(url, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "User-Agent": headerEn,
      'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 50));
    debugPrint(response.body);
    if (response.statusCode == 200) {
      // Convert and return
      var data = ProfileListResponse.fromJson(jsonDecode(response.body));
      //print('Response: ${response.statusCode}\nBody: ${data.profileDetails}');
      return data;
    } else if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 404 ||
        response.statusCode == 503 ||
        response.statusCode == 500) {
      //print(            'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
      if (response.body.isNotEmpty) {
        var apiErrorCode = response.statusCode == 400
            ? APIError.BAD_REQUEST
            : response.statusCode == 401
            ? APIError.UN_AUTHORIZED
            : response.statusCode == 403
            ? APIError.FORBIDDEN
            : response.statusCode == 404
            ? APIError.NOT_FOUND
            : response.statusCode == 500
            ? APIError.INTERNAL_SERVER_ERROR
            : APIError.UN_AVAILABLE;
        // Convert and return
        var responseData =
        ProfileListResponse.fromJson(jsonDecode(response.body));
        return APIException(
            responseData.errorMessage, response.statusCode, apiErrorCode);
      }
    } else {
      return const APIException(
          "Oop's, something went, please restart application",
          0,
          APIError.NONE);
    }
    // try {
    //
    // } catch (e) {
    //   //print(e.toString());
    //   return APIException(e.toString(), 0, APIError.NONE);
    // }
  }

  Future<dynamic> getUserAccount(String userName) async {
    try {
      final url = Uri.parse('${ApplicationData().API_URL}/account/${userName}');
      var deviceData = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceData = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceData['Source'], deviceData['Device'], deviceData['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      // Get user profile for id
      print('$url');
      print('Calling API');
      var response = await client!.get(url, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        "User-Agent": headerEn,
      }).timeout(Duration(seconds: 50));
      if (kDebugMode) {
        print(response.body +
            '\n Status Code: ' +
            response.statusCode.toString());
      }
      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> getIdentity() async {
    try {
      final url = Uri.parse('${ApplicationData().API_URL}/IdentityType');
      var deviceData = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceData = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceData['Source'], deviceData['Device'], deviceData['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      // Get user profile for id
      print('$url');
      print('Calling API');
      var response = await client!.get(url, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        "User-Agent": headerEn,
      }).timeout(Duration(seconds: 50));
      if (kDebugMode) {
        //print(            response.body + '\n Status Code: ' + response.statusCode.toString());
      }
      if (response.statusCode == 200) {
        // Convert and return
        return IdentityResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData =
              IdentityResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> registerUser(
      UserDetailsModel registerModel, XFile identityPhoto) async {
    try {
      final url = Uri.parse('${ApplicationData().API_URL}/Account/register');

      var request = http.MultipartRequest("POST", url);

      //registerModel.setConfirmPassword(registerModel.password);
      var token = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        token = value;
      });
      RequestHeaderDto requestHeaderDto =
          RequestHeaderDto(token['Source'], token['Device'], token['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      Map<String, String> headers = {'Content-Type': 'application/json'};
      headers.putIfAbsent('User-Agent', () => headerEn);
      headers.putIfAbsent('accept', () => 'application/json');
      debugPrint(jsonEncode(registerModel.toJson()));
      request.headers.addAll(headers);
      Map<String, dynamic> data = registerModel.toJson();
      data.remove('emailConfirmed');
      data.remove('phoneNumberConfirmed');
      Map<String, String> register = data.cast<String, String>();
      request.fields.addAll(register);
      try {
        request.files.add(await http.MultipartFile.fromPath(
            'IdentityDocPhoto', identityPhoto.path));
      } catch (e) {
        debugPrint(e.toString());
      }

      // request.fields.addAll(registerModel.toJson());

      var sendRequest =
          await request.send().timeout(const Duration(seconds: 50));
      var response = await http.Response.fromStream(sendRequest);

      if (kDebugMode) {
        print(response.body +
            '\n Status Code: ' +
            response.statusCode.toString());
      }
      if (response.statusCode == 200) {
        // Convert and return
        return RegisterApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData =
              RegisterApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message,
              response.statusCode,
              apiErrorCode,
              responseData.errors != null && responseData.errors!.isNotEmpty
                  ? responseData.errors
                  : []);
        } else if (response.statusCode == 500) {
          return APIException("Internal Server Error, Please contact support",
              response.statusCode, APIError.INTERNAL_SERVER_ERROR);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  ///Account API's
  Future<dynamic> getAccounts([int startLength = 0]) async {
    try {
      final url = Uri.parse('${ApplicationData().API_URL}/BankAccounts');
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });
      var deviceData = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceData = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceData['Source'], deviceData['Device'], deviceData['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      // Get user profile for id
      print('Calling API');
      var response = await client!.get(url, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        "User-Agent": headerEn,
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        print(response.body +
            '\n Status Code: ' +
            response.statusCode.toString());
      }

      if (response.statusCode == 200) {
        // Convert and return
        return AccountListResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (kDebugMode) {
          //print(              'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
        }
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData =
              AccountListResponse.fromJson(jsonDecode(response.body));
          print('API Exception Data${responseData.toString()}');
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> addAccount(AddAccountModel _addAccountModel) async {
    try {
      final url = Uri.parse('${ApplicationData().API_URL}/BankAccounts');
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceData = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceData = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceData['Source'], deviceData['Device'], deviceData['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      print(jsonEncode(_addAccountModel.toJson()));
      // Get user profile for id
      var response = await client!
          .post(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                "User-Agent": headerEn,
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(_addAccountModel.toJson()))
          .timeout(const Duration(seconds: 50));

      print(response.body);

      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (kDebugMode) {
          //print(            'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
        }
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          print('API Exception Data${responseData.toString()}');
          return APIException(responseData.message, response.statusCode,
              apiErrorCode, responseData.errors);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> removeAccount(AccountDetails accountData) async {
    try {
      final url = Uri.parse(
          '${ApplicationData().API_URL}/BankAccounts/${accountData.id!}');
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });
      var deviceData = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceData = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceData['Source'], deviceData['Device'], deviceData['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      // Get user profile for id
      print('Calling API');
      var response = await client!.delete(url, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        "User-Agent": headerEn,
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        //print(            response.body + '\n Status Code: ' + response.statusCode.toString());
      }

      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        //print(            'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          print('API Exception Data${responseData.toString()}');
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> setDefaultAccount(AccountDetails accountData) async {
    try {
      final url = Uri.parse(
          '${ApplicationData().API_URL}/BankAccounts/${accountData.id!}');
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });
      var deviceData = <String, dynamic>{};
      var setDefaultData = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceData = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceData['Source'], deviceData['Device'], deviceData['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      // Get user profile for id
      print('Calling API');
      setDefaultData.putIfAbsent('primary', () => true);
      var response = await client!
          .put(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                "User-Agent": headerEn,
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(setDefaultData))
          .timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        print(response.body +
            '\n Status Code: ' +
            response.statusCode.toString());
      }

      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        //print(            'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          if (responseData.message!.contains('edit')) {
            return responseData;
          }
          print('API Exception Data${responseData.toString()}');
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  ///Credit/Debit Card API's
  Future<dynamic> getCards([int startLength = 0]) async {
    // try{
    //
    // }on TimeoutException catch (_){
    //   return const APIException('The request timed-out, Please check your internet connection'
    //       , 0, APIError.SYSTEM_ERROR);
    // }
    // catch(e){
    //   return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    // }
    final url = Uri.parse('${ApplicationData().API_URL}/Cards');
    String token = "";
    await LocalSharedPref().getToken().then((value) {
      token = value;
    });
    var deviceData = <String, dynamic>{};
    await DeviceInfo().getDeviceInfo().then((value) {
      deviceData = value;
    });
    RequestHeaderDto requestHeaderDto = RequestHeaderDto(
        deviceData['Source'], deviceData['Device'], deviceData['Version']);
    String headerEn = encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
    // Get user profile for id
    print('Calling API');
    var response = await client!.get(url, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "User-Agent": headerEn,
      'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 50));
    if (kDebugMode) {
      print(
          response.body + '\n Status Code: ' + response.statusCode.toString());
    }

    if (response.statusCode == 200) {
      // Convert and return
      return CardListResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 404 ||
        response.statusCode == 503 ||
        response.statusCode == 500) {
      //print(            'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
      if (response.body.isNotEmpty) {
        var apiErrorCode = response.statusCode == 400
            ? APIError.BAD_REQUEST
            : response.statusCode == 401
                ? APIError.UN_AUTHORIZED
                : response.statusCode == 403
                    ? APIError.FORBIDDEN
                    : response.statusCode == 404
                        ? APIError.NOT_FOUND
                        : response.statusCode == 500
                            ? APIError.INTERNAL_SERVER_ERROR
                            : APIError.UN_AVAILABLE;
        // Convert and return
        var responseData = CardListResponse.fromJson(jsonDecode(response.body));
        print('API Exception Data ${responseData.toString()}');
        return APIException(
            responseData.message, response.statusCode, apiErrorCode);
      }
    } else {
      return const APIException(
          "Oop's, something went, please restart application",
          0,
          APIError.NONE);
    }
  }

  Future<dynamic> addCards(AddCardModel _addCardModel) async {
    try {
      final url = Uri.parse('${ApplicationData().API_URL}/cards');
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceData = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceData = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceData['Source'], deviceData['Device'], deviceData['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      print(jsonEncode(_addCardModel.toJson()));
      // Get user profile for id
      var response = await client!
          .post(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                "User-Agent": headerEn,
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(_addCardModel.toJson()))
          .timeout(const Duration(seconds: 50));

      print(response.body + 'Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Convert and return
        // PaymentMethodsRepositoryImpl impl = locator<PaymentMethodsRepositoryImpl>();
        // //Check if Payment Methods Added in the System:
        // await impl.getAllUserPaymentMethods().then((value) => {
        //   impl.insertUserPaymentMethod(UserPaymentMethods.cardMethod(
        //       const Uuid().v1(),
        //       'Credit/Debit Card',
        //       _addCardModel.cardNumber,
        //       _addCardModel.validTill,
        //       _addCardModel.nameOnCard,
        //       value.isEmpty)),
        // });
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        //print(            'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          print('API Exception Data${responseData.toString()}');
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> setDefaultCard(CardDetailsModel accountData) async {
    try {
      final url =
          Uri.parse('${ApplicationData().API_URL}/cards/${accountData.id!}');
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });
      var deviceData = <String, dynamic>{};
      var setDefaultData = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceData = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceData['Source'], deviceData['Device'], deviceData['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      // Get user profile for id
      print('Calling API');
      setDefaultData.putIfAbsent('isPrimary', () => accountData.isPrimary);
      var response = await client!
          .put(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                "User-Agent": headerEn,
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(setDefaultData))
          .timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        print(response.body +
            '\n Status Code: ' +
            response.statusCode.toString());
      }

      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        //print(            'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          if (responseData.message!.contains('edit')) {
            return responseData;
          }
          print('API Exception Data${responseData.toString()}');
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> deleteCard(CardDetailsModel cardsData) async {
    try {
      final url =
          Uri.parse('${ApplicationData().API_URL}/Cards/${cardsData.id!}');
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });
      var deviceData = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceData = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceData['Source'], deviceData['Device'], deviceData['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      // Get user profile for id
      print('Calling API');
      var response = await client!.delete(url, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        "User-Agent": headerEn,
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        print(response.body +
            '\n Status Code: ' +
            response.statusCode.toString());
      }

      if (response.statusCode == 200) {
        // Convert and return
        return CardListResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        //print(            'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData =
              CardListResponse.fromJson(jsonDecode(response.body));
          print('API Exception Data${responseData.toString()}');
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<List<AddressDetails>?> fetchAddress(
      {String? endPoint, String? id}) async {
    var url;
    if (id != null) {
      url = Uri.parse('${ApplicationData().API_URL}/address/$endPoint/$id');
    } else {
      url = Uri.parse('${ApplicationData().API_URL}/address/$endPoint');
    }
    var deviceData = <String, dynamic>{};
    await DeviceInfo().getDeviceInfo().then((value) {
      deviceData = value;
    });
    RequestHeaderDto requestHeaderDto = RequestHeaderDto(
        deviceData['Source'], deviceData['Device'], deviceData['Version']);
    String headerEn = encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

    // Get user profile for id
    debugPrint('Calling API with url : $url');
    var response = await client!.get(url, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "User-Agent": headerEn
    }).timeout(const Duration(seconds: 50));
    //debug//print(        response.body + '\n Status Code: ' + response.statusCode.toString());

    if (response.statusCode == 200) {
      // Convert and return
      return AddressModel.fromJson(jsonDecode(response.body)).data;
    } else if (response.statusCode == 401 || response.statusCode == 404) {
      // Convert and return
      return [];
    } else if (response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        // Convert and return
        return [];
      } else {
        return [];
      }
    } else if (response.statusCode == 401) {
      print('401');
      return [];
    } else {
      return [];
    }
  }

  Future<dynamic> searchContacts(String query) async {
    final url = Uri.parse('${ApplicationData().API_URL}/usercontacts/$query');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      print(decryptAESCryptoJS(headerEn));
      response = await client!.get(url, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 50));
      //print(          'Response: ${response.statusCode}\nHeader: ${response.headers}\nBody: ${jsonDecode(response.body)['data']}');
      if (response.statusCode == 200) {
        // Convert and return
        return ContactsResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData =
              ContactsResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> searchUserDetails(String query) async {
    final url = Uri.parse('${ApplicationData().API_URL}/account/$query');
    // Get user profile for id
    http.Response response;
    print(url);

    String token = "";
    await LocalSharedPref().getToken().then((value) {
      token = value;
    });

    var deviceInfo = <String, dynamic>{};
    await DeviceInfo().getDeviceInfo().then((value) {
      deviceInfo = value;
    });
    RequestHeaderDto requestHeaderDto = RequestHeaderDto(
        deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
    String headerEn =
    encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

    print(decryptAESCryptoJS(headerEn));
    response = await client!.get(url, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      'User-Agent': headerEn,
      'Authorization': 'Bearer $token'
    }).timeout(const Duration(seconds: 50));
    print('Received a response');
    //print('Response: ${response.statusCode}\nHeader: ${response.headers}\n');
    if (response.statusCode == 200) {
      // Convert and return
      //print('Parsing response');
      print('Parsing response details:');
      var details = UserDetailsApiResponse.fromJson(jsonDecode(response.body));
      return details;
    } else if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 404 ||
        response.statusCode == 503 ||
        response.statusCode == 500) {
      if (response.body.isNotEmpty) {
        var apiErrorCode = response.statusCode == 400
            ? APIError.BAD_REQUEST
            : response.statusCode == 401
            ? APIError.UN_AUTHORIZED
            : response.statusCode == 403
            ? APIError.FORBIDDEN
            : response.statusCode == 404
            ? APIError.NOT_FOUND
            : response.statusCode == 500
            ? APIError.INTERNAL_SERVER_ERROR
            : APIError.UN_AVAILABLE;
        var responseData =
        UserDetailsApiResponse.fromJson(jsonDecode(response.body));
        print('Parsing response details: ${responseData.toString()}');
        return APIException(
            responseData.errorMessage, response.statusCode, apiErrorCode);
      }
    } else {
      print('Exception response ');
      return const APIException(
          "Oop's, something went, please restart application",
          0,
          APIError.NONE);
    }

    // try {
    //
    // } on TimeoutException catch (_) {
    //   return const APIException(
    //       'The request timed-out, Please check your internet connection',
    //       0,
    //       APIError.SYSTEM_ERROR);
    // } catch (e) {
    //   print(e);
    //   return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    // }
  }

  Future<dynamic> getNearByMerchant(
      double lat, double lng, double radius) async {
    final url = Uri.parse('${ApplicationData().API_URL}/merchant/nearby');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      Map<String, dynamic> locationRequest = <String, dynamic>{
        'lat': lat,
        'lng': lng,
        'radius': radius*1000,
      };
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      debugPrint('LOCATION: Nearby Request ${jsonEncode(locationRequest)}');
      print(decryptAESCryptoJS(headerEn));
      response =
          await client!.post(url, body: jsonEncode(locationRequest), headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 50));
      print(          'Response: ${response.statusCode}\nHeader: ${response.headers}\nBody: ${jsonDecode(response.body)['data']}');
      if (response.statusCode == 200) {
        // Convert and return
        var data = NearByResponse.fromJson(jsonDecode(response.body));
        print('Response: ${response.statusCode}\nBody: ${data.data!}');
        return data;
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        //print(            'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = NearByResponse.fromJson(jsonDecode(response.body));
          print('API Exception Data${responseData.toString()}');
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  /*
  All Payment API
  */
  Future<dynamic> sendpayment(PaymentRequest addAccountModel) async {
    final url = Uri.parse('${ApplicationData().API_URL}/payment');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      String paymentPayload =
          encryptAESCryptoJS(jsonEncode(addAccountModel.toJson()));
      PaymentRequestPayload payload = new PaymentRequestPayload(paymentPayload);

      print(jsonEncode(payload.toJson()));

      Duration timeoutDuration =
          addAccountModel.paymentMode!.toLowerCase().contains("mtn")
              ? Duration(minutes: 13)
              : Duration(minutes: 1);
      response =
          await client!.post(url, body: jsonEncode(payload.toJson()), headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(timeoutDuration);
      var decryptedResponse = '';
      if (response.body.contains("status")) {
        decryptedResponse = response.body;
      } else {
        decryptedResponse =
            decryptAESCryptoJS(response.body.replaceAll("\"", ''));
      }

      //print(          'Response: ${response.statusCode}\nBody: ${jsonDecode(decryptedResponse)}');
      if (response.statusCode == 200) {
        // Convert and return
        return PaymentApiResponse.fromJson(jsonDecode(decryptedResponse));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          var responseData =
              PaymentApiResponse.fromJson(jsonDecode(decryptedResponse));
          // if(response.body.contains("title")){
          // }
          // else{
          //   responseData = ApiResponse.fromJson(jsonDecode(response.body));
          // }
          print('API Exception:${responseData.errors}');
          return APIException(
              responseData is ApiResponse
                  ? responseData.message
                  : (responseData as PaymentApiResponse).message,
              response.statusCode,
              apiErrorCode,
              responseData.errors != null && responseData.errors!.isNotEmpty
                  ? responseData.errors
                  : []);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> checkWalletAccount(String phoneNumber) async {
    final url =
        Uri.parse('${ApplicationData().API_URL}/mtnwallet/createwallet');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      var walletInfo = <String, String>{};
      walletInfo.putIfAbsent('id', () => Uuid().v1());
      walletInfo.putIfAbsent('walletNumber', () => phoneNumber);
      //walletInfo.putIfAbsent('currency', () => "RWF");

      //print(jsonEncode(walletInfo).toString());
      //print(jsonEncode(requestHeaderDto.toJson()));

      response = await client!
          .post(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                'User-Agent': headerEn,
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(walletInfo))
          .timeout(const Duration(seconds: 50));
      //print(          'Response: ${jsonDecode(response.body)}');
      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          // if(response.body.contains("title")){
          // }
          // else{
          //   responseData = ApiResponse.fromJson(jsonDecode(response.body));
          // }
          print('API Exception:${responseData.errors}');
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else if (response.statusCode == 405) {
        return const APIException(
            "Its seems, the thing you're looking for has been moved. Please contact support!",
            0,
            APIError.NOT_FOUND);
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> getDefaultPaymentMethods() async {
    final url = Uri.parse(
        '${ApplicationData().API_URL}/payment/getalldefaultpaymentmethod');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      response = await client!.get(url, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 50));
      print(
          'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
      if (response.statusCode == 200 || response.statusCode == 400) {
        // Convert and return
        return ResponsePaymentMethodDto.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          var responseData =
              ResponsePaymentMethodDto.fromJson(jsonDecode(response.body));
          // if(response.body.contains("title")){
          // }
          // else{
          //   responseData = ApiResponse.fromJson(jsonDecode(response.body));
          // }
          print('API Exception:${responseData.errors}');
          return APIException(
              responseData is ApiResponse
                  ? responseData.message
                  : (responseData as ResponsePaymentMethodDto).message,
              response.statusCode,
              apiErrorCode,
              responseData.errors != null && responseData.errors!.isNotEmpty
                  ? responseData.errors
                  : []);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> getTransactionStatus(String transactionId) async {
    final url = Uri.parse(
        '${ApplicationData().API_URL}/payment/${transactionId}');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
      encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      response = await client!.get(url, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 50));
      print(
          'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
      if (response.statusCode == 200 || response.statusCode == 400) {
        // Convert and return
        return TransactionResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
              ? APIError.UN_AUTHORIZED
              : response.statusCode == 403
              ? APIError.FORBIDDEN
              : response.statusCode == 404
              ? APIError.NOT_FOUND
              : response.statusCode == 500
              ? APIError.INTERNAL_SERVER_ERROR
              : APIError.UN_AVAILABLE;
          var responseData =
          ResponsePaymentMethodDto.fromJson(jsonDecode(response.body));
          // if(response.body.contains("title")){
          // }
          // else{
          //   responseData = ApiResponse.fromJson(jsonDecode(response.body));
          // }
          print('API Exception:${responseData.errors}');
          return APIException(
              responseData is ApiResponse
                  ? responseData.message
                  : (responseData as ResponsePaymentMethodDto).message,
              response.statusCode,
              apiErrorCode,
              responseData.errors != null && responseData.errors!.isNotEmpty
                  ? responseData.errors
                  : []);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  /*
  All Payment API
  */

  void dispose() {
    client!.close();
  }

  Future<dynamic> verificationCompleted(String phoneNumber, bool status) async {
    final url =
        Uri.parse('${ApplicationData().API_URL}/account/verifyphonenumber');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      Map<String, dynamic> phoneVerificationRequest = <String, dynamic>{
        'phoneNumber': phoneNumber,
        'status': status
      };

      print(decryptAESCryptoJS(headerEn));
      print(phoneVerificationRequest.toString());
      response = await client!
          .put(url, body: jsonEncode(phoneVerificationRequest), headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 50));
      //print(          'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> enableTwoFactorAuthentication(
      String phoneNumber, bool status) async {
    final url =
        Uri.parse('${ApplicationData().API_URL}/account/twofactorupdate');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      Map<String, dynamic> phoneVerificationRequest = <String, dynamic>{
        'phoneNumber': phoneNumber,
        'status': status
      };

      print(decryptAESCryptoJS(headerEn));
      print(phoneVerificationRequest.toString());
      response = await client!
          .put(url, body: jsonEncode(phoneVerificationRequest), headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 50));
      //print(          'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> getRecentUsers() async {
    final url = Uri.parse('${ApplicationData().API_URL}/payment/users');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      //print(jsonEncode(addAccountModel.toJson()));

      response = await client!.get(url, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 50));
      //print(          'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
      if (response.statusCode == 200) {
        // Convert and return
        return RecentTransactionModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData =
              RecentTransactionModel.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> syncContacts(List<Contacts> systemContact) async {
    final postContacts = Uri.parse('${ApplicationData().API_URL}/usercontacts');
    //final getContacts = Uri.parse('${ApplicationData().API_URL}/usercontacts');
    // Get user profile for id
    http.Response response;
    print(postContacts);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      String body = jsonEncode(systemContact);
      body = body.replaceAll('Contacts', '');
      List<dynamic> data = jsonDecode(body);

      if (kDebugMode) {
        //log('contacts :${jsonEncode(data)}');
      }
      // response = await client!.post(postContacts,body: jsonEncode(data), headers: {
      //   "content-type": "application/json",
      //   "accept": "application/json",
      //   'User-Agent': headerEn,
      //   'Authorization': 'Bearer $token'
      // });
      var responses =
          await client!.post(postContacts, body: jsonEncode(data), headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 50));
      var errorCode, parsedContactData, responseData;

      if (responses.statusCode == 200) {
        // Convert and return
        print(
            'Success Response: ${responses.statusCode}\nBody: ${responses.body}');
        parsedContactData =
            ContactsResponse.fromJson(jsonDecode(responses.body));
      } else if (responses.statusCode == 400 ||
          responses.statusCode == 401 ||
          responses.statusCode == 403 ||
          responses.statusCode == 404 ||
          responses.statusCode == 503 ||
          responses.statusCode == 500) {
        if (responses.body.isNotEmpty) {
          errorCode = responses.statusCode == 400
              ? APIError.BAD_REQUEST
              : responses.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : responses.statusCode == 403
                      ? APIError.FORBIDDEN
                      : responses.statusCode == 404
                          ? APIError.NOT_FOUND
                          : responses.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;

          // Convert and return
          print(
              'Failure Response: ${responses.statusCode}\nBody: ${responses.body}');
          var responseData =
              ContactsResponse.fromJson(jsonDecode(responses.body));
          parsedContactData = APIException(
              responseData.message, responses.statusCode, errorCode);
        } else {
          print('Response: ${responses.statusCode}\nBody is Empty}');
        }
      } else {
        parsedContactData = const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
      print('Internal Response: ${parsedContactData.toString()}');
      return parsedContactData;
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      log(e.toString());
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> getContacts() async {
    final postContacts = Uri.parse('${ApplicationData().API_URL}/usercontacts');
    //final getContacts = Uri.parse('${ApplicationData().API_URL}/usercontacts');
    // Get user profile for id
    http.Response response;
    print(postContacts);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      if (kDebugMode) {
        //log('contacts :${jsonEncode(data)}');
      }
      // response = await client!.post(postContacts,body: jsonEncode(data), headers: {
      //   "content-type": "application/json",
      //   "accept": "application/json",
      //   'User-Agent': headerEn,
      //   'Authorization': 'Bearer $token'
      // });
      var responses = await client!.get(postContacts, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 50));
      var errorCode, parsedContactData, responseData;

      if (responses.statusCode == 200) {
        // Convert and return
        print(
            'Success Response: ${responses.statusCode}\nBody: ${responses.body}');
        parsedContactData =
            ContactsResponse.fromJson(jsonDecode(responses.body));
      } else if (responses.statusCode == 400 ||
          responses.statusCode == 401 ||
          responses.statusCode == 403 ||
          responses.statusCode == 404 ||
          responses.statusCode == 503 ||
          responses.statusCode == 500) {
        if (responses.body.isNotEmpty) {
          errorCode = responses.statusCode == 400
              ? APIError.BAD_REQUEST
              : responses.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : responses.statusCode == 403
                      ? APIError.FORBIDDEN
                      : responses.statusCode == 404
                          ? APIError.NOT_FOUND
                          : responses.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;

          // Convert and return
          print(
              'Failure Response: ${responses.statusCode}\nBody: ${responses.body}');
          var responseData =
              ContactsResponse.fromJson(jsonDecode(responses.body));
          parsedContactData = APIException(
              responseData.message, responses.statusCode, errorCode);
        } else {
          print('Response: ${responses.statusCode}\nBody is Empty}');
        }
      } else {
        parsedContactData = const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
      print('Internal Response: ${parsedContactData.toString()}');
      return parsedContactData;
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      log(e.toString());
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> getRecentChats({int skip = 0, int pageSize = 20}) async {
    try {
      final url = Uri.parse('${ApplicationData().API_URL}/chat/recent');
      //print(url);
      // Get user profile for id
      http.Response response;

      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      ///var detailsUser = UserDetails.fromJson(jsonDecode(userDetails));

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      Map<String, dynamic> body = <String, dynamic>{
        'skip': skip,
        'pageSize': pageSize,
        'receiver': "0",
      };
      //print(body);
      response = await client!
          .post(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                'User-Agent': headerEn,
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 50));
      print("response received");
      //print("Response: "+response.toString());
      //print('Response: ${response.statusCode}\nBody: ${response.body}');
      if (response.statusCode == 200) {
        // Convert and return
        return RecentChatResponse.fromJson(jsonDecode(response.body));
        //return RecentChatResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          //print("Inside Error");
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        } else {
          print('Error Response: ${response.statusCode}}');
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> getRecentTransaction(
      int page, int pageSize, String startDate, String endDate) async {
    final url = Uri.parse('${ApplicationData().API_URL}/payment/getall');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      Map<String, dynamic> body = <String, dynamic>{
        'skip': page,
        'pageSize': pageSize,
        'fromDate': startDate,
        'toDate': endDate,
      };

      //print(jsonEncode(body));

      response = await client!
          .post(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                'User-Agent': headerEn,
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 50));
      print(
          'Response: ${response.statusCode}\nBody: ${jsonDecode(response.body)}');
      if (response.statusCode == 200) {
        // Convert and return
        return RecentTransactionResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData =
              RecentTransactionResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message!, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } catch (e) {
      print(e);
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> uploadProfilePicture(CroppedFile? profilePhoto) async {
    final profilePicture =
        Uri.parse('${ApplicationData().API_URL}/profile/uploadprofilepicture');

    var request = http.MultipartRequest("PUT", profilePicture);

    var deviceDetails = <String, dynamic>{};
    await DeviceInfo().getDeviceInfo().then((value) {
      deviceDetails = value;
    });

    String token = "";
    await LocalSharedPref().getToken().then((value) {
      token = value;
      print('Token $token');
    });

    RequestHeaderDto requestHeaderDto = RequestHeaderDto(
        deviceDetails['Source'],
        deviceDetails['Device'],
        deviceDetails['Version']);
    String headerEn = encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
    Map<String, String> headers = {'Content-Type': 'application/json'};
    headers.putIfAbsent('User-Agent', () => headerEn);
    headers.putIfAbsent('accept', () => '*/*');
    //'Authorization': 'Bearer $token'
    headers.putIfAbsent('Authorization', () => 'Bearer $token');

    request.headers.addAll(headers);
    try {
      request.files.add(await http.MultipartFile.fromPath(
          'ProfilePicture', profilePhoto!.path));
    } catch (e) {
      debugPrint(e.toString());
    }

    var sendRequest = await request.send().timeout(const Duration(seconds: 50));
    var responses = await http.Response.fromStream(sendRequest);

    var errorCode, parsedApiResponse, responseData;
    print('Response: ${responses.statusCode}\nBody: ${responses.body}');
    if (responses.statusCode == 200) {
      // Convert and return
      parsedApiResponse = ApiResponse.fromJson(jsonDecode(responses.body));
    } else if (responses.statusCode == 400 ||
        responses.statusCode == 401 ||
        responses.statusCode == 403 ||
        responses.statusCode == 404 ||
        responses.statusCode == 503 ||
        responses.statusCode == 500) {
      if (responses.body.isNotEmpty) {
        errorCode = responses.statusCode == 400
            ? APIError.BAD_REQUEST
            : responses.statusCode == 401
                ? APIError.UN_AUTHORIZED
                : responses.statusCode == 403
                    ? APIError.FORBIDDEN
                    : responses.statusCode == 404
                        ? APIError.NOT_FOUND
                        : responses.statusCode == 500
                            ? APIError.INTERNAL_SERVER_ERROR
                            : APIError.UN_AVAILABLE;
        // Convert and return
        responseData = ApiResponse.fromJson(jsonDecode(responses.body));
        parsedApiResponse =
            APIException(responseData.args, responses.statusCode, errorCode);
      }
    } else {
      parsedApiResponse = const APIException(
          "Oop's, something went, please restart application",
          0,
          APIError.NONE);
    }

    return parsedApiResponse;
  }

  Future<dynamic> getAllChats(
      [int skip = 0, int pageSize = 20, String? receiverId]) async {
    try {
      final url = Uri.parse('${ApplicationData().API_URL}/chat/getAll');
      if (kDebugMode) {
        print(url);
      }
      // Get user profile for id
      http.Response response;
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      Map<String, dynamic> body = <String, dynamic>{
        'skip': skip,
        'pageSize': pageSize,
        'receiver': receiverId,
      };
      if (kDebugMode) {
        print(body);
      }
      response = await client!
          .post(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                'User-Agent': headerEn,
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        print("response received");
      }
      //print("Response: "+response.toString());
      if (kDebugMode) {
        print('Response: ${response.statusCode}\nBody: ${response.body}');
      }
      if (response.statusCode == 200) {
        // Convert and return
        return RecentChatResponse.fromJson(jsonDecode(response.body));
        //return RecentChatResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          if (kDebugMode) {
            print("Inside Error");
          }
          var responseData =
              RecentChatResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message,
              response.statusCode,
              apiErrorCode,
              responseData.errors != null && responseData.errors!.isNotEmpty
                  ? responseData.errors
                  : []);
        } else {
          if (kDebugMode) {
            print('Error Response: ${response.statusCode}}');
          }
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> deleteChat(String messageId) async {
    final url =
        Uri.parse('${ApplicationData().API_URL}/chat/delete/$messageId');
    if (kDebugMode) {
      print(url);
    }
    // Get user profile for id
    http.Response response;

    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });
      String userDetails = "";

      await LocalSharedPref().getUserDetails().then((value) {
        userDetails = value;
        if (kDebugMode) {
          print(userDetails);
        }
      });
      //var detailsUser = UserDetails.fromJson(jsonDecode(userDetails));

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      response = await client!.delete(url, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        print("response received");
      }
      //print("Response: "+response.toString());
      if (kDebugMode) {
        print('Response: ${response.statusCode}\nBody: ${response.body}');
      }
      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
        //return RecentChatResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          if (kDebugMode) {
            print("Inside Error");
          }
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        } else {
          if (kDebugMode) {
            print('Error Response: ${response.statusCode}}');
          }
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> uploadFile(String? senderName, File? profilePhoto, String? receiversId) async {
    final profilePicture =
        Uri.parse('${ApplicationData().API_URL}/chat/uploadfile');

    var request = http.MultipartRequest("POST", profilePicture);

    var deviceDetails = <String, dynamic>{};
    await DeviceInfo().getDeviceInfo().then((value) {
      deviceDetails = value;
    });

    String token = "";
    await LocalSharedPref().getToken().then((value) {
      token = value;
      if (kDebugMode) {
        print('Token $token');
      }
    });
    var errorCode, parsedApiResponse, responseData;

    try {
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceDetails['Source'],
          deviceDetails['Device'],
          deviceDetails['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      Map<String, String> headers = {'Content-Type': 'application/json'};
      headers.putIfAbsent('User-Agent', () => headerEn);
      headers.putIfAbsent('accept', () => '*/*');
      //'Authorization': 'Bearer $token'
      headers.putIfAbsent('Authorization', () => 'Bearer $token');

      request.headers.addAll(headers);
      try {
        request.files.add(
            await http.MultipartFile.fromPath('ChatFile', profilePhoto!.path));
      } catch (e) {
        debugPrint(e.toString());
      }
      var fields = <String, String>{};
      fields.putIfAbsent('id', () => Uuid().v1());
      fields.putIfAbsent('Receiver', () => receiversId!);
      fields.putIfAbsent('senderName', () => senderName!);
      request.fields.addAll(fields);

      debugPrint(request.toString());

      var sendRequest =
          await request.send().timeout(const Duration(seconds: 50));
      var responses = await http.Response.fromStream(sendRequest);

      if (kDebugMode) {
        print('Response: ${responses.statusCode}\nBody: ${responses.body}');
      }
      if (responses.statusCode == 200) {
        // Convert and return
        parsedApiResponse =
            FileUploadResponse.fromJson(jsonDecode(responses.body));
      } else if (responses.statusCode == 400 ||
          responses.statusCode == 401 ||
          responses.statusCode == 403 ||
          responses.statusCode == 404 ||
          responses.statusCode == 503 ||
          responses.statusCode == 500) {
        if (responses.body.isNotEmpty) {
          errorCode = responses.statusCode == 400
              ? APIError.BAD_REQUEST
              : responses.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : responses.statusCode == 403
                      ? APIError.FORBIDDEN
                      : responses.statusCode == 404
                          ? APIError.NOT_FOUND
                          : responses.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = ApiResponse.fromJson(jsonDecode(responses.body));
          parsedApiResponse = APIException(
              responseData.message,
              responses.statusCode,
              errorCode,
              responseData.errors != null && responseData.errors!.isNotEmpty
                  ? responseData.errors
                  : []);
        }
      } else {
        parsedApiResponse = const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (_) {
      parsedApiResponse = const APIException(
          "Oop's, something went, please restart application",
          0,
          APIError.NONE);
    }

    return parsedApiResponse;
  }

  Future<dynamic> getAllDiscounts(DiscountRequest request) async {
    final url = Uri.parse('${ApplicationData().API_URL}/discount/getall');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      if (kDebugMode) {
        print(headerEn);
      }
      response = await client!
          .post(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                'User-Agent': headerEn,
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(request.toJson()))
          .timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        print('Response: ${response.statusCode}\nBody: ${response.body}');
      }
      if (response.statusCode == 200) {
        // Convert and return
        return DiscountResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData =
              DiscountResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application.",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> getTransactionSummary(Map<String, dynamic> request) async {
    final url = Uri.parse('${ApplicationData().API_URL}/servicecharge/get');
    // Get user profile for id
    http.Response response;
    print(url);
    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      if (kDebugMode) {
        print(headerEn);
      }
      response = await client!
          .post(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                'User-Agent': headerEn,
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(request))
          .timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        print('Response: ${response.statusCode}\nBody: ${response.body}');
      }
      if (response.statusCode == 200) {
        // Convert and return
        return ServiceApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData =
              ServiceApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application.",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  //region Social Post for User
  //user can create and retrieve posts
  //user can react to it via these api's
  Future<dynamic> getAllSocialPost(
      [int skip = 0,
      int pageSize = 20,
      String? visibility,
      String? sortBy]) async {
    try {
      final url = Uri.parse('${ApplicationData().API_URL}/socialpost/getall');
      if (kDebugMode) {
        print(url);
      }
      // Get user profile for id
      http.Response response;
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });
      String userDetails = "";

      //token = '';

      await LocalSharedPref().getUserDetails().then((value) {
        userDetails = value;
        if (kDebugMode) {
          print(userDetails);
        }
      });
      //var detailsUser = UserDetails.fromJson(jsonDecode(userDetails));

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      Map<String, dynamic> body = <String, dynamic>{
        'skip': skip,
        'pageSize': pageSize,
        'postStatus': visibility,
        'sortValue': sortBy
      };
      if (kDebugMode) {
        print(body);
      }
      response = await client!
          .post(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                'User-Agent': headerEn,
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 50));
      // if (kDebugMode) {
      //   print("response received");
      // }
      //print("Response: "+response.toString());
      // if (kDebugMode) {
      //   print('Response: ${response.statusCode}\nBody: ${response.body}');
      // }
      if (response.statusCode == 200) {
        // Convert and return
        return SocialPostResponse.fromJson(jsonDecode(response.body));
        //return RecentChatResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          // if (kDebugMode) {
          //   print("Inside Error");
          // }
          var responseData =
              SocialPostResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        } else {
          if (kDebugMode) {
            //print('Error Response: ${response.statusCode}}');
            return const APIException(
                "Oop's, something went, please restart application",
                0,
                APIError.NONE);
          }
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> createSocialPost(SocialPostCreate socialPost) async {
    final url = Uri.parse('${ApplicationData().API_URL}/socialpost');
    if (kDebugMode) {
      print(url);
    }
    // Get user profile for id
    http.Response response;

    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });
      String userDetails = "";

      await LocalSharedPref().getUserDetails().then((value) {
        userDetails = value;
        if (kDebugMode) {
          print(userDetails);
        }
      });
      //var detailsUser = UserDetails.fromJson(jsonDecode(userDetails));

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      response = await client!
          .post(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                'User-Agent': headerEn,
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(socialPost.toJSON()))
          .timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        print("response received");
      }
      //print("Response: "+response.toString());
      if (kDebugMode) {
        print('Response: ${response.statusCode}\nBody: ${response.body}');
      }
      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
        //return RecentChatResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          if (kDebugMode) {
            print("Inside Error");
          }
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        } else {
          if (kDebugMode) {
            print('Error Response: ${response.statusCode}}');
          }
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> socialPostReact(SocialPostReactionRequest socialPost) async {
    final url = Uri.parse('${ApplicationData().API_URL}/socialinteraction');
    if (kDebugMode) {
      print(url);
    }
    // Get user profile for id
    http.Response response;

    try {
      String token = "";
      await LocalSharedPref().getToken().then((value) {
        token = value;
      });

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });
      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      print(jsonEncode(socialPost.toJSON()));

      response = await client!
          .post(url,
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                'User-Agent': headerEn,
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(socialPost.toJSON()))
          .timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        print("response received");
      }
      //print("Response: "+response.toString());
      if (kDebugMode) {
        print('Response: ${response.statusCode}\nBody: ${response.body}');
      }
      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
        //return RecentChatResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          if (kDebugMode) {
            print("Inside Error");
          }
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        } else {
          if (kDebugMode) {
            print('Error Response: ${response.statusCode}}');
          }
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> logout(String userId) async {
    // final url = Uri.parse('${ApplicationData().API_URL}/socialinteraction');
    // if (kDebugMode) {
    //   print(url);
    // }
    // Get user profile for id

    try {

      http.Response response;

      String token = await LocalSharedPref().getToken();

      var deviceInfo = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {
        deviceInfo = value;
      });

      final url =
      Uri.parse('${ApplicationData().API_URL}/account/logout?userID=$userId');
      if (kDebugMode) {
        print(url);
      }

      RequestHeaderDto requestHeaderDto = RequestHeaderDto(
          deviceInfo['Source'], deviceInfo['Device'], deviceInfo['Version']);
      String headerEn = encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));

      //print(jsonEncode(socialPost.toJSON()));

      response = await client!.get(url, headers: {
        "content-type": "application/json",
        "accept": "application/json",
        'User-Agent': headerEn,
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 50));
      if (kDebugMode) {
        print("response received");
      }
      //print("Response: "+response.toString());
      if (kDebugMode) {
        print('Response: ${response.statusCode}\nBody: ${response.body}');
      }
      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
        //return RecentChatResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
              ? APIError.UN_AUTHORIZED
              : response.statusCode == 403
              ? APIError.FORBIDDEN
              : response.statusCode == 404
              ? APIError.NOT_FOUND
              : response.statusCode == 500
              ? APIError.INTERNAL_SERVER_ERROR
              : APIError.UN_AVAILABLE;
          // Convert and return
          if (kDebugMode) {
            print("Inside Error");
          }
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message, response.statusCode, apiErrorCode);
        } else {
          if (kDebugMode) {
            print('Error Response: ${response.statusCode}}');
          }
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }

    }on TimeoutException catch (_){
      return const APIException('The request timed-out, Please check your internet connection'
          , 0, APIError.SYSTEM_ERROR);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

  Future<dynamic> updateUserProfile(ProfileDetailsResponse? profileDetails) async {
    try {



      //final url = Uri.parse('${ApplicationData().API_URL}/Profile');

      String accesstoken = await LocalSharedPref().getToken();

      Map<String, dynamic> tokenDecoded = JWTHelper().decodeJwt(accesstoken);
      String userID = tokenDecoded[
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
      final url = Uri.parse('${ApplicationData().API_URL}/Profile/$userID');
      var request = http.MultipartRequest("PUT", url);


      //registerModel.setConfirmPassword(registerModel.password);
      var token = <String, dynamic>{};
      await DeviceInfo().getDeviceInfo().then((value) {

        token = value;
      });
      RequestHeaderDto requestHeaderDto =
          RequestHeaderDto(token['Source'], token['Device'], token['Version']);
      String headerEn =
          encryptAESCryptoJS(jsonEncode(requestHeaderDto.toJson()));
      Map<String, String> headers = {'Content-Type': 'application/json'};
      headers.putIfAbsent('User-Agent', () => headerEn);
      headers.putIfAbsent('accept', () => 'application/json');
      headers.putIfAbsent('Authorization', () => 'Bearer $accesstoken');
      //debugPrint(jsonEncode(profileDetails.toJson()));
      request.headers.addAll(headers);
      Map<String, dynamic> data = profileDetails!.toUpdateJson();
      Map<String, String> register = data.cast<String, String>();
      request.fields.addAll(register);

      // request.fields.addAll(registerModel.toJson());

      var sendRequest =
          await request.send().timeout(const Duration(seconds: 40));
      var response = await http.Response.fromStream(sendRequest);

      if (kDebugMode) {
        print('${response.body}\n Status Code: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        // Convert and return
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 503 ||
          response.statusCode == 500) {
        if (response.body.isNotEmpty) {
          var apiErrorCode = response.statusCode == 400
              ? APIError.BAD_REQUEST
              : response.statusCode == 401
                  ? APIError.UN_AUTHORIZED
                  : response.statusCode == 403
                      ? APIError.FORBIDDEN
                      : response.statusCode == 404
                          ? APIError.NOT_FOUND
                          : response.statusCode == 500
                              ? APIError.INTERNAL_SERVER_ERROR
                              : APIError.UN_AVAILABLE;
          // Convert and return
          var responseData = ApiResponse.fromJson(jsonDecode(response.body));
          return APIException(
              responseData.message,
              response.statusCode,
              apiErrorCode,
              responseData.errors != null && responseData.errors!.isNotEmpty
                  ? responseData.errors
                  : []);
        } else if (response.statusCode == 500) {
          return APIException("Internal Server Error, Please contact support",
              response.statusCode, APIError.INTERNAL_SERVER_ERROR);
        }
      } else {
        return const APIException(
            "Oop's, something went, please restart application",
            0,
            APIError.NONE);
      }
    } on TimeoutException catch (_) {
      return const APIException(
          'The request timed-out, Please check your internet connection',
          0,
          APIError.SYSTEM_ERROR);
    } catch (e) {
      return APIException(e.toString(), 0, APIError.SYSTEM_ERROR);
    }
  }

//endregion
}
