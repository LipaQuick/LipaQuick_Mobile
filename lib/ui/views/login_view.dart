import 'dart:convert';

import 'package:country_codes/country_codes.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lipa_quick/core/managers/language/language_bloc.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/requests.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/ui/shared/text_styles.dart';
import 'package:lipa_quick/ui/shared/ui_helpers.dart';
import 'package:lipa_quick/ui/views/add_account/add_account.dart';
import 'package:lipa_quick/ui/views/dashboard/dashboard_page.dart';
import 'package:lipa_quick/ui/views/forgot_password/forgot_password.dart';
import 'package:lipa_quick/ui/views/forgot_password/recovery_password.dart';
import 'package:lipa_quick/ui/views/otp/otp_screen.dart';
import 'package:lipa_quick/ui/views/register/register.dart';
import 'package:lipa_quick/ui/views/register/register_step_4.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/localization/app_language_pref.dart';
import '../../core/view_models/accounts_viewmodel.dart';
import '../shared/app_colors.dart';
import '../shared/app_theme.dart';
import '../shared/dialogs/dialogshelper.dart';
import '../widgets/button.dart';
import '../widgets/custom_loading.dart';
import 'payment/payment_link_page.dart';

class LoginPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginPage());
  }

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => LoginPageForm();
}

class LoginPageForm extends State<LoginPage> {
  var _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> controllers =
      List.generate(1, (index) => TextEditingController());

  late AppLanguage _appLocale;
  late AccountViewModel model;

  CountryCode? countryCode;

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('login', true);
    });
  }

  Future<void> _saveDetails(String token, UserDetails? userModel) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('login', true);
    prefs.setString("token", token);
    debugPrint('Data' + userModel!.toJson().toString());

    prefs.setString('userDetails', jsonEncode(userModel.toJson()).toString());
  }

  late String username, pass;

  @override
  void initState() {
    initCountry();
    super.initState();
  }

  @override
  void didChangeDependencie() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _appLocale.fetchLocale().then((value) =>
    //     {print('${value!.languageCode}'), _appLocale.changeLanguage(value)});

    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
        fixedSize: const Size.fromHeight(45));
    var padding = UIHelper.smallSymmetricPadding();
    var outlineStyle = const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)));
    var welcomeMsg = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(Assets.icon.lauchericon.path, width: 120),
        Text.rich(
          TextSpan(
            text: '', // default text style
            children: <TextSpan>[
              TextSpan(
                  text: '${AppLocalizations.of(context)!.welcome}\n',
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      color: Colors.black,
                      fontSize: 27)),
              TextSpan(
                  text: AppLocalizations.of(context)!.welcome_end,
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      color: Colors.green,
                      fontSize: 27)),
            ],
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
    var register = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          child: Text.rich(
            TextSpan(
              text: '', // default text style
              children: <TextSpan>[
                TextSpan(
                    text: '${AppLocalizations.of(context)!.register} ',
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                        fontSize: 16)),
                TextSpan(
                    text: AppLocalizations.of(context)!.register_here,
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        decoration: TextDecoration.underline,
                        fontSize: 16)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          onTap: () {
            openPage(context, const RegisterPage());
          },
        )
      ],
    );

    return Consumer2(builder: (BuildContext context, AppLanguage appLang,
        AccountViewModel model, Widget? child) {
      var code = AppLocalizations.of(context);
      if (kDebugMode) {
        print(code!.localeName);
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildAppTheme()!,
        home: Scaffold(
          resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: SafeArea(
                child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(padding: padding, child: welcomeMsg),
                        const SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: padding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(AppLocalizations.of(context)!.user_name_hint,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: controllers[0],
                                cursorColor: Theme.of(context).primaryColorDark,
                                //inputFormatters: [PhoneEmailInputFormatter()],
                                style: Theme.of(context)
                                    .textTheme
                                    .copyWith(
                                    headlineSmall: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                        color: appSurfaceBlack,
                                        fontSize: 16))
                                    .headlineSmall,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (String value) {
                                  username = value;
                                },
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .validation_phone_email_valid;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: outlineStyle,
                                  hintText: AppLocalizations.of(context)!
                                      .user_name_hint,
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                            padding: padding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(AppLocalizations.of(context)!.password_hint,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                TextFormField(
                                  obscureText: _isObscure,
                                  cursorColor: Theme.of(context).primaryColorDark,
                                  style: Theme.of(context)
                                      .textTheme
                                      .copyWith(
                                      headlineSmall: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                          color: appSurfaceBlack,
                                          fontSize: 16))
                                      .headlineSmall,
                                  onChanged: (String value) {
                                    pass = value;
                                  },
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!
                                          .validation_password_empty;
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: outlineStyle,
                                    hintText: AppLocalizations.of(context)!
                                        .password_hint,
                                    suffixIcon: IconButton(
                                        icon: Icon(
                                          _isObscure
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isObscure = !_isObscure;
                                          });
                                        }),
                                  ),
                                )
                              ],
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                      AppLocalizations.of(context)!
                                          .forgot_password_hint,
                                      style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600))
                                ],
                              )),
                          onTap: (){
                            //openPage(context, ForgotPasswordPage(username: '9140542194',));
                            openPage(context, const AccountRecovery());

                            // context.pushNamed(LipaQuickAppRouteMap.account_recovery);
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: padding,
                          child: _getLoginButton(style, model),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 0.0),
                            child: register)
                      ],
                    )),
              ),
            )
        ),
      );
    });
  }

   openPage(BuildContext context, Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
     //Navigator.pushNamed(context, LipaQuickAppRouteMap.register);
     //context.go(LipaQuickAppRouteMap.register);
  }

  Widget _getLoginButton(ButtonStyle style, AccountViewModel model) {
    // return ElevatedButton(
    //   style: style,
    //   onPressed: () => _performLogin(model),
    //   child: Text(AppLocalizations.of(context)!
    //       .login_button_text),
    // );
    print('${Theme.of(context).primaryColor}');
    Widget widget = CustomLoadingButton(
      defaultWidget: const Text('Login',
          style: TextStyle(color: Colors.white, fontSize: 20)),
      progressWidget: ThreeSizeDot(),
      width: 114,
      height: 48,
      borderRadius: 24,
      animate: false,
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          clearSharedPref();
          var currentuserName = '';
          if(controllers[0].text.contains('@')){
            currentuserName = controllers[0].text;
          }
          else{
            var phoneNumber = controllers[0].text;
            var dialCode = context.read<LanguageBloc>().state.selectedLanguage.dialCode;

            if(dialCode != '+91'){
              dialCode = '+250';
            }
            // if(dialCode == '+91') {
            //   dialCode = '+250';
            // }

            if(phoneNumber.startsWith('0')){
              phoneNumber = phoneNumber.substring(1);
            }else if(phoneNumber.startsWith('2')){
              phoneNumber = phoneNumber.substring(3);
            }
            currentuserName = '${dialCode.toString().substring(1)}$phoneNumber';
            debugPrint('Current Name $currentuserName');
          }
          var response = await model.login(LoginRequest(currentuserName, pass));
          //var response = await model.login(LoginRequest('${'91'}${username}', pass));
          return () {
            if (response is APIException) {
              CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                  context: context,
                  title: (response as APIException).apiError.name,
                  message: (response as APIException).message,
                  onPositivePressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  buttonPositive: 'OK');
            } else {
              response = response as LoginApiResponse;
              if (response.status!) {
                // CustomDialog(DialogType.SUCCESS).buildAndShowDialog(
                //     context: context,
                //     title: 'Login',
                //     message: AppLocalizations.of(context)!.login_successful_msg,
                //     onPositivePressed: () => ,
                //     buttonPositive: 'OK');
                proceedAfterLogin(response);
              } else {
                CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                    context: context,
                    title: 'Error',
                    message: model.errorMessage,
                    onPositivePressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    buttonPositive: 'OK');
              }
            }
          };
        }
      },
    );
    return widget;
  }

  void clearSharedPref() {}

  void proceedAfterLogin(var response) {
    UserDetails? data = (response as LoginApiResponse).userData!;
    print('Phone Number Confirmed ${data.toString()}');
    if (data.phoneNumberConfirmed) {
      debugPrint('Phone Number Confirmed');
      _saveDetails(response.access_token, data).then((value) => {
      // context.pushReplacementNamed(LipaQuickAppRouteMap.home),
      // Navigator.pushNamed(
      //     context, '/dashboard'),
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => route.isFirst),
          });
    } else {
      debugPrint('Phone Number Not Confirmed');
      username = response.userData!.phoneNumber;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OtpScreen(
                  PaymentLinkPage(),
                  appToken: response.access_token,
                  userModel: response.userData!,
                  phoneNo: username,
                  OTP: '')));
    }
  }

  void initCountry() async {
    await CountryCodes.init();
  }
}

class FormFields extends StatefulWidget {
  List<TextEditingController> controllers;
  String hint;
  String? errorMessageFirst, errorMessageSecond;
  bool isPhone, isEmail, isPassword, isConfirmPassword;
  int position = -1;
  late final FlCountryCodePicker countryPicker;
  CountryCodeCallback? countryCallback;

  FormFields(this.controllers, this.hint, this.position,
      {Key? key,
      this.countryCallback,
      this.errorMessageFirst,
      this.errorMessageSecond,
      this.isPhone = false,
      this.isEmail = false,
      this.isPassword = false,
      this.isConfirmPassword = false})
      : super(key: key) {
    countryPicker = FlCountryCodePicker(localize: false);
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

  var insets = const EdgeInsets.all(0);

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
    } else if (isPhone) {
      inputDecoration = InputDecoration(
          border: outlineStyle,
          prefix: GestureDetector(
            onTap: () async {
              final code = await widget.countryPicker.showPicker(
                context: context,
              );
              if (code != null) {
                print(code.dialCode);
                setState(() => countryCode = code);
                if (widget.countryCallback != null) {
                  widget.countryCallback!(code);
                }
              }
            },
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
    } else {
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[A-Za-z]"))];
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          controller: controllers[position],
          autofocus: true,
          inputFormatters: inputFormatters,
          obscureText: _isObscure,
          textInputAction: TextInputAction.next,
          maxLength: isPhone ? 10 : null,
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
              if (value.length < 10) {
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
    );
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
}
