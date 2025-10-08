import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/crypto/encryption.dart';
import 'package:lipa_quick/core/local_db/repository/payment_reposiroty_impl.dart';
import 'package:lipa_quick/core/managers/language/language_bloc.dart';
import 'package:lipa_quick/core/models/IdentityResponse.dart';
import 'package:lipa_quick/core/models/accounts/add_account_model.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/cards/add_card_model.dart';
import 'package:lipa_quick/core/models/change_password_model.dart';
import 'package:lipa_quick/core/models/payment/payment.dart';
import 'package:lipa_quick/core/models/payment/paymentresponse.dart';
import 'package:lipa_quick/core/models/payment/user_payment_methods.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';
import 'package:lipa_quick/core/models/profile/profile_item_model.dart';
import 'package:lipa_quick/core/models/profile/profile_list_reponse.dart';
import 'package:lipa_quick/core/models/requests.dart';
import 'package:lipa_quick/core/models/reset_password_request.dart';
import 'package:lipa_quick/core/models/resgister_steps_data.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/models/user.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/utils/jwt_utils.dart';
import 'package:lipa_quick/core/view_models/appsettings_viewmodel.dart';
import 'package:lipa_quick/core/view_models/base_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/views/user_profile/customer_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../models/banks/bank_details.dart';
import '../models/banks/bank_response.dart';
import 'package:http/http.dart' as http;

import '../models/password_login.dart';

class AccountViewModel extends BaseModel {
  final Api _api = locator<Api>();
  String errorMessage = "";

  Future<IdentityResponse?> getAccounts() async {
    setState(ViewState.Loading);
    var response = await _api.getIdentity();
    if (response == null) {
      errorMessage = "Oops, something went wrong, please try again";
      setState(ViewState.Idle);
      return null;
    } else if (response != null && response is IdentityResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = response.message!;
          setState(ViewState.Idle);
          return response;
        }
      }
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic> getUserId() async {
    setState(ViewState.Loading);
    String token = "";
    await LocalSharedPref().getToken().then((value) {
      token = value;
    });
    Map<String, dynamic> tokenDecoded = JWTHelper().decodeJwt(token);
    String userID = tokenDecoded[
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
    debugPrint('USER ID = $userID');
    setState(ViewState.Idle);
    return userID;
  }

  Future<dynamic> getUserDetails() async {
    setState(ViewState.Loading);
    var response = await _api.getUserProfile();
    debugPrint((response.toString()));
    if (response != null && response is ProfileListResponse) {
      if (!response.status!) {
        debugPrint('API Response False');
        if (response.errorMessage!.isNotEmpty) {
          errorMessage = response.errorMessage!;
          setState(ViewState.Empty_Data);
          return response;
        }
      }
    }

    if (response is APIException) {
      //debugPrint('API Exception');
      setState(getViewState(response));
      return response;
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic> getLocalUserDetails() async {
    var prefs = await SharedPreferences.getInstance();
    //print('Checking User Details ${prefs.getString('userDetails')}');
    // print('Null Preference, Loading Default EN');
    String rawData = prefs.getString("userDetails")!;
    //print('Raw Data Print: $rawData');
    var data = jsonDecode(rawData);
    //print('JSON Decode Data Print: $data');
    //print(data);
    ProfileListResponse profileListResponse = ProfileListResponse.fromJson(data);
    return profileListResponse;
  }

  Future<bool> isUserActive({String? userPhoneNumber}) async {
    LocalSharedPref localSharedPref = await LocalSharedPref();
    var details  = await localSharedPref.getUserDetails();
    UserDetails detail = UserDetails.fromJson(jsonDecode(details));
    if(userPhoneNumber != null){
      if(detail.active){
        if(detail.phoneNumber == userPhoneNumber){
          return false;
        }
      }
    }
    return detail.active;
  }

  Future<List<ProfileItemModels>> getDynamicProfile(
      BuildContext context) async {
    setState(ViewState.Loading);
    var profilePageItems = <ProfileItemModels>[];
    final l10n = AppLocalizations.of(context)!;
    profilePageItems.add(ProfileItemModels(
        1,
        0xFFE0FFF0,
        0xFF3BB143,
        Icons.currency_exchange,
        l10n.nav_profile_transactions,
        l10n.nav_profile_transactions_hint));
    profilePageItems.add(ProfileItemModels(
        2,
        0xFFE0FFF0,
        0xFF3BB143,
        Icons.account_balance,
        l10n.nav_profile_accounts,
        l10n.nav_profile_accounts_hint));
    profilePageItems.add(ProfileItemModels(
        3,
        0xFFE0FFF0,
        0xFF3BB143,
        Icons.credit_card,
        l10n.nav_profile_cards,
        l10n.nav_profile_cards_hint));
    profilePageItems.add(ProfileItemModels(4, 0xFFE0FDFF, 0xFF33CBD5,
        Icons.lock, l10n.nav_profile_privacy, l10n.nav_profile_privacy_hint));
    profilePageItems.add(ProfileItemModels(5, 0xFFF1E0FF, 0xFFBD66F2,
        Icons.wallet, l10n.nav_profile_payment, l10n.nav_profile_payment_hint));
    // profilePageItems.add(ProfileItemModels(
    //     6,
    //     0xFFFFFCE0,
    //     0xFFFFD233,
    //     Icons.notifications,
    //     l10n.nav_profile_notification,
    //     l10n.nav_profile_notification_hint));
    profilePageItems.add(ProfileItemModels(
        7,
        0xFFFFE0E0,
        0xFFFF9790,
        Icons.exit_to_app_rounded,
        l10n.nav_profile_logout,
        l10n.nav_profile_logout_hint));
    setState(ViewState.Idle);
    return profilePageItems;
  }

  Future<List<ProfileItemModels>> getPrivacyList() async {
    setState(ViewState.Loading);
    var profilePageItems = <ProfileItemModels>[];
    profilePageItems.add(ProfileItemModels(1, 0xFFE0FFF0, 0xFF3BB143,
        Icons.person, 'Profile Details', 'View your personal details here.'));
    profilePageItems.add(ProfileItemModels(
        2,
        0xFFE0FFF0,
        0xFF3BB143,
        Icons.password,
        'Change Password',
        'Update your account password here.'));
    setState(ViewState.Idle);
    return profilePageItems;
  }

  Future<IdentityResponse?> getIdentity() async {
    setState(ViewState.Loading);
    var response = await _api.getIdentity();
    if (response == null) {
      errorMessage = "Oops, something went wrong, please try again";
      setState(ViewState.Idle);
      return null;
    } else if (response != null && response is APIException) {
      errorMessage = response.message!;
      setState(ViewState.Idle);
      return null;
    }else if (response != null && response is IdentityResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = response.message!;
          setState(ViewState.Idle);
          return response;
        }
      }
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<BankListResponse?> getServicableBanks() async {
    setState(ViewState.Loading);
    var banks = <BankDetails>[];
    banks.add(BankDetails(id: "1", name: "Eco\nBank", logo: ""));
    banks.add(BankDetails(id: "2", name: "Bank of\nKigali", logo: ""));
    banks.add(BankDetails(id: "3", name: "Equity\nBank", logo: ""));
    banks.add(BankDetails(id: "4", name: "BPR\nRwanda", logo: ""));
    var response = BankListResponse(status: true, message: "", data: banks);
    // var response = await _api.getIdentity();
    // if(response == null){
    //   errorMessage = "Oops, something went wrong, please try again";
    //   setState(ViewState.Idle);
    //   return null;
    // }else if(response != null && response is IdentityResponse){
    //   if(!response.status!){
    //     if(response.message!.isNotEmpty) {
    //       errorMessage = response.message!;
    //       setState(ViewState.Idle);
    //       return response;
    //     }
    //   }
    // }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic> login(LoginRequest model) async {
    setState(ViewState.Loading);
    var token = await LocalSharedPref().getFcmToken();
    var oldToken = await LocalSharedPref().getOldFcmToken();
    var response =
        await _api.login(model, fcmToken: token, oldFcmToken: oldToken);
    if (response != null && response is LoginApiResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = response.message!;
          setState(ViewState.Idle);
          return response;
        }
      }
      // if(response.userData!.twoFactorEnabled){
      //   var isPinCreated = await locator<AppSettingsViewModel>().checkPin(response.userData!.id);
      //   if(!isPinCreated) {
      //     await LocalSharedPref().setTwoFactor(false);
      //   }
      // }


    } else if (response is APIException) {
      return response;
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic> registerUser(List<TextEditingController> controllers,
      RegisterStep? registerStep, CountryCode countryCode) async {
    setState(ViewState.Loading);
    UserDetailsModel model = UserDetailsModel.initial();
    model.firstName = registerStep!.firstName!;
    model.lastName = registerStep.secondName!;
    model.dateOfBirth = registerStep.dob!;
    //debugPrint(registerStep.gender!.name.toString());
    model.gender = registerStep.gender!.name.toString();
    model.idNumber = registerStep.IdNumber!;
    model.idType = registerStep.details!.id!;
    model.street = registerStep.street!;
    model.city = registerStep.city!;
    model.state = registerStep.state!;
    model.country = registerStep.country!;

    model.email = controllers[0].text;
    model.phoneNumber =
        '${countryCode.dialCode.toString().substring(1)}${controllers[1].text}';
    //model.phoneNumber = controllers[1].text;
    model.inviteCode = controllers[4].text;
    //debugPrint(controllers[4].text);
    var passwordDto = PasswordDto(controllers[2].text,
        DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));
    String encryptedPassword = encryptAESCryptoJS(jsonEncode(passwordDto));
    //details['password'] = encryptedPassword
    model.password = encryptedPassword;
    model.confirmPassword = encryptedPassword;

    var response =
        await _api.registerUser(model, registerStep.details!.identityPhoto!);
    if (response != null && response is RegisterApiResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = (response.errors != null
              ? getErrorMessage(response.errors!):response.message)!;
          setState(ViewState.Idle);
          return response;
        }
      } else {}
    } else if (response is APIException) {
      print('API Exception ${response.toString()}');
      errorMessage = (response.errors != null && response.errors!.isNotEmpty
          ? getErrorMessage(response.errors!):response.message)!;
      return response;
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic?> AddAccount(AddAccountModel? accountModel) async {
    setState(ViewState.Loading);
    if (accountModel == null) {
      errorMessage = "Oops, something went wrong, please try again";
      setState(ViewState.Idle);
      return null;
    }
    var response = await _api.addAccount(accountModel);
    if (response == null) {
      errorMessage = "Oops, something went wrong, please try again";
      setState(ViewState.Idle);
      return null;
    } else if (response != null && response is APIException) {
      if (response.message!.isNotEmpty) {
        //print("Add Account Error Message: ${(response.errors != null && response.errors!.isNotEmpty)}");
        errorMessage = ((response.errors != null && response.errors!.isNotEmpty))
            ? getErrorMessage(response.errors!):response.message!;
        //print("Add Account Error Message: $errorMessage");
        setState(ViewState.Idle);
        return response;
      }
    }else if (response != null && response is ApiResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = response.message!;
          setState(ViewState.Idle);
          return response;
        }
      }
    }

    try{
      PaymentMethodsRepositoryImpl impl = locator<PaymentMethodsRepositoryImpl>();
      //Check if Payment Methods Added in the System:
      await impl.getAllUserPaymentMethods().then((value) => {
        impl.insertUserPaymentMethod(UserPaymentMethods.bankAccount(
            const Uuid().v1(),
            'Bank Account',
            accountModel.bank,
            accountModel.swiftCode,
            accountModel.accountNumber,
            accountModel.accountHolderName,
            value.isEmpty)),
      });
    }catch(e){
      //debugPrint(e.toString());
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic?> UpdateProfileImage(CroppedFile? file) async {
    setState(ViewState.Loading);
    if (file == null) {
      errorMessage = "Oops, something went wrong, please try again";
      setState(ViewState.Idle);
      return null;
    }
    var response = await _api.uploadProfilePicture(file);
    if (response == null) {
      errorMessage = "Oops, something went wrong, please try again";
      setState(ViewState.Idle);
      return null;
    } else if (response != null && response is ApiResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = response.message!;
          setState(ViewState.Idle);
          return response;
        }
      }
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic> AddCard(AddCardModel? accountModel) async {
    setState(ViewState.Loading);
    if (accountModel == null) {
      errorMessage = "Oops, something went wrong, please try again";
      setState(ViewState.Idle);
      return null;
    }
    var response = await _api.addCards(accountModel);
    if (response == null) {
      errorMessage = "Oops, something went wrong, please try again";
      setState(ViewState.Idle);
      return null;
    } else if (response != null && response is ApiResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = (response.errors != null
              ? getErrorMessage(response.errors!):response.message)!;
          return response;
        }
      }
    }else if(response is APIException){
      errorMessage = (response.errors != null
          ? getErrorMessage(response.errors!):response.message)!;
      return response;
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic> changePassword(String currentPassword, String newPassword,
      String newConfirmPassword) async {
    setState(ViewState.Loading);

    var response = await _api.changePassword(ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: newConfirmPassword));
    if (response == null) {
      errorMessage = "Oops, something went wrong, please try again";
      setState(ViewState.Idle);
      return null;
    } else if (response != null && response is ChangePasswordResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = response.message!;
          return response;
        }
      }
    } else if (response is APIException) {
      return response;
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic> forgotPassword(String phoneNumber, String newPassword,
      String newConfirmPassword) async {
    setState(ViewState.Loading);
    phoneNumber = phoneNumber.substring(1);
    var response = await _api.forgotPassword(ResetPasswordRequest(
        phoneNumber: phoneNumber,
        newPassword: newPassword,
        confirmPassword: newConfirmPassword));
    if (response == null) {
      errorMessage = "Oops, something went wrong, please try again";
      setState(ViewState.Idle);
      return null;
    } else if (response != null && response is ChangePasswordResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = response.message!;
          return response;
        }
      }
    } else if (response is APIException) {
      if(response.errors != null){
        errorMessage = getErrorMessage(response.errors!);
      }
      return response;
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic> searchContacts(String query, BuildContext context) async {
    setState(ViewState.Loading);
    // var dialCode =
    // context.read<LanguageBloc>().state.selectedLanguage.dialCode!.toString().substring(1);
    var response = await _api.searchContacts('$query');
    if (response != null && response is RegisterApiResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = response.message!;
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

  Future<dynamic> pay(PaymentRequest? addAccountModel) async {
    setState(ViewState.Loading);
    //addAccountModel!.sender!.senderPhoneNumber = '25078473467';
    //addAccountModel!.receiver!.receiverPhoneNumber = '250785247186';

    var response = await _api.sendpayment(addAccountModel!);
    if (response != null && response is PaymentApiResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = response.message!;
          setState(ViewState.Idle);
          return response;
        }
      }
    } else if (response is APIException) {
      //debugPrint(response.errors.toString());
      errorMessage = (response.errors != null && response.errors!.isNotEmpty)
          ? getErrorMessage(response.errors!)
          : response.message!;
      //debugPrint(errorMessage);
      setState(ViewState.Error);
      return response;
    }
    setState(ViewState.Idle);
    return response;
  }

  Future<dynamic> getRecentUserTransaction() async {
    setState(ViewState.Loading);
    var response = await _api.getRecentUsers();
    if (response != null && response is RegisterApiResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = response.message!;
          setState(ViewState.Idle);
          return response;
        }
      } else {}
    } else if (response is APIException) {
      return response;
    }
    setState(ViewState.Idle);
    return response;
  }

  String getErrorMessage(List<String> errors) {
    var buffer = StringBuffer();
    for (var i = 0; i < errors.length; i++) {
      buffer.write('${(i + 1)}. ${errors[i]}\n');
    }
    return buffer.toString();
  }

  ViewState getViewState(APIException response) {
    ViewState viewState;
    switch(response.statusCode!){
      case 400:
        viewState = ViewState.Empty_Data;
        break;
      case 404:
        viewState = ViewState.Authorization_Failed;
        break;
      default:
        viewState = ViewState.Error;
        break;
    }
    return viewState;
  }

  Future<dynamic> logout() async {
    setState(ViewState.Loading);
    String userId = await getUserId();
    var response = await _api.logout(userId);
    if (response != null && response is ApiResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = response.message!;
          setState(ViewState.Idle);
          //return response;
        }
      } else {}
    } else if (response is APIException) {
      //return response;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userDetails');
    prefs.remove('login');

    setState(ViewState.Idle);
    return response;
  }

  updateUserProfile(ProfileDetailsResponse? profileDetails) async {
    setState(ViewState.Loading);
    var response =
        await _api.updateUserProfile(profileDetails);
    if (response != null && response is ApiResponse) {
      if (!response.status!) {
        if (response.message!.isNotEmpty) {
          errorMessage = (response.errors != null
              ? getErrorMessage(response.errors!):response.message)!;
          setState(ViewState.Idle);
          return response;
        }
      } else {}
    } else if (response is APIException) {
      print('API Exception ${response.toString()}');
      errorMessage = (response.errors != null && response.errors!.isNotEmpty
          ? getErrorMessage(response.errors!):response.message)!;
      return response;
    }
    setState(ViewState.Idle);
    return response;
  }
}
