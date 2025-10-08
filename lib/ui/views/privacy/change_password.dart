import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/user.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/shared/text_styles.dart';
import 'package:lipa_quick/ui/shared/ui_helpers.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/widgets/button.dart';
import 'package:lipa_quick/ui/widgets/custom_loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangePasswordPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const ChangePasswordPage());
  }

  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => ChangePasswordForm();
}

class ChangePasswordForm extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> controllers =
      List.generate(3, (index) => TextEditingController());
  final AccountViewModel _model = locator<AccountViewModel>();

  Future<void> _clearDetails() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('login', false);
    prefs.setString("token", "");
    prefs.setString('userDetails', "");
  }

  late String username, pass;

  @override
  void initState() {
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
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
        fixedSize: const Size.fromHeight(45));
    var padding = UIHelper.smallSymmetricPadding();
    var outlineStyle = const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)));

    return Consumer(
        builder: (BuildContext context, AccountViewModel model, Widget? child) {
      return Scaffold(
        appBar: AppTheme.getAppBar(
            context: context,
            title: AppLocalizations.of(context)!.change_password_title,
            subTitle: "",
            enableBack: true),
        body: Stack(children: [
          SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 40),
                    FormFields(
                      controllers,
                      AppLocalizations.of(context)!.password_hint,
                      0,
                      errorMessageFirst: AppLocalizations.of(context)!
                          .validation_password_valid,
                      isOldPassword: true,
                    ),
                    FormFields(controllers,
                        AppLocalizations.of(context)!.new_password_hint, 1,
                        errorMessageFirst: AppLocalizations.of(context)!
                            .validation_confirm_password,
                        errorMessageSecond: AppLocalizations.of(context)!
                            .validation_password_not_matched,
                        isNewPassword: true),
                    FormFields(controllers,
                        AppLocalizations.of(context)!.confirm_password, 2,
                        errorMessageFirst: AppLocalizations.of(context)!
                            .validation_confirm_password,
                        errorMessageSecond: AppLocalizations.of(context)!
                            .validation_password_not_matched,
                        isNewConfirmPassword: true),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: padding,
                      child: _getChangeButton(style, _model),
                    )
                  ],
                )),
          ),
        ]),
      );
    });
  }

  Future<dynamic> openPage(BuildContext context, Widget widget) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => widget));
  }

  Widget _getChangeButton(ButtonStyle style, AccountViewModel model) {
    print('${Theme.of(context).primaryColor}');
    Widget widget = CustomLoadingButton(
      defaultWidget: Text(AppLocalizations.of(context)!.change_password_title,
          style: const TextStyle(color: Colors.white, fontSize: 20)),
      progressWidget: ThreeSizeDot(),
      width: 114,
      height: 48,
      borderRadius: 24,
      animate: false,
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          if(controllers[2].text == controllers[0].text){
            return (){
              CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                  context: context,
                  title: 'Password',
                  message: 'New Password cannot be same as old password. Please enter new password',
                  onPositivePressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  buttonPositive: AppLocalizations.of(context)!.button_ok);

            };
          }
          //clearSharedPref();
          var response = await model.changePassword(
              controllers[0].text, controllers[1].text, controllers[2].text);
          return () {
            if (response is APIException) {
              CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                  context: context,
                  title: response.apiError.name,
                  message: response.message,
                  onPositivePressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  buttonPositive: AppLocalizations.of(context)!.button_ok);
            } else {
              if (response.status!) {
                CustomDialog(DialogType.SUCCESS).buildAndShowDialog(
                    context: context,
                    title: AppLocalizations.of(context)!.change_password_title,
                    message: AppLocalizations.of(context)!.change_password_success_msg,
                    onPositivePressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      //Login Successful, go to OTP Verification Page
                      // Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      //     OtpScreen(const HomePage(), appToken: response.access_token, userModel:response.userData!
                      //         , phoneNo: username, OTP: Helper().getRandOTP(4).toString())));
                      goToLoginPage(context);

                    },
                    buttonPositive: AppLocalizations.of(context)!.button_ok);
              } else {
                CustomDialog(DialogType.FAILURE).buildAndShowDialog(
                    context: context,
                    title: AppLocalizations.of(context)!.error_hint,
                    message: model.errorMessage,
                    onPositivePressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    buttonPositive: AppLocalizations.of(context)!.button_ok);
              }
            }
          };
        }
      },
    );
    return widget;
  }

  void clearSharedPref() {}
}

class FormFields extends StatefulWidget {
  List<TextEditingController> controllers;
  String hint;
  String? errorMessageFirst, errorMessageSecond;
  bool isPhone, isEmail, isOldPassword, isNewPassword, isNewConfirmPassword;
  int position = -1;

  FormFields(this.controllers, this.hint, this.position,
      {Key? key,
      this.errorMessageFirst,
      this.errorMessageSecond,
      this.isPhone = false,
      this.isEmail = false,
      this.isOldPassword = false,
      this.isNewPassword = false,
      this.isNewConfirmPassword = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => FormFieldState();
}

class FormFieldState extends State<FormFields> {
  var _isObscure = false;

  var insets = UIHelper.mediumSymmetricPadding();

  FormFieldState();

  @override
  void initState() {
    _isObscure = widget.isOldPassword ||
        widget.isNewPassword ||
        widget.isNewConfirmPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var outlineStyle = const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)));
    var inputDecoration;
    if (widget.isOldPassword || widget.isNewPassword || widget.isNewConfirmPassword) {
      inputDecoration = InputDecoration(
          border: outlineStyle,
          hintText: widget.hint,
          suffixIcon: IconButton(
              icon: Icon(
                _isObscure ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              }));
    } else {
      inputDecoration = InputDecoration(
        border: outlineStyle,
        hintText: widget.hint,
      );
    }
    var inputFormatters;
    if (widget.isOldPassword ||
        widget.isNewPassword ||
        widget.isNewConfirmPassword) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp("[0-9A-Za-z@!#%^&*]"))
      ];
    } else {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9]"))
      ];
    }
    return Padding(
        padding: insets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.hint, style: InputTitleStyle),
            const SizedBox(height: 10),
            TextFormField(
              controller: widget.controllers[widget.position],
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
              keyboardType: TextInputType.text,
              maxLength: 20,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.errorMessageFirst;
                }

                if (widget.isOldPassword) {
                  return validatePassword(value);
                }

                if (widget.isNewPassword) {
                  return validatePassword(value);
                }

                if (widget.isNewConfirmPassword) {
                  if (widget.controllers[widget.position - 1].text !=
                      widget.controllers[widget.position].text) {
                    return widget.errorMessageSecond;
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
}
