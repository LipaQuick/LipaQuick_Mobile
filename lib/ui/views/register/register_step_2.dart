import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/models/IdentityResponse.dart';
import 'package:lipa_quick/core/models/resgister_steps_data.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/base_view.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/text_styles.dart';
import 'package:lipa_quick/ui/shared/ui_helpers.dart';
import 'package:lipa_quick/ui/shared/ui_styles.dart';
import 'dart:math';
import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/views/register/register_step_3.dart';

class RegisterStepTwo extends StatefulWidget {

  RegisterStep? registerStep;

  RegisterStepTwo({Key? key, this.registerStep}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

enum Gender { Male, Female, Others }

class RegisterPageState extends State<RegisterStepTwo> {
  final _formKey = GlobalKey<FormState>();
  final _formImagePicker = GlobalKey<ImagePickerState>();
  List<TextEditingController> controllers =
      List.generate(1, (index) => TextEditingController());
  Gender selectedGender = Gender.Male;
  IdentityDetails? _identityDetails = IdentityDetails();
  List<IdentityDetails?> list = [];
  AccountViewModel mainModel = locator<AccountViewModel>();

  late Locale _locale;

  String? dob;

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
   // mainModel.dispose();
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
    AssetImage image = AssetImage(Assets.icon.lauchericon.path);
    Image images =
    Image(image: image, width: 200, height: 80, fit: BoxFit.cover);

    var height = MediaQuery.of(context).size.height;

    return BaseView<AccountViewModel>(
        builder: (BuildContext context, AccountViewModel model, Widget? child) {
      return Scaffold(
          appBar: AppTheme.getAppBar(context: context, title:AppLocalizations.of(context)!.step_2,subTitle: "",enableBack: true),
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
                            Expanded(child: Container(child: welcomeMsg), flex: 1,)
                          ],
                        )),
                    Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: UIHelper.mediumSymmetricPadding(),
                                  child: Container(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(AppLocalizations.of(context)!.id_type, style: InputTitleStyle),
                                  ),
                                ),
                                Wrap(
                                  direction: Axis.horizontal,
                                  children: [_showDropDownField()],
                                ),
                                FormFields(controllers, AppLocalizations.of(context)!.id_number, 0,
                                    errorMessageFirst:
                                    AppLocalizations.of(context)!.validation_id_number, identityDetails: _identityDetails),
                                Padding(
                                  padding: UIHelper.mediumSymmetricPadding(),
                                  child: Container(
                                    alignment: AlignmentDirectional.centerStart,
                                    child:
                                    Text(AppLocalizations.of(context)!.id_photo, style: InputTitleStyle),
                                  ),
                                ),
                                Stack(
                                  alignment: const Alignment(1, 1),
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width / 2.1,
                                      child:  Card(
                                        color: backgroundColor,
                                        child: ImagePickerWidget(key: _formImagePicker, function: imageSelected,),
                                      ),
                                    )
                                  ],
                                )
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
                                      visible: (_formKey.currentState != null && _formKey.currentState!.validate() && _formImagePicker.currentState?._selectedImage != null),
                                      child: Padding(
                                        padding: insets,
                                        child: ElevatedButton(
                                          style: buttonStyle,
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              if(_formImagePicker.currentState?._selectedImage != null){
                                                debugPrint('Inside Selected Image');
                                                if(_identityDetails != null){
                                                  debugPrint('_identityDetails');
                                                  _identityDetails?.setIdentityPhoto(_formImagePicker.currentState!._selectedImage!);
                                                  widget.registerStep?.details = _identityDetails;
                                                  widget.registerStep?.IdNumber = controllers[0].text;
                                                  print('Step 2 ${widget.registerStep.toString()}');
                                                  // context.push(LipaQuickAppRouteMap.registerStep3
                                                  //     , extra: widget.registerStep);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              RegisterThirdStep(registerStep: widget.registerStep)));
                                                }else{
                                                  debugPrint('Inside select id');
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    //'Select your ID-Card'
                                                    SnackBar(content: Text(AppLocalizations.of(context)!.validation_select_id_hint)),
                                                  );
                                                }
                                              }else{
                                                debugPrint('Inside capture ID Photo.');
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  //Please pick or capture ID Photo.
                                                  SnackBar(content: Text(AppLocalizations.of(context)!.validation_id_photo)
                                                    , elevation: 200,),
                                                );
                                              }

                                            }
                                          },
                                          child: Text(AppLocalizations.of(context)!.btn_next),
                                        ),
                                      ),
                                    ),)
                              ],
                            )
                          ],
                        ))
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
      print('Model is Ready');
      model.getIdentity().then((value) => {
            if (value == null)
              {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(model.errorMessage)),
                )
              }
            else
              {
                if (value.status!)
                  {list = value.data!}
                else
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(model.errorMessage)),
                    )
                  }
              }
          });
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

  imageSelected() {
    setState(() {

    });
  }
}

class ImagePickerWidget extends StatefulWidget {
  final VoidCallback function;
  const ImagePickerWidget({Key? key, required this.function}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ImagePickerState();
}

class ImagePickerState extends State<ImagePickerWidget>{
  XFile? _selectedImage;
  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();

  void _setImageFileListFromFile(XFile? value) {
    _selectedImage = (value == null) ? null : value;
    widget.function();
  }


  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 25
      );
      setState(() {
        _setImageFileListFromFile(pickedFile);
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    };
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    setState(() {
      if (response.files == null) {
        _setImageFileListFromFile(response.file);
      } else {
        _selectedImage = response.file;
        widget.function();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<void>(
          future: retrieveLostData(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Text(
                  //'You have not yet picked an image.',
                  AppLocalizations.of(context)!.validation_pick_image_msg,
                  textAlign: TextAlign.center,
                );
              case ConnectionState.done:
                return _handlePreview();
              default:
                if (snapshot.hasError) {
                  return Text(
                    'Pick image error: ${snapshot.error}}',
                    textAlign: TextAlign.center,
                  );
                } else {
                  return Text(
                    AppLocalizations.of(context)!.validation_pick_image_msg,
                    textAlign: TextAlign.center,
                  );
                }
            }
          },
        )
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Semantics(
            label: 'image_picker_example_from_gallery',
            child: FloatingActionButton.small(
              onPressed: () {
                _onImageButtonPressed(ImageSource.gallery);
              },
              heroTag: 'image0',
              tooltip: 'Pick Image from gallery',
              child: const Icon(Icons.photo, color: appSurfaceWhite),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: FloatingActionButton.small(
              onPressed: () {
                _onImageButtonPressed(ImageSource.camera);
              },
              heroTag: 'image2',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt, color: appSurfaceWhite),
            ),
          )
        ],
      ),
    );
  }

  Widget _handlePreview() {
    if (_selectedImage != null) {
      return Semantics(
        label: 'image_picker_example_picked_images',
        child: Semantics(
          label: 'image_picker_example_picked_image',
          child: Image.file(File(_selectedImage!.path)),
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        AppLocalizations.of(context)!.validation_pick_image_msg,
        textAlign: TextAlign.center,
      );
    }
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
              autofocus: false,
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
                      : (position == 0 && widget.identityDetails != null && widget.identityDetails!.alphaNumeric != null)
                          ? widget.identityDetails!.alphaNumeric!? TextInputType.text:TextInputType.number
                          : TextInputType.text,
              maxLength: (position == 0 && widget.identityDetails != null && widget.identityDetails!.maxLength != null)?widget.identityDetails!.maxLength!:50,
              onChanged: (String value){
                if(position == 0 && widget.identityDetails != null && widget.identityDetails!.regex != null){
                  if(widget.identityDetails!.regex!.isNotEmpty){
                    var regex = RegExp(widget.identityDetails!.regex!);
                    if(regex.hasMatch(value)){
                      //'Invalid value has been entered, please enter valid $hint'
                      print('Validating Regex');
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                  }
                }
              },
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

                if(position == 0 && widget.identityDetails != null && widget.identityDetails!.regex != null){
                  if(widget.identityDetails!.regex!.isNotEmpty){
                    var regex = RegExp(widget.identityDetails!.regex!);
                    print('Validating Regex');
                    if(!regex.hasMatch(value)){
                      //'Invalid value has been entered, please enter valid $hint'
                      return AppLocalizations.of(context)!.validation_identity_error(hint);
                    }
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
