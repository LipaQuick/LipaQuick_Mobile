import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lipa_quick/core/models/address.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/profile/profile_details_response.dart';
import 'package:lipa_quick/core/models/resgister_steps_data.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/services/api.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/locator.dart';
import 'package:lipa_quick/ui/base_view.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/country_state_city.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/shared/text_styles.dart';
import 'package:lipa_quick/ui/views/register/register_step_3.dart';
import 'package:lipa_quick/ui/views/register/register_step_4.dart';
import 'package:lipa_quick/ui/views/registeration/auto_complete_ui.dart';
import 'package:lipa_quick/ui/views/user_profile/customer_profile.dart';
import 'dart:math';
import 'dart:convert';

import '../../../core/models/requests.dart';
import '../../shared/language/language_pref.dart';
import '../../shared/ui_helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/ui_styles.dart';
import '../../widgets/custom_loading.dart';
import '../../widgets/button.dart';

class EditCustomerDetails extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => EditCustomerDetails());
  }

  ProfileDetailsResponse? profileDetails;

  EditCustomerDetails({Key? key, this.profileDetails}) : super(key: key);

  @override
  EditDetails createState() => EditDetails();
}

class EditDetails extends State<EditCustomerDetails> {
  final _formKey = GlobalKey<FormState>();
  final _addressCountryKey = GlobalKey<AddressSearchState>();
  final stateKey = GlobalKey<AddressSearchState>();
  final cityKey = GlobalKey<AddressSearchState>();

  AddressDetails? _selectedCountry, _selectedState, _selectedCity;
  List<TextEditingController> controllers =
  List.generate(6, (index) => TextEditingController());

  var isChecked = false;

  //late Locale _locale;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    String cityStreetAddress = widget.profileDetails!.street;
    String city = '';
    String street = '';

    if(cityStreetAddress.contains('/s')){
      city = cityStreetAddress.split('/s')[0];
      List<String> address = cityStreetAddress.split('/s');
      address.removeAt(0);
      street = address.join(' ');
    }else{
      city = cityStreetAddress.split(',')[0];
      List<String> address = cityStreetAddress.split('/s');
      address.removeAt(0);
      street = address.join(' ');
    }

    if(widget.profileDetails!.city.isNotEmpty){
      city = widget.profileDetails!.city;
      street = widget.profileDetails!.street;
    }

    debugPrint('Details : ${widget.profileDetails!.toJson()['street']}');

    _selectedCountry = AddressDetails.init('0', widget.profileDetails!.country);
    _selectedState = AddressDetails.init('0', widget.profileDetails!.state);
    _selectedCity = AddressDetails.init('0', city);

    controllers[0] = TextEditingController(text: widget.profileDetails!.firstName);
    controllers[1] = TextEditingController(text: widget.profileDetails!.lastName);
    controllers[2] = TextEditingController(text: street);

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
    return BaseView<AccountViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppTheme.getAppBar(
                context: context,
                title: '',
                subTitle: '',
                enableBack: true),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
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
                            FormFields(
                              controllers,
                              //'Street',
                              AppLocalizations.of(context)!.street,
                              2,
                              //errorMessageFirst: 'Please enter street.',
                              errorMessageFirst: AppLocalizations.of(context)!
                                  .validation_street,
                            ),

                            // Padding(
                            //     padding: EdgeInsets.all(12.0),
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: <Widget>[
                            //         HeaderWidget(headerTitle: 'Country'),
                            //         const SizedBox(height: 10),
                            //         AddressSearch(
                            //           key: _addressCountryKey,
                            //           endPoint: 'Country',
                            //           controllers: controllers[1],
                            //           onChanged: (value){
                            //             setState(() {
                            //               _selectedCountry = value;
                            //             });
                            //
                            //           },
                            //         )
                            //       ],
                            //     )),
                            // Padding(
                            //     padding: EdgeInsets.all(12.0),
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: <Widget>[
                            //         HeaderWidget(headerTitle: 'State'),
                            //         const SizedBox(height: 10),
                            //         AddressOthers(
                            //           key: stateKey,
                            //           endPoint: 'State',
                            //           controllers: controllers[2],
                            //           seletedDetails: _selectedCountry ?? AddressDetails.init('', ''),
                            //           onChanged: (value){
                            //             setState(() {
                            //               _selectedState = value;
                            //             });
                            //           },
                            //         )
                            //       ],
                            //     )),
                            // Padding(
                            //     padding: EdgeInsets.all(12.0),
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: <Widget>[
                            //         HeaderWidget(headerTitle: 'City'),
                            //         const SizedBox(height: 10),
                            //         AddressOthers(
                            //           key: cityKey,
                            //           endPoint: 'City',
                            //           controllers: controllers[3],
                            //           seletedDetails: _selectedState ?? AddressDetails.init('', ''),
                            //           onChanged: (value){
                            //             setState(() {
                            //               _selectedCity = value;
                            //             });
                            //           },
                            //         )
                            //       ],
                            //     ))
                            Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SelectState(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4.0))),
                                    contentPadding: EdgeInsets.all(5.0)),
                                spacing: 25.0,
                                apiClient: Api(),
                                defaultCity: _selectedCity,
                                defaultState: _selectedState,
                                defaultCountry: _selectedCountry,
                                onCountryChanged: (value) {
                                  setState(() {
                                    _selectedCountry = value;
                                  });
                                },
                                onCountryTap: () =>
                                    displayMsg('You\'ve tapped on countries!'),
                                onStateChanged: (value) {
                                  setState(() {
                                    _selectedState = value;
                                  });
                                },
                                onStateTap: () =>
                                    displayMsg('You\'ve tapped on states!'),
                                onCityChanged: (value) {
                                  setState(() {
                                    _selectedCity = value;
                                  });
                                },
                                onCityTap: () =>
                                    displayMsg('You\'ve tapped on cities!'),
                              ),
                            )
                          ],
                        )),
                    Visibility(
                        visible: (_selectedCity != null &&
                            _selectedState != null &&
                            _selectedCountry != null &&
                            controllers[0].text.isNotEmpty),
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: UIHelper.smallSymmetricPadding(),
                              child: _getSignUpButton(buttonStyle, model,
                                  widget.profileDetails, controllers, isChecked),
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
      ProfileDetailsResponse? registerStep,
      List<TextEditingController> controllers,
      bool termsAndCondition) {
    print('${Theme.of(context).primaryColor}');

    Widget widget = CustomLoadingButton(
      defaultWidget: Text(AppLocalizations.of(context)!.button_continue,
          style: TextStyle(color: Colors.white, fontSize: 20)),
      progressWidget: ThreeSizeDot(),
      width: 114,
      height: 48,
      borderRadius: 24,
      animate: false,
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          var profileDetails = registerStep;
          profileDetails!.firstName = controllers[0].text;
          profileDetails.lastName = controllers[1].text;
          profileDetails.street = '${_selectedCity!.name!} ${controllers[2].text}' ;

          profileDetails.country = _selectedCountry!.id!;
          profileDetails.state = _selectedState!.id!;
          profileDetails.city = _selectedCity!.id!;
          var response = await model.updateUserProfile(registerStep);
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
                    title: AppLocalizations.of(context)!.nav_profile,
                    message: (response as ApiResponse).message!,
                    onPositivePressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      //model.dispose();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()),
                          (Route<dynamic> route) => route.isFirst);
                      // await LocalSharedPref().clearLoginDetails();
                      // goToLoginPage(context);
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

  displayMsg(String s) {
    debugPrint(s);
    // print(msg);
  }
}

class HeaderWidget extends StatelessWidget {
  String? headerTitle;

  HeaderWidget({Key? key, this.headerTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(headerTitle!,
        style: const TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold));
  }
}

class FormFields extends StatefulWidget {
  List<TextEditingController> controllers;
  String hint;
  String? errorMessageFirst, errorMessageSecond;
  bool isPhone, isEmail, isPassword, isConfirmPassword;
  int position = -1;

  FormFields(this.controllers, this.hint, this.position,
      {Key? key,
        this.errorMessageFirst,
        this.errorMessageSecond,
        this.isPhone = false,
        this.isEmail = false,
        this.isPassword = false,
        this.isConfirmPassword = false})
      : super(key: key) {}

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
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp("[A-Za-z\\s]"))
      ];
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
              style: InputTitleStyle,
              textInputAction: TextInputAction.next,
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