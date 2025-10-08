import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';
import 'package:lipa_quick/core/models/profile/profile_item_model.dart';
import 'package:lipa_quick/core/models/profile/profile_list_reponse.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/ui/AppColorBuilder.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/shared/image_util.dart';
import 'package:lipa_quick/ui/views/add_account/banks/bank_list.dart';
import 'package:lipa_quick/ui/views/add_account/account_list/list_account.dart';
import 'package:lipa_quick/ui/views/cards/add_card.dart';
import 'package:lipa_quick/ui/views/cards/card_list/card_list_account.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/views/payment/payment_methods/list_default_methods.dart';
import 'package:lipa_quick/ui/views/payment/transaction_history.dart';
import 'package:lipa_quick/ui/views/privacy/privacy_page.dart';
import 'package:lipa_quick/ui/views/qrcode/barcode_scanner_window.dart';
import 'package:lipa_quick/ui/views/settings/payments/payments_methods.dart';
import 'package:lipa_quick/ui/views/user_profile/show_qr_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/app_states.dart';
import '../../../core/models/user.dart';
import '../../../core/view_models/accounts_viewmodel.dart';
import '../../base_view.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const ProfilePage());
  }

  const ProfilePage({Key? key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late SharedPreferences sharedPreferences;
  var userModel = ProfileDetailsResponse.init();
  var dynamicProfileItems = <ProfileItemModels>[];

  Future<bool> _onBackPressed(bool canPop) {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(true);

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    var buttonStyle = ButtonStyle(
        shape: WidgetStateProperty.all(const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)))),
        backgroundColor: WidgetStateProperty.all(Colors.white),
        padding: WidgetStateProperty.all(EdgeInsets.all(12)));
    return BaseView<AccountViewModel>(
        builder: (BuildContext context, AccountViewModel model, Widget? child) {
          //print('ViewState:${model.state.name}');
          if(model.state == ViewState.Idle || model.state == ViewState.Loading){
            return PopScope(onPopInvoked: _onBackPressed, child: Scaffold(
              appBar: AppTheme.getAppBar(
                  context: context, title: "", subTitle: "", enableBack: true),
              body: Stack(
                children: [
                  SafeArea(
                    child: Visibility(
                      visible: model.state == ViewState.Idle,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const SizedBox(height: 20),
                            Stack(
                              alignment: const Alignment(1, 1),
                              children: [
                                ClipRRect(
                                  child: userModel.profilePicture != null &&
                                      userModel.profilePicture.isNotEmpty
                                      ? ImageUtil().imageFromBase64String(
                                      userModel.getProfilePictureLogo(),
                                      MediaQuery.of(context).size.width / 3.2,
                                      MediaQuery.of(context).size.width / 3.2)
                                      : const Icon(Icons.question_mark),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width / 3.2),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 10,
                                  decoration: const BoxDecoration(
                                      color: appGreen300, shape: BoxShape.circle),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: appSurfaceWhite,
                                    ),
                                    onPressed: () {
                                      showImagePickerAndCrop(model);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${userModel.firstName} ${userModel.lastName}',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 21,
                                  color: appSurfaceBlack),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => BarcodePage(),
                                      ),
                                    );
                                  },
                                  style: buttonStyle,
                                  label: Text(
                                    'Scan QR',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17,
                                        color: appSurfaceBlack),
                                  ),
                                  icon: const Icon(Icons.qr_code_scanner_rounded,
                                      color: appGreen400),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => {
                                    //_dialogBuilder(context, )
                                    Navigator.of(context)
                                        .push(_showQrDialog(userModel))
                                  },
                                  style: buttonStyle,
                                  label: Text(
                                    'My QR',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: appSurfaceBlack),
                                  ),
                                  icon: const Icon(Icons.qr_code_scanner_rounded,
                                      color: appGreen400),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Flexible(
                                flex: 1,
                                child: _getProfileListView(dynamicProfileItems))
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Visibility(
                        visible: model.state == ViewState.Loading,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: Container(
                              width: 30,
                              height: 30,
                              child: const CircularProgressIndicator(),
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: appSurfaceWhite,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: appBackgroundBlack200,
                              borderRadius: BorderRadius.circular(8)),
                        )),
                  )
                ],
              ),
            ));
          }else{
            if(model.state == ViewState.Empty_Data){
              return EmptyViewFailedWidget(title: 'Profile'
                  , message: 'Its seems something is broken, please check back again after some time.'
                  , icon: Icons.error_outlined,buttonHint: "OK", callback: (){
                Navigator.of(context).pop();
                });
            }
            else{
              return AuthorizationFailedWidget(callback: () async {
                // LocalSharedPref().clearLoginDetails().then((value) => {
                //   Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage())
                //       , (Route<dynamic> route) => false)
                // });
                //await LocalSharedPref().clearLoginDetails();
                goToLoginPage(context);
              });
            }
          }
    }, onModelReady: (model) {
      model.getUserDetails().then((itemValue) => {
            model.getDynamicProfile(context).then((value) => {
                  dynamicProfileItems = value,
                  if (itemValue is ProfileListResponse)
                    {
                      userModel = itemValue.profileDetails!,
                      print('${userModel.toJson()}'),
                      LocalSharedPref().setUserDetails(jsonEncode(userModel.toJson())),
                    }
                  else if (itemValue is APIException)
                    {
                      //print('API Exception '+itemValue.apiError.value.toString()),
                      setState(() {
                        model.setState(model.getViewState(itemValue));
                      }),
                    }
                })
          });
    });
  }

  Route _showQrDialog(ProfileDetailsResponse qrCode) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ShowQrCodeScreen(qrCode),
      fullscreenDialog: true,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _showErrorDialog(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      fullscreenDialog: true,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Widget _getProfileListView(List<ProfileItemModels>? data) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: data!.length,
        itemBuilder: (context, index) {
          //print('Build List Item${_tile(data[index]).title}');
          return GestureDetector(
            onTap: () {
              onListItemTap(data[index]);
            },
            child: Card(
              child: _tile(data[index]),
              color: Colors.white,
            ),
          );
        });
  }

  ListTile _tile(ProfileItemModels models) => ListTile(
        dense: true,
        title: Text(models.title,
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
        subtitle: Text(models.subTitle,
            style:
                GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400)),
        leading: Container(
          decoration: BoxDecoration(
              color: Color(models.parentColorCode),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          padding: const EdgeInsets.all(10),
          child: Icon(
            models.icon,
            color: Color(models.iconColorCode),
          ),
        ),
      );

  onListItemTap(ProfileItemModels models) {
    //print(models.itemId);
    switch (models.itemId) {
      case 1:
        // Navigator.pushNamed(
        //     context, '/profile/transactions');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TransactionListPage(),
                settings: const RouteSettings(name: 'Transaction')));
        break;
      case 2:
        print("This is called with a click");
        // Navigator.pushNamed(
        //     context, '/profile/account');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AccountListPage(),
                settings: const RouteSettings(name: 'ListAccount')));
        break;
      case 3:
        // Navigator.pushNamed(
        //     context, '/profile/card');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CardListPage(),
                settings: const RouteSettings(name: 'Credit_Debit_Card')));
        break;
      case 4:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PrivacyPage(userModel),
                settings: const RouteSettings(name: 'PrivacyPage')));
        break;
      case 5:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DefaultPaymentListPage(showAppBar: true, voidCallback: (dynamic data){

                },),
                settings: const RouteSettings(name: 'PaymentMethodsPage')));
        break;
      case 7:
        performLogout(context);
        break;
    }
  }

  void performLogout(BuildContext buildContext) {

    CustomDialog(DialogType.SUCCESS).buildAndShowDialog(
        context: buildContext,
        cancellable: true,
        title: AppLocalizations.of(context)!.logout_title,
        message: AppLocalizations.of(context)!.logout_msg,
        buttonPositive: AppLocalizations.of(context)!.btn_yes,
        buttonNegative: AppLocalizations.of(context)!.btn_no,
        onPositivePressed: () async {
          showDialogLoading();
        },
        onNegativePressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        });
  }

  Future<void> showImagePickerAndCrop([AccountViewModel? model]) async {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
        imageQuality: 25
    );
    if (image != null) {
      _cropImage(image, model);
    }
  }

  Future<void> _cropImage(XFile _pickedFile, [AccountViewModel? model]) async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 60,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: appGreen400,
              statusBarColor: appGreen400,
              activeControlsWidgetColor: appGreen400,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              hideBottomControls: true,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedFile != null) {
        var response = await model?.UpdateProfileImage(croppedFile);
        if (response is ApiResponse) {
          var apiResponse = response as ApiResponse;
          if (apiResponse.status!) {
            var dialog = CustomDialog(DialogType.SUCCESS);
            dialog.buildAndShowDialog(
                context: context,
                title: 'User Profile',
                message: apiResponse.message,
                onPositivePressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  model?.getUserDetails().then((value) => {
                        userModel =
                            (value as ProfileListResponse).profileDetails!,
                        LocalSharedPref()
                            .setUserDetails(jsonEncode(userModel.toJson())),
                      });
                },
                buttonPositive: 'OK');
          }
        } else if (response is APIException) {
          var apiResponse = response as APIException;
          var dialog = CustomDialog(DialogType.FAILURE);
          dialog.buildAndShowDialog(
              context: context,
              title: 'User Profile',
              message: apiResponse.message,
              onPositivePressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              buttonPositive: 'OK');
        }
      }
    }
  }

  void showDialogLoading() {
    Navigator.of(context, rootNavigator: true).pop();
    goToLoginPage(context);
  }
}
