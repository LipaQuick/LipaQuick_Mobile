import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/resgister_steps_data.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/ui/base_view.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/shared/text_styles.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'dart:math';
import 'dart:convert';

import '../../../gen/assets.gen.dart';
import '../../shared/ui_helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/ui_styles.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_loading.dart';

typedef CountryCodeCallback = CountryCode Function(CountryCode);

class RegisterFourthStep extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => RegisterFourthStep());
  }

  RegisterStep? registerStep;

  RegisterFourthStep({Key? key, this.registerStep}) : super(key: key);

  @override
  RegisterSecondStepState createState() => RegisterSecondStepState();
}

class RegisterSecondStepState extends State<RegisterFourthStep> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> controllers =
      List.generate(5, (index) => TextEditingController());

  var isChecked = false;

  CountryCode? countryCode;

  var showReferralBox = false;
  late final FlCountryCodePicker countryPicker;

  //late Locale _locale;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print('Name: ${details!.name!.toLowerCase()}');
    if(widget.registerStep!.selectedCountry != null && widget.registerStep!.selectedCountry!.name!.toLowerCase()
        == 'rwanda'){
      countryPicker = const FlCountryCodePicker(localize: false
          , filteredCountries: ['RW']);

    }else{
      countryPicker = const FlCountryCodePicker(localize: false
          , filteredCountries: ['IN']);

    }
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
    var width = MediaQuery.of(context).size.width;

    var welcomeMsg = Text(AppLocalizations.of(context)!.sign_up_now,
        style: TextStyle(
            fontStyle: FontStyle.normal, color: Colors.black, fontSize: 21));
    AssetImage image = AssetImage(Assets.icon.lauchericon.path);
    Image images =
        Image(image: image, width: 200, height: 80, fit: BoxFit.cover);

    return BaseView<AccountViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppTheme.getAppBar(
                context: context,
                title: AppLocalizations.of(context)!.step_4,
                subTitle: "",
                enableBack: true),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: height / 7,
                        child: Column(
                          children: [
                            Container(child: images),
                            Expanded(child: Container(child: welcomeMsg), flex: 1,),
                          ],
                        )),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            FormFields(controllers,
                                AppLocalizations.of(context)!.email_hint, 0,
                                errorMessageFirst: AppLocalizations.of(context)!
                                    .validation_email,
                                errorMessageSecond:
                                    AppLocalizations.of(context)!
                                        .validation_email_valid,
                                isEmail: true),
                            FormFields(
                              controllers,
                              AppLocalizations.of(context)!.phone_hint,
                              1,
                              errorMessageFirst: AppLocalizations.of(context)!
                                  .validation_phone,
                              errorMessageSecond: AppLocalizations.of(context)!
                                  .validation_phone_valid,
                              isPhone: true,
                              countryPicker: countryPicker,
                              countryCallback: (CountryCode code) {
                                //print(code.dialCode);
                                setState(() {
                                  countryCode = code;
                                });
                                return countryCode!;
                              },
                            ),
                            FormFields(
                              controllers,
                              AppLocalizations.of(context)!.password_hint,
                              2,
                              errorMessageFirst: AppLocalizations.of(context)!
                                  .validation_password_valid,
                              isPassword: true,
                            ),
                            FormFields(
                                controllers,
                                AppLocalizations.of(context)!.confirm_password,
                                3,
                                errorMessageFirst: AppLocalizations.of(context)!
                                    .validation_confirm_password,
                                errorMessageSecond:
                                    AppLocalizations.of(context)!
                                        .validation_password_not_matched,
                                isConfirmPassword: true),
                            Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          Text(
                                              //'Do you have a referral code?',
                                              AppLocalizations.of(context)!
                                                  .referral_code,
                                              style: subHeaderStyle,
                                              overflow: TextOverflow.visible),
                                          Checkbox(
                                              fillColor: MaterialStateProperty
                                                  .resolveWith(getColor),
                                              value: showReferralBox,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  showReferralBox = value!;
                                                });
                                              })
                                        ],
                                      ),
                                      Visibility(
                                        visible: showReferralBox,
                                        child: FormFields(
                                          controllers,
                                          AppLocalizations.of(context)!
                                              .referral_code_hint,
                                          4,
                                          errorMessageFirst:
                                              AppLocalizations.of(context)!
                                                  .referral_code_validation,
                                          errorMessageSecond: '',
                                        ),
                                      )
                                    ])),
                            Row(
                              children: [
                                Checkbox(
                                    fillColor:
                                        MaterialStateProperty.resolveWith(
                                            getColor),
                                    value: isChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked = value!;
                                      });
                                    }),
                                //
                                Expanded(
                                    child: Text(
                                        //'I agree to the Terms and Conditions, Privacy Policy and Content Policy',
                                        AppLocalizations.of(context)!
                                            .term_conditions,
                                        style: subHeaderStyle,
                                        overflow: TextOverflow.visible)),
                              ],
                            )
                          ],
                        )),
                    Visibility(
                        visible: isValid(controllers, isChecked),
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: UIHelper.smallSymmetricPadding(),
                              child: _getSignUpButton(
                                  buttonStyle,
                                  model,
                                  widget.registerStep,
                                  controllers,
                                  isChecked,
                                  countryPicker),
                            )))
                  ],
                ),
              ),
            ),
          );
        },
        onModelReady: (model) {});
  }

  Widget _getSignUpButton(
      ButtonStyle style,
      AccountViewModel model,
      RegisterStep? registerStep,
      List<TextEditingController> controllers,
      bool termsAndCondition,
      FlCountryCodePicker? countryPicker) {
    print('${Theme.of(context).primaryColor}');

    Widget widget = CustomLoadingButton(
      defaultWidget: const Text('SIGN UP',
          style: TextStyle(color: Colors.white, fontSize: 20)),
      progressWidget: ThreeSizeDot(),
      width: 114,
      height: 48,
      borderRadius: 24,
      animate: false,
      onPressed: !termsAndCondition
          ? null
          : () async {
              if (_formKey.currentState!.validate()) {
                CountryCode countryCode = countryPicker!.countryCodes.where((element) => element.code == countryPicker.filteredCountries.first).first;
                print('Country Code${countryCode.dialCode}');
                var response = await model.registerUser(
                    controllers, registerStep, countryCode);
                return () {
                  if (response is APIException) {
                    print('Message ${model.errorMessage}');

                    CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                        context: context,
                        title: (response).apiError.name,
                        message: model.errorMessage,
                        onPositivePressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        buttonPositive: 'OK');
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text(model.errorMessage)),
                    // );
                  } else {
                    if (response.status!) {
                      var dialog = CustomDialog(DialogType.SUCCESS);
                      dialog.buildAndShowDialog(
                          context: context,
                          title: AppLocalizations.of(context)!.registration,
                          message: (response as RegisterApiResponse).message!,
                          onPositivePressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            //model.dispose();
                            // Navigator.pushAndRemoveUntil(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => LoginPage()),
                            //     (Route<dynamic> route) => false);
                            // await LocalSharedPref().clearLoginDetails();
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage())
                                , (Route<dynamic> route) => route.isFirst);
                          },
                          buttonPositive:
                              AppLocalizations.of(context)!.button_ok);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //       content: Text(
                      //           AppLocalizations.of(context)!.login_successful_msg)),
                      // );
                    } else {
                      //print('API Response in View');
                      CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                          context: context,
                          title: AppLocalizations.of(context)!.error,
                          message: model.errorMessage,
                          onPositivePressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          buttonPositive:
                              AppLocalizations.of(context)!.button_ok);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text(model.errorMessage)),
                      // );
                    }
                  }
                };
              }
            },
    );
    return widget;
  }
}

isValid(List<TextEditingController> controllers, bool isChecked) {
  return (controllers[0].text.isNotEmpty &&
      controllers[1].text.isNotEmpty &&
      controllers[2].text.isNotEmpty &&
      controllers[3].text.isNotEmpty &&
      isChecked);
}

class FormFields extends StatefulWidget {
  List<TextEditingController> controllers;
  String hint;
  String? errorMessageFirst, errorMessageSecond;
  bool isPhone, isEmail, isPassword, isConfirmPassword;
  int position = -1;
  FlCountryCodePicker? countryPicker;
  CountryCodeCallback? countryCallback;

  FormFields(this.controllers, this.hint, this.position,
      {Key? key,
      this.countryCallback,
      this.errorMessageFirst,
      this.errorMessageSecond,
      this.isPhone = false,
      this.isEmail = false,
      this.isPassword = false,
      this.isConfirmPassword = false, this.countryPicker})
      : super(key: key) {
  }

  @override
  State<StatefulWidget> createState() =>
      FormFieldState(controllers, hint, position,
          errorMessageFirst: errorMessageFirst,
          errorMessageSecond: errorMessageSecond,
          isPhone: isPhone,
          isEmail: isEmail,
          isPassword: isPassword,
          isConfirmPassword: isConfirmPassword);
}

class FormFieldState extends State<FormFields> {
  List<TextEditingController> controllers;
  String hint = '';
  String? errorMessageFirst, errorMessageSecond;
  bool isPhone = false,
      isEmail = false,
      isPassword = false,
      isConfirmPassword = false;
  int position = -1;
  var _isObscure = false;
  CountryCode? countryCode;

  var insets = const EdgeInsets.only(left: 12, right: 12, bottom: 12);

  FormFieldState(this.controllers, this.hint, this.position,
      {String? errorMessageFirst,
      String? errorMessageSecond,
      bool isPhone = false,
      bool isEmail = false,
      bool isPassword = false,
      bool isConfirmPassword = false}) {
    this.errorMessageFirst = errorMessageFirst;
    this.errorMessageSecond = errorMessageSecond;
    this.isPhone = isPhone;
    this.isEmail = isEmail;
    this.isPassword = isPassword;
    this.isConfirmPassword = isConfirmPassword;
    this._isObscure = isPassword || isConfirmPassword;
  }


  @override
  void initState() {
    super.initState();
    if(widget.countryPicker != null){
      countryCode = widget.countryPicker!.countryCodes.where((element)
      => element.code == widget.countryPicker!.filteredCountries.first).first;
    }

  }

  @override
  Widget build(BuildContext context) {
    var outlineStyle = const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)));
    var inputDecoration;
    if (isPassword || isConfirmPassword) {
      inputDecoration = InputDecoration(
          border: outlineStyle,
          hintText: hint,
          suffixIcon: IconButton(
              icon: Icon(
                _isObscure ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              }));
    }
    else if (isPhone) {
      inputDecoration = InputDecoration(
          border: outlineStyle,
          prefix: GestureDetector(
            // onTap: () async {
            //   final code = await widget.countryPicker.showPicker(
            //     context: context,
            //   );
            //   if (code != null) {
            //     print(code.dialCode);
            //     setState(() => countryCode = code);
            //     if (widget.countryCallback != null) {
            //       widget.countryCallback!(code);
            //     }
            //   }
            // },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              margin: EdgeInsets.only(left: 8.0, right: 8.0),
              decoration: const BoxDecoration(
                  color: appGreen400,
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              child: Text(countryCode?.dialCode ?? '+1',
                  style: const TextStyle(color: Colors.white)),
            ),
          ));
    } else {
      inputDecoration = InputDecoration(
        border: outlineStyle,
        hintText: hint,
      );
    }
    var inputFormatters;
    if (isPhone) {
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[0-9]"))];
    } else if (isEmail) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp("[0-9A-Za-z@.]"))
      ];
    } else if (isPassword || isConfirmPassword) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp("[0-9A-Za-z@!#%^&*]"))
      ];
    } else if (position == 4){
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9]"))];
    }else {
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[A-Za-z]"))];
    }
    return Padding(
        padding: insets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(hint,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: controllers[position],
              autofocus: true,
              inputFormatters: inputFormatters,
              obscureText: _isObscure,
              textInputAction: TextInputAction.next,
              maxLength: isPhone ? getPhoneNumberLength(countryCode) : position == 4 ? null : null,
              style: InputTitleStyle,
              keyboardType: isPhone
                  ? TextInputType.phone
                  : isEmail
                      ? TextInputType.emailAddress
                      : TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return errorMessageFirst;
                }

                if (isEmail) {
                  if (!value.contains('@')) {
                    return errorMessageSecond;
                  }
                }

                if (isPhone) {
                  if (countryCode!.dialCode == '+250'?value.length < 9 : value.length < 10) {
                    return errorMessageSecond;
                  }
                }

                if (isPassword) {
                  return validatePassword(value);
                }

                if (isConfirmPassword) {
                  if (controllers[position - 1].text !=
                      controllers[position].text) {
                    return errorMessageSecond;
                  }
                }

                return null;
              },
              decoration: inputDecoration,
            )
          ],
        ));
  }

  String? validatePassword(String? value) {
    String missings = "";
    if (value!.length < 8) {
      //missings += "Password has at least 8 characters\n";
      missings += AppLocalizations.of(context)!.validation_password_characters;
    }

    if (!RegExp("(?=.*[a-z])").hasMatch(value)) {
      //missings += "Password must contain at least one lowercase letter\n";
      missings += AppLocalizations.of(context)!.validation_password_lowercase;
    }
    if (!RegExp("(?=.*[A-Z])").hasMatch(value)) {
      //missings += "Password must contain at least one uppercase letter\n";
      missings += AppLocalizations.of(context)!.validation_password_uppercase;
    }
    if (!RegExp((r'\d')).hasMatch(value)) {
      //missings += "Password must contain at least one digit\n";
      missings += AppLocalizations.of(context)!.validation_password_digit;
    }
    if (!RegExp((r'\W')).hasMatch(value)) {
      //missings += "Password must contain at least one symbol\n";
      missings += AppLocalizations.of(context)!.validation_password_symbol;
    }

    //if there is password input errors return error string
    if (missings != "") {
      return missings;
    }

    //success
    return null;
  }

  getPhoneNumberLength(CountryCode? countryCode) {
    if(countryCode == null){
      return 10;
    }
    return countryCode.dialCode == '+250' ? 9 : 10;
  }
}

class Helper {
  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  String getRandOTP(int len) {
    return Random().nextInt(9999).toString().padLeft(4, '0');
  }
}
