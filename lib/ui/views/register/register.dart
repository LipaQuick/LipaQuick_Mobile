import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:lipa_quick/core/models/IdentityResponse.dart';
import 'package:lipa_quick/core/models/resgister_steps_data.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/AppColorBuilder.dart';
import 'package:lipa_quick/ui/base_view.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/language/language_pref.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/views/login_view.dart';
import 'package:lipa_quick/ui/views/register/register_step_2.dart';
import 'dart:math';
import 'dart:convert';

import '../../../core/app_states.dart';
import '../../../gen/assets.gen.dart';
import '../../shared/app_colors.dart';
import '../../shared/custom_radio.dart';
import '../../shared/date_picker.dart';
import '../../shared/text_styles.dart';
import '../../shared/ui_helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/ui_styles.dart';

class RegisterPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const RegisterPage());
  }

  const RegisterPage({Key? key}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

enum Gender { Male, Female, Others }

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> controllers =
      List.generate(2, (index) => TextEditingController());
  Gender selectedGender = Gender.Male;
  IdentityDetails? _identityDetails = IdentityDetails();
  List<IdentityDetails?> list = [];
  AccountViewModel mainModel = locator<AccountViewModel>();

  late Locale _locale;

  String? dob;

  bool isDOBSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    for (var element in controllers) {
      element.dispose();
    }

    // if(mainModel != null){
    //   mainModel.dispose();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    EdgeInsets insets = UIHelper.smallSymmetricPadding();

    var welcomeMsg = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text.rich(
          TextSpan(
            text: '', // default text style
            children: <TextSpan>[
              TextSpan(
                  text: AppLocalizations.of(context)!.sign_up_now,
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      color: Colors.black,
                      fontSize: 21))
            ],
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
    AssetImage image =  AssetImage(Assets.icon.lauchericon.path);
    Image images = Image(image: image, width: 200, height: 80, fit: BoxFit.cover);

    var height = MediaQuery.of(context).size.height;

    return BaseView<AccountViewModel>(
        builder: (BuildContext context, AccountViewModel model, Widget? child) {
      return Scaffold(
          appBar: AppTheme.getAppBar(context: context, title:AppLocalizations.of(context)!.step_1,subTitle: "",enableBack: true),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: height / 5,
                        child: Column(
                          children: [
                            Container(child: images),
                            Expanded(child: Container(child: welcomeMsg), flex: 1,),
                          ],
                        )),
                    Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                FormFields(
                                    controllers,
                                    AppLocalizations.of(context)!
                                        .first_name_hint,
                                    0,
                                    errorMessageFirst:
                                    AppLocalizations.of(context)!
                                        .validation_first_name),
                                FormFields(
                                    controllers,
                                    AppLocalizations.of(context)!
                                        .last_name_hint,
                                    1,
                                    errorMessageFirst:
                                    AppLocalizations.of(context)!
                                        .validation_last_name),
                                // FormFields(controllers,
                                //     AppLocalizations.of(context)!.dob_hint, 3,
                                //     errorMessageFirst:
                                //     AppLocalizations.of(context)!
                                //         .validation_dob),
                                DatePickerWidget(
                                    restorationId: "DOB",
                                    hint: AppLocalizations.of(context)!.dob_hint,
                                    format: DateFormat('yyyy-MM-dd'),
                                    isCreditDebitCardDate: false,
                                    onChanged: (value){
                                      isDOBSelected = true;
                                      dob = value;
                                      setState(() {

                                      });
                                    }),
                                Padding(
                                  padding: UIHelper.mediumSymmetricPadding(),
                                  child: Container(
                                    alignment: AlignmentDirectional.centerStart,
                                    child:
                                    Text(AppLocalizations.of(context)!.gender, style: InputTitleStyle),
                                  ),
                                ),
                                Wrap(direction: Axis.horizontal, children: <
                                    Widget>[
                                  MyRadioListTile<Gender>(
                                    value: Gender.Male,
                                    groupValue: selectedGender,
                                    leading: '',
                                    title: Card(
                                      child: Padding(
                                        padding:
                                        UIHelper.smallSymmetricPadding(),
                                        child: Text(
                                          AppLocalizations.of(context)!.male,
                                          style:
                                          TextStyle(color: appSurfaceBlack),
                                        ),
                                      ),
                                      elevation: 6,
                                    ),
                                    onChanged: (value) => setState(() {
                                      selectedGender = value!;
                                    }),
                                  ),
                                  MyRadioListTile<Gender>(
                                    value: Gender.Female,
                                    groupValue: selectedGender,
                                    leading: '',
                                    title: Card(
                                      child: Padding(
                                        padding:
                                        UIHelper.smallSymmetricPadding(),
                                        child: Text(
                                          AppLocalizations.of(context)!.female,
                                          style:
                                          TextStyle(color: appSurfaceBlack),
                                        ),
                                      ),
                                      elevation: 6,
                                    ),
                                    onChanged: (value) => setState(() {
                                      selectedGender = value!;
                                    }),
                                  )
                                ])
                              ],
                            ),
                          ),
                        )),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: height / 12,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                    child: Visibility(
                                      visible: (_formKey.currentState != null && _formKey.currentState!.validate() && isDOBSelected),
                                      child: Padding(
                                        padding: insets,
                                        child: ElevatedButton(
                                          style: buttonStyle,
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if(isDOBSelected){
                                                var registerStep = RegisterStep(firstName: controllers[0].text,
                                                    secondName: controllers[1].text,
                                                    gender: selectedGender, dob: dob);
                                                print('Step 1 ${registerStep.toString()}');
                                                // context.push(LipaQuickAppRouteMap.registerStep2
                                                //   , extra: registerStep);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RegisterStepTwo(registerStep: registerStep,)));
                                              }else{
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Please select DOB.'),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Text(AppLocalizations.of(context)!.btn_next),
                                        ),
                                      ),
                                    ))
                              ],
                            )
                          ],
                        )
                    )
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
                          child: CircularProgressIndicator(),
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
          ));
    }, onModelReady: (model) {
      mainModel = model;
      print('Model is Ready');
    });
  }



  _showDropDownField() {
    var outlineStyle = const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)));
    return Padding(
        padding: UIHelper.smallSymmetricPadding(),
        child: DropdownButtonFormField<IdentityDetails?>(
          isExpanded: true,
          value: _identityDetails!.name == null ? null : _identityDetails,
          icon: const Icon(Icons.chevron_right),
          elevation: 16,
          style: const TextStyle(color: appSurfaceBlack),
          decoration: InputDecoration(
            border: outlineStyle,
          ),
          borderRadius: BorderRadius.circular(8),
          onChanged: (IdentityDetails? newValue) {
            setState(() {
              _identityDetails = newValue;
            });
          },
          items: list
              .map<DropdownMenuItem<IdentityDetails>>((IdentityDetails? value) {
            return DropdownMenuItem<IdentityDetails>(
              value: value,
              child: Text(value!.name.toString()),
            );
          }).toList(),
        ));
  }
}

class FormFields extends StatefulWidget {
  List<TextEditingController> controllers;
  String hint;
  String? errorMessageFirst, errorMessageSecond;
  bool isPhone, isEmail, isPassword, isConfirmPassword;
  int position = -1;
  IdentityDetails? identityDetails;

  FormFields(this.controllers, this.hint, this.position,
      {Key? key,
      this.errorMessageFirst,
      this.errorMessageSecond,
      this.isPhone = false,
      this.isEmail = false,
      this.isPassword = false,
      this.isConfirmPassword = false,
      this.identityDetails})
      : super(key: key);

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

  var insets = UIHelper.mediumSymmetricPadding();

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
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9]"))];
    }
    return Padding(
        padding: insets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(hint, style: InputTitleStyle),
            const SizedBox(height: 10),
            TextFormField(
              controller: controllers[position],
              autofocus: true,
              cursorColor: Theme.of(context).primaryColorDark,
              style: Theme.of(context).textTheme.copyWith(headlineSmall: Theme.of(context).textTheme
                  .headlineSmall?.copyWith(color: appSurfaceBlack, fontSize: 16)).headlineSmall,
              inputFormatters: inputFormatters,
              obscureText: _isObscure,
              textInputAction: TextInputAction.next,
              keyboardType: isPhone
                  ? TextInputType.phone
                  : isEmail
                      ? TextInputType.emailAddress
                      : (position == 2 && widget.identityDetails != null && widget.identityDetails!.alphaNumeric != null)
                          ? widget.identityDetails!.alphaNumeric!? TextInputType.text:TextInputType.number
                          : TextInputType.text,
              maxLength: (position == 2 && widget.identityDetails != null && widget.identityDetails!.maxLength != null)?widget.identityDetails!.maxLength!:50,
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

                // if(position == 2 && widget.identityDetails != null && widget.identityDetails!.regex != null){
                //   if(widget.identityDetails!.regex!.isNotEmpty){
                //     var regex = RegExp(widget.identityDetails!.regex!);
                //     print('Validating Regex');
                //     if(!regex.hasMatch(value)){
                //       return 'Invalid value has been entered, please enter valid $hint';
                //     }
                //   }
                // }

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
