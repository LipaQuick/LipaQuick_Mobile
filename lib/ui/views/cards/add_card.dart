import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/cards/add_card_model.dart';
import 'package:lipa_quick/core/services/local_shared_pref.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/ui/base_view.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/date_picker.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/views/cards/card_formatters.dart';
import 'package:lipa_quick/ui/views/dashboard/dashboard_page.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_states.dart';
import '../../shared/app_colors.dart';
import '../../shared/dialogs/dialogshelper.dart';
import '../../shared/text_styles.dart';
import '../../shared/ui_helpers.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_loading.dart';

class AddCardPage extends StatefulWidget {

  bool? goToHome = false;
  AddCardPage({Key? key, this.goToHome}) : super(key: key);

  @override
  AddCardPageState createState() => AddCardPageState();
}

class AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> controllers =
      List.generate(4, (index) => TextEditingController());
  late AccountViewModel model;
  String? validTillDate;
  late DatePickerWidget datePickerWidget;

  var isGoBack = false;
  var isChecked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var element in controllers) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
        fixedSize: const Size.fromHeight(45));
    datePickerWidget = DatePickerWidget(
        restorationId: "Valid Till",
        hint: "Valid Till",
        format: DateFormat('MM/yyyy'),
        isCreditDebitCardDate: true,
        onChanged: (value) {
          setState(() {
            validTillDate = value;
          });

        });

    return BaseView<AccountViewModel>(builder:
        (BuildContext buildContext, AccountViewModel model, Widget? child) {

      return Scaffold(
          appBar: AppTheme.getAppBar(
              title: AppLocalizations.of(context)!.add_card_title,
              subTitle: "",
              enableBack: true,
              context: buildContext),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                const SizedBox(height: 20),
                                FormFields(
                                  controllers,
                                  AppLocalizations.of(context)!.card_number_hint,
                                  0,
                                  isCardNumber: true,
                                  errorMessageFirst: AppLocalizations.of(context)!
                                      .validation_hint(
                                      AppLocalizations.of(context)!
                                          .card_number_hint),
                                  errorMessageSecond:
                                  AppLocalizations.of(context)!
                                      .validation_format_hint(
                                      AppLocalizations.of(context)!
                                          .card_number_hint),
                                ),
                                FormFields(
                                    controllers,
                                    AppLocalizations.of(context)!
                                        .re_enter_card_number,
                                    1,
                                    isCardNumber: true,
                                    errorMessageFirst:
                                    AppLocalizations.of(context)!
                                        .validation_hint(
                                        AppLocalizations.of(context)!
                                            .card_number_hint),
                                    errorMessageSecond:
                                    AppLocalizations.of(context)!
                                        .validation_format_hint(
                                        AppLocalizations.of(context)!
                                            .re_enter_card_number)),
                                FormFields(
                                    controllers,
                                    AppLocalizations.of(context)!
                                        .card_holder_name_hint,
                                    2,
                                    errorMessageFirst:
                                    AppLocalizations.of(context)!
                                        .validation_hint(
                                        AppLocalizations.of(context)!
                                            .card_holder_name_hint)),
                                FormFields(
                                  controllers,
                                  AppLocalizations.of(context)!.cvc_cvv_hint,
                                  3,
                                  isCVVCode: true,
                                  errorMessageFirst: AppLocalizations.of(context)!
                                      .validation_hint(
                                      AppLocalizations.of(context)!
                                          .cvc_cvv_hint),
                                  errorMessageSecond:
                                  AppLocalizations.of(context)!
                                      .validation_format_hint(
                                      AppLocalizations.of(context)!
                                          .cvc_cvv_hint),
                                ),
                                datePickerWidget,
                                Row(
                                  children: [
                                    Checkbox(
                                        fillColor: MaterialStateProperty.resolveWith(getColor),
                                        value: isChecked, onChanged: (bool? value){
                                      setState(() {
                                        isChecked = value!;
                                      });
                                    }),
                                    Expanded(child: Text(AppLocalizations.of(context)!.set_default_message
                                        , overflow: TextOverflow.visible))
                                  ],
                                )
                              ],
                            ),
                          ),
                        )),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: height / 13,
                        padding: EdgeInsets.all(10.0),
                        child: _getAddCardButton(style, model, controllers
                            , validTillDate, widget.goToHome, isChecked))
                  ],
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
          )
      );
    }, onModelReady: (model) {
      print('Model is Ready');
    });
  }

  Widget _getAddCardButton(ButtonStyle style, AccountViewModel model,
      List<TextEditingController> controllers, String? validTillData, bool? goToHome, bool? isChecked) {
    var addCardModel = getAddCardModel(controllers, validTillData, isChecked);

    Widget widget = CustomLoadingButton(
        defaultWidget: Text(AppLocalizations.of(context)!.add_card_title,
            style: TextStyle(color: Colors.white, fontSize: 20)),
        progressWidget: ThreeSizeDot(),
        width: double.infinity,
        height: 45,
        borderRadius: 24,
        animate: false,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            print('${Theme.of(context).primaryColor}\n Valid Till: $validTillDate');
            if (validTillData != null) {
              var response = await model.AddCard(addCardModel);
              return () {
                if (response == null) {
                  CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                      context: context,
                      title: AppLocalizations.of(context)!.error_hint,
                      message: model.errorMessage,
                      onPositivePressed: () {
                        previousPage(false);
                      },
                      buttonPositive: AppLocalizations.of(context)!.button_ok);
                } else {
                  if (response.status!) {
                    var dialog = CustomDialog(DialogType.SUCCESS);
                    dialog.buildAndShowDialog(
                        context: context,
                        title: 'Card',
                        message: response.message,
                        onPositivePressed: () {
                          if(goToHome!){
                            Navigator.of(context, rootNavigator: true).pop();
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()),
                                    (Route<dynamic> route) => route.isFirst);
                          }else{
                            previousPage(true);
                          }
                        },
                        buttonPositive: 'OK');
                  }
                  else if(response is APIException){
                    CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                        context: context,
                        title: AppLocalizations.of(context)!.error,
                        message: response.message,
                        onPositivePressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        buttonPositive: 'OK');
                  }
                  else {
                    //print('API Response in View');
                    CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                        context: context,
                        title: AppLocalizations.of(context)!.error_hint,
                        message: model.errorMessage,
                        onPositivePressed: () {

                          if(goToHome!){
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => HomePage()),
                                    (Route<dynamic> route) => false);
                          }else{
                            clearPrefsAndGotoLogin(true, model.errorMessage);
                          }

                        },
                        buttonPositive: 'OK');
                  }
                }
              };
            } else {
              return () {
                CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                    context: context,
                    title: AppLocalizations.of(context)!.expiry_date_title,
                    message: AppLocalizations.of(context)!.expiry_date_error_hint,
                    onPositivePressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    buttonPositive: 'OK');
              };
            }
          }
        });
    return widget;
  }

  String? title, message;

  void previousPage(bool reload) {
    // isGoBack = true;
    Navigator.of(context).pop();
    if (reload) {
      Navigator.of(context).pop(reload);
    }
    //Navigator.of(context, rootNavigator: true).pop(MaterialPageRoute(builder: (context) => AccountListPage()));
  }

  void clearPrefsAndGotoLogin(bool bool, String? errorMessage) async {
    Navigator.of(context).pop();
    if(errorMessage!.contains('Unauth')){
      // LocalSharedPref().clearLoginDetails().then((value) => {
      //   //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false)
      // context.go(LipaQuickAppRouteMap.login)
      // });
      //await LocalSharedPref().clearLoginDetails();
      goToLoginPage(context);
    }
  }
}

AddCardModel? getAddCardModel(
    List<TextEditingController> controllers, String? validTillData, bool? isChecked) {
  return AddCardModel.name(
      id: const Uuid().v1(),
      cardNumber: controllers[1].text,
      nameOnCard: controllers[2].text,
      validTill: validTillData,
      isPrimary: isChecked);
}

class FormFields extends StatefulWidget {
  List<TextEditingController> controllers;
  String hint;
  String? errorMessageFirst, errorMessageSecond;
  bool isCardNumber, isCVVCode;
  int position = -1;

  FormFields(
    this.controllers,
    this.hint,
    this.position, {
    Key? key,
    this.errorMessageFirst,
    this.errorMessageSecond,
    this.isCardNumber = false,
    this.isCVVCode = false,
  }) : super(key: key) {}

  @override
  State<StatefulWidget> createState() =>
      FormFieldState(controllers, hint, position,
          errorMessageFirst: errorMessageFirst,
          errorMessageSecond: errorMessageSecond,
          isAccount: isCardNumber,
          isSwiftCode: isCVVCode);
}

class FormFieldState extends State<FormFields> {
  List<TextEditingController> controllers;
  String hint = '';
  String? errorMessageFirst, errorMessageSecond;
  bool isAccountNumber = false, isCvvCode = false;

  int position = -1;
  var _isObscure = false;

  var insets = UIHelper.mediumSymmetricPadding();

  FormFieldState(
    this.controllers,
    this.hint,
    this.position, {
    String? errorMessageFirst,
    String? errorMessageSecond,
    bool isAccount = false,
    bool isSwiftCode = false,
  }) {
    this.errorMessageFirst = errorMessageFirst;
    this.errorMessageSecond = errorMessageSecond;
    this.isAccountNumber = isAccount;
    this.isCvvCode = isSwiftCode;
  }

  @override
  Widget build(BuildContext context) {
    var outlineStyle = const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)));
    InputDecoration inputDecoration;
    inputDecoration = InputDecoration(
      border: outlineStyle,
      hintText: hint,
    );
    List<TextInputFormatter> inputFormatters;
    if (isAccountNumber) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        CardNumberInputFormatter()
      ];
    } else if (isCvvCode) {
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[0-9]"))];
    } else {
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[A-Za-z\\s]"))];
    }
    return Padding(
        padding: insets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(hint, style: InputTitleStyle),
            const SizedBox(height: 5),
            TextFormField(
              controller: controllers[position],
              autofocus: true,
              cursorColor: Theme.of(context).primaryColorDark,
              style: Theme.of(context)
                  .textTheme
                  .copyWith(
                      headlineSmall: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: appSurfaceBlack, fontSize: 16))
                  .headlineSmall,
              inputFormatters: inputFormatters,
              obscureText: _isObscure,
              textInputAction: TextInputAction.next,
              keyboardType: (isAccountNumber || isCvvCode)
                  ? TextInputType.text
                  : TextInputType.text,
              maxLength: isCvvCode
                  ? 3
                  : isAccountNumber
                      ? 22
                      : 50,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return errorMessageFirst;
                }

                if (isCvvCode) {
                  if (value.length < 3) {
                    return errorMessageSecond;
                  }
                }

                if (isAccountNumber) {
                  if (value.length < 16) {
                    return errorMessageSecond;
                  } else if (!RegExp(
                          ('^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|6(?:011|5[0-9]{2})[0-9]{12}|(?:2131|1800|35\d{3})\d{11})\$'))
                      .hasMatch(value.replaceAll(' ', ''))) {
                    return 'Please Enter a valid credit/debit card number';
                  }
                }

                return null;
              },
              decoration: inputDecoration,
            )
          ],
        ));
  }
}
