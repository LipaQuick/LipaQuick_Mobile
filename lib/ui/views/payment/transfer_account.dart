import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/accounts/add_account_model.dart';
import 'package:lipa_quick/core/models/banks/bank_details.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/ui/base_view.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/routing/app_router.dart';
import 'package:lipa_quick/ui/views/add_account/banks/bank_list.dart';
import 'package:lipa_quick/ui/views/dashboard/dashboard_page.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/views/payment/payment_screen.dart';

import '../../../core/app_states.dart';
import '../../shared/app_colors.dart';
import '../../shared/dialogs/dialogshelper.dart';
import '../../shared/text_styles.dart';
import '../../shared/ui_helpers.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_loading.dart';

class TransferAccountPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(
        builder: (_) => const TransferAccountPage(false));
  }

  final bool goToHome;

  const TransferAccountPage(this.goToHome, {Key? key}) : super(key: key);

  @override
  TransferAccountPageState createState() => TransferAccountPageState();
}

class TransferAccountPageState extends State<TransferAccountPage> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> controllers = List.generate(
      3, (index) => TextEditingController());
  List<BankDetails?> list = [];
  late AccountViewModel model;
  String? dob;
  BankDetails? _currentSelectedBank;

  var isChecked = false;

  var isGoBack = false;


  get voidCallback =>
          (BankDetails details) {
        Navigator.pop(context);
        dataCallBack(details);
      };

  final _borderBottomSheet = const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(10)
          , topRight: Radius.circular(10))
  );

  void dataCallBack(BankDetails details) {
    setState(() {
      _currentSelectedBank = details;
    });
  }

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
    EdgeInsets insets = UIHelper.smallSymmetricPadding();
    var height = MediaQuery
        .of(context)
        .size
        .height;
    final TextStyle headline2 = Theme
        .of(context)
        .textTheme
        .displaySmall!;
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
        fixedSize: const Size.fromHeight(45)
        , shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(45)),
    ));

    return BaseView<AccountViewModel>(
        builder: (BuildContext buildContext, AccountViewModel model,
            Widget? child) {
          return Scaffold(
              appBar: AppTheme.getAppBar(title: AppLocalizations.of(context)!
                  .transfer_money_title,
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
                                      AppLocalizations.of(context)!
                                          .recipient_account_number_hint,
                                      0,
                                      isAccountNumber: true,
                                      errorMessageFirst: AppLocalizations.of(
                                          context)!
                                          .validation_hint(
                                          AppLocalizations.of(context)!
                                              .recipient_account_number_hint),
                                      errorMessageSecond: AppLocalizations.of(
                                          context)!
                                          .validation_format_hint(
                                          AppLocalizations.of(context)!
                                              .recipient_account_number_hint),),
                                    FormFields(
                                        controllers,
                                        AppLocalizations.of(context)!
                                            .recipient_account_holder_name,
                                        1,
                                        errorMessageFirst:
                                        AppLocalizations.of(context)!
                                            .validation_hint(
                                            AppLocalizations.of(context)!
                                                .recipient_account_holder_name)),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Container(
                                        alignment: AlignmentDirectional
                                            .centerStart,
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .recipient_select_bank_hint,
                                            style: InputTitleStyle),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: InkWell(
                                          onTap: () {
                                            _showBankModelBottomSheet();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(8),
                                              border: Border.all(
                                                  color: const Color(
                                                      0xff999999), width: 1),
                                              color: Colors.white,
                                            ),
                                            padding:
                                            UIHelper
                                                .mediumAllSymmetricPadding(),
                                            alignment:
                                            AlignmentDirectional.centerStart,
                                            child: Text(
                                              _currentSelectedBank == null
                                                  ? AppLocalizations.of(
                                                  context)!
                                                  .recipient_select_bank_hint
                                                  : _currentSelectedBank!.name!
                                                  .replaceAll(
                                                  RegExp('\n'), ' '),
                                              style: TextStyle(
                                                color: _currentSelectedBank ==
                                                    null
                                                    ? const Color(0xff5d5c5d)
                                                    : appSurfaceBlack,
                                                fontSize: _currentSelectedBank ==
                                                    null ? 14 : 19,
                                              ),
                                            ),
                                          ),
                                        )),
                                    const SizedBox(height: 10),
                                    FormFields(
                                      controllers,
                                      AppLocalizations.of(context)!
                                          .recipient_swift_code_hint,
                                      2,
                                      isSwiftCode: true,
                                      errorMessageFirst: AppLocalizations.of(
                                          context)!
                                          .validation_hint(
                                          AppLocalizations.of(context)!
                                              .recipient_swift_code_hint),
                                      errorMessageSecond: AppLocalizations.of(
                                          context)!
                                          .validation_format_hint(
                                          AppLocalizations.of(context)!
                                              .recipient_swift_code_hint),)
                                  ],
                                ),
                              ),
                            )),
                        Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            height: height / 13,
                            padding: EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              style: style,
                              onPressed: () {

                                if(_formKey.currentState!.validate()){
                                  if(_currentSelectedBank != null){
                                    AddAccountModel? accountModel = getAddAccountModel(controllers
                                        , _currentSelectedBank, true);
                                    openAmountBottomSheet(accountModel, model);
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(AppLocalizations.of(context)!.select_bank_accout),
                                          showCloseIcon: true),
                                    );
                                  }
                                }
                              },
                              child: Text(AppLocalizations.of(context)!
                                  .button_continue,
                                  style: GoogleFonts.poppins(
                                      textStyle: headline2.copyWith(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white))),
                            )
                        )
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Visibility(
                        visible: model.state == ViewState.Loading,
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: MediaQuery
                              .of(context)
                              .size
                              .height,
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
              ));
        }, onModelReady: (model) {
      print('Model is Ready');
    });
  }


  _showBankModelBottomSheet() {
    return showModalBottomSheet<BankDetails>(
      context: context,
      //backgroundColor: const Color(0xFFF7F7F7),
      backgroundColor: const Color(0xF7F6F6F6),
      shape: _borderBottomSheet,
      builder: (BuildContext context) {
        return BankPage(voidCallback, AppLocalizations.of(context)!.recipient_select_bank_hint,);
      },
    );
  }

  Widget _getAddAccountButton(ButtonStyle style, AccountViewModel model
      , List<TextEditingController> controllers, BankDetails? _currentSelected,
      bool isSelected) {
    print('${Theme
        .of(context)
        .primaryColor}');


    var addAccountModel = getAddAccountModel(
        controllers, _currentSelected, isSelected);

    Widget widget = CustomLoadingButton(
        defaultWidget: Text(AppLocalizations.of(context)!.button_continue,
            style: TextStyle(color: Colors.white, fontSize: 20)),
        progressWidget: ThreeSizeDot(),
        width: double.infinity,
        height: 45,
        borderRadius: 24,
        animate: false,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            var response = await model.AddAccount(addAccountModel);
            return () {
              if (response == null) {
                CustomDialog(DialogType.FAILURE)
                    .buildAndShowDialog(context: context,
                    title: AppLocalizations.of(context)!.error_hint,
                    message: model.errorMessage,
                    onPositivePressed: () {
                      previousPage(false);
                    }
                    ,
                    buttonPositive: AppLocalizations.of(context)!.button_ok);
              }
              else {
                if (response.status!) {
                  var dialog = CustomDialog(DialogType.SUCCESS);
                  dialog.buildAndShowDialog(context: context,
                      title: AppLocalizations.of(context)!.transfer_money_title,
                      message: response.message,
                      onPositivePressed: () {
                        previousPage(true);
                      },
                      buttonPositive: AppLocalizations.of(context)!.button_ok);
                } else {
                  //print('API Response in View');
                  CustomDialog(DialogType.FAILURE)
                      .buildAndShowDialog(context: context,
                      title: AppLocalizations.of(context)!.error_hint,
                      message: model.errorMessage
                      ,
                      onPositivePressed: () {
                        previousPage(false);
                      }
                      ,
                      buttonPositive: AppLocalizations.of(context)!.button_ok);
                }
              }
            };
          }
        }
    );
    return widget;
  }

  String? title, message;

  void previousPage(bool reload) {
    // isGoBack = true;
    Navigator.of(context, rootNavigator: true).pop();
    if (widget.goToHome) {
      Navigator.of(context, rootNavigator: true).pop(
          MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      if (reload) {
        Navigator.of(context).pop(reload);
      }
    }
  }

  void openAmountBottomSheet(AddAccountModel? addAccount, AccountViewModel model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: appSurfaceWhite,
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom,
            ),
            child: TransferConfirmationSheet.confirm(addAccount!, model),
          ),
        );
      },
    );
  }
}

AddAccountModel? getAddAccountModel(List<TextEditingController> controllers,
    BankDetails? currentSelected, bool isSelected) {
  if (currentSelected == null) {
    return null;
  }
  return AddAccountModel(
      bank: currentSelected.id!,
      bankName: currentSelected.name!,
      accountNumber: controllers[0].text,
      accountHolderName: controllers[1].text,
      swiftCode: controllers[2].text,
      primary: isSelected
  );
}

class TransferConfirmationSheet extends StatelessWidget {

  AddAccountModel? addAccount;
  AccountViewModel? model;

  TransferConfirmationSheet.confirm(this.addAccount, this.model);

  @override
  Widget build(BuildContext context) {
    final TextStyle headline2 = Theme.of(context).textTheme.displayMedium!;
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 17, color: appSurfaceWhite),
        backgroundColor: appGreen400,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ));
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .transfer_confirm_title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(
                  Icons.cancel,
                  color: appGreen400,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
          SizedBox(height: 20),
          _buildDetailRow(AppLocalizations.of(context)!
              .recipient_account_holder_name, addAccount!.accountHolderName!),
          _buildDetailRow(AppLocalizations.of(context)!
              .account_number_hint, addAccount!.accountNumber!),
          _buildDetailRow(AppLocalizations.of(context)!
              .bank_name_hint, addAccount!.bankName!),
          SizedBox(height: 30),
          Container(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style: style,
              onPressed: () {
                Navigator.pop(context);
                ContactsAPI contactsAPI = ContactsAPI('', addAccount!.accountHolderName
                    , '', addAccount!.bank
                    , addAccount!.accountHolderName
                    , addAccount!.swiftCode
                    , addAccount!.accountNumber);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          true,
                          contact: contactsAPI,
                        )));
              },

              child: Text(AppLocalizations.of(context)!
                  .confirm_pay_hint),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: TextStyle(fontSize: 16)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class FormFields extends StatefulWidget {
  List<TextEditingController> controllers;
  String hint;
  String? errorMessageFirst, errorMessageSecond;
  bool isAccountNumber, isSwiftCode;
  int position = -1;

  FormFields(this.controllers, this.hint, this.position,
      {Key? key,
        this.errorMessageFirst,
        this.errorMessageSecond,
        this.isAccountNumber = false,
        this.isSwiftCode = false,
      })
      : super(key: key) {}

  @override
  State<StatefulWidget> createState() =>
      FormFieldState(controllers, hint, position,
          errorMessageFirst: errorMessageFirst,
          errorMessageSecond: errorMessageSecond,
          isAccount: isAccountNumber,
          isSwiftCode: isSwiftCode);
}

class FormFieldState extends State<FormFields> {
  List<TextEditingController> controllers;
  String hint = '';
  String? errorMessageFirst, errorMessageSecond;
  bool isAccountNumber = false,
      isSwiftCode = false;

  int position = -1;
  var _isObscure = false;

  var insets = UIHelper.mediumSymmetricPadding();

  FormFieldState(this.controllers, this.hint, this.position,
      {String? errorMessageFirst,
        String? errorMessageSecond,
        bool isAccount = false,
        bool isSwiftCode = false,}) {
    this.errorMessageFirst = errorMessageFirst;
    this.errorMessageSecond = errorMessageSecond;
    this.isAccountNumber = isAccount;
    this.isSwiftCode = isSwiftCode;
  }

  @override
  Widget build(BuildContext context) {
    var outlineStyle = const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)));
    var inputDecoration;
    inputDecoration = InputDecoration(
      border: outlineStyle,
      hintText: hint,
    );
    var inputFormatters;
    if (isAccountNumber) {
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[0-9]"))];
    } else if (isSwiftCode) {
      inputFormatters =
      [FilteringTextInputFormatter.allow(RegExp("[0-9A-Za-z]"))];
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
            Text(hint, style: InputTitleStyle),
            const SizedBox(height: 10),
            TextFormField(
              controller: controllers[position],
              autofocus: true,
              cursorColor: Theme
                  .of(context)
                  .primaryColorDark,
              style: Theme
                  .of(context)
                  .textTheme
                  .copyWith(
                  headlineSmall: Theme
                      .of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: appSurfaceBlack, fontSize: 16))
                  .headlineSmall,
              inputFormatters: inputFormatters,
              obscureText: _isObscure,
              maxLength: isAccountNumber ? 18 : isSwiftCode ? 11 : 100,
              textInputAction: TextInputAction.next,
              keyboardType: isAccountNumber
                  ? TextInputType.number
                  : isSwiftCode
                  ? TextInputType.emailAddress
                  : TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return errorMessageFirst;
                }

                if (isSwiftCode) {
                  if (value.length < 8) {
                    return errorMessageSecond;
                  }
                }

                if (isAccountNumber) {
                  if (value.length < 9) {
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
