import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/managers/language/language_bloc.dart';
import 'package:lipa_quick/core/models/accounts/account_model.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/app_router/app_route_model.dart';
import 'package:lipa_quick/core/models/cards/cards_model.dart';
import 'package:lipa_quick/core/models/discount/discount_model.dart';
import 'package:lipa_quick/core/models/payment/default_payments.dart';
import 'package:lipa_quick/core/models/payment/payment.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/core/view_models/discount_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/base_view.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/image_util.dart';
import 'package:lipa_quick/ui/shared/sucess_pages.dart';
import 'package:lipa_quick/ui/shared/text_styles/text_style.dart';
import 'package:lipa_quick/ui/views/add_account/account_list/account_item.dart';
import 'package:lipa_quick/ui/views/cards/card_list/card_item.dart';
import 'package:lipa_quick/ui/views/dashboard/dashboard_page.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/views/payment/discount_listing.dart';
import 'package:lipa_quick/ui/views/payment/payment_methods/list_default_methods.dart';
import 'package:lipa_quick/ui/views/payment/select_account.dart';
import 'package:lipa_quick/ui/views/payment/transaction_summary.dart';
import 'package:lipa_quick/ui/views/register/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/contacts/contacts.dart';
import '../../shared/app_colors.dart';
import '../../shared/dialogs/dialogshelper.dart';
import '../../shared/ui_helpers.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_loading.dart';

class PaymentPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => PaymentPage(false));
  }

  final bool goToHome;
  ContactsAPI? contact;

  PaymentPage(this.goToHome, {Key? key, this.contact}) : super(key: key);

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> controllers =
  List.generate(2, (index) => TextEditingController());
  late AccountViewModel paymentViewModel;
  String? dob;
  dynamic _currentSelectedBank;
  DiscountViewModel discountViewModel = locator<DiscountViewModel>();
  final StreamController<dynamic> discountController = StreamController();

  var isChecked = false;

  var isGoBack = false;

  var _isBankSelection = false;

  String? currency = "Rwf";

  String amount = '0';

  DiscountItems? currentSelectedDiscount;

  List<DiscountItems> discounts = [
    DiscountItems(
        discountCode: 'ABCDEF',
        flatAmount: 10,
        amountPercentage: 10,
        minAmount: 100,
        maxAmount: 200,
        amountPercentageActive: false),
    DiscountItems(
        discountCode: 'BCDEFG',
        flatAmount: 9,
        amountPercentage: 6,
        minAmount: 200,
        maxAmount: 300,
        amountPercentageActive: true),
    DiscountItems(
        discountCode: 'CDEFGH',
        flatAmount: 7,
        amountPercentage: 4,
        minAmount: 300,
        maxAmount: 400,
        amountPercentageActive: true),
    DiscountItems(
        discountCode: 'DEFGHI',
        flatAmount: 11,
        amountPercentage: 11,
        minAmount: 400,
        maxAmount: 500,
        amountPercentageActive: false)
  ];

  get voidCallback =>
          (dynamic details) {
        Navigator.pop(context);
        dataCallBack(details!);
      };

  final _borderBottomSheet = const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10)));

  void dataCallBack(dynamic details) {
    setState(() {
      _currentSelectedBank = details;
      _isBankSelection = !_isBankSelection;
    });
  }

  @override
  void initState() {
    //discountController = StreamController();
    super.initState();
  }

  @override
  void dispose() {
    for (var element in controllers) {
      element.dispose();
    }
    super.dispose();
  }

  Future<bool> _onBackPressed(bool canPop) {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(true);

    return completer.future;
  }


  @override
  Widget build(BuildContext context) {
    final state = BlocProvider
        .of<LanguageBloc>(context)
        .state;
    var height = MediaQuery
        .of(context)
        .size
        .height;
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
        fixedSize: const Size.fromHeight(45));
    var padding = const EdgeInsets.all(0.0);
    var color = appGreen400;
    var shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    return BaseView<AccountViewModel>(builder:
        (BuildContext buildContext, AccountViewModel model, Widget? child) {
      return PopScope(
          onPopInvoked: _onBackPressed,
          canPop: true,
          child: Scaffold(
            appBar: AppTheme.getAppBar(
                title: AppLocalizations.of(context)!.send_money_title,
                subTitle: "",
                enableBack: true,
                context: buildContext),
            body: Stack(children: <Widget>[
              SingleChildScrollView(
                child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width / 2,
                            child: Text(
                                AppLocalizations.of(context)!.amount_title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width / 2,
                            child: TextFormField(
                                controller: controllers[0],
                                autofocus: false,
                                cursorColor: Theme
                                    .of(context)
                                    .primaryColorDark,
                                textAlign: TextAlign.center,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .copyWith(
                                    titleMedium: Theme
                                        .of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                        color: appSurfaceBlack,
                                        fontSize: 32))
                                    .titleMedium,
                                inputFormatters: [
                                  CurrencyInputFormatter(
                                      leadingSymbol:
                                      state.selectedLanguage.currency!,
                                      useSymbolPadding: true,
                                      mantissaLength: 0,
                                      maxTextLength:
                                      7 // the length of the fractional side
                                  )
                                ],
                                textInputAction: TextInputAction.done,
                                keyboardType:
                                const TextInputType.numberWithOptions(
                                  signed: true,
                                ),
                                onChanged: (String value) async {
                                  amount = value;
                                  checkAndloadDiscounts(amount);
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                    '${state.selectedLanguage.currency!} 0')),
                          ),
                          Container(
                            height: MediaQuery
                                .of(context)
                                .size
                                .height / 15,
                          ),
                          ReceiverWidget(contact: widget.contact),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: TextFormField(
                              controller: controllers[1],
                              autofocus: false,
                              cursorColor: Theme
                                  .of(context)
                                  .primaryColorDark,
                              textAlign: TextAlign.start,
                              maxLength: 50,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleSmall,
                              // inputFormatters: [
                              //   FilteringTextInputFormatter.allow(RegExp("[a-z]")),
                              //   FilteringTextInputFormatter.allow(RegExp("[A-Z]"))
                              // ],
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  hintText: 'Description',
                                  border: InputBorder.none),
                            ),
                          ),
                          FutureBuilder(
                              future: checkAndloadDiscounts(amount),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                debugPrint('Has error: ${snapshot.hasError}');
                                debugPrint('Has data: ${snapshot.hasData}');
                                debugPrint('Snapshot Data ${snapshot.data}');
                                if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }
                                if (snapshot.hasData) {
                                  if (snapshot.data is DiscountResponse &&
                                      ((snapshot.data) as DiscountResponse)
                                          .data !=
                                          null) {
                                    return Column(
                                      children: [
                                        Visibility(
                                          visible:
                                          currentSelectedDiscount != null,
                                          child: ListTile(
                                            leading:
                                            Icon(Icons.discount_rounded),
                                            title: Text(
                                                '${AppLocalizations.of(context)!
                                                    .discount_applied(
                                                    currentSelectedDiscount
                                                        ?.discountCode ??
                                                        '')}'),
                                            subtitle: Text(
                                                '${AppLocalizations.of(context)!
                                                    .discount_saving(
                                                    currentSelectedDiscount
                                                        ?.flatAmount!.toDouble() ?? 0)}'),
                                            trailing: TextButton.icon(
                                                onPressed: () {
                                                  setState(() {
                                                    currentSelectedDiscount =
                                                    null;
                                                  });
                                                },
                                                icon: Icon(Icons.clear),
                                                label: Text(AppLocalizations.of(
                                                    context)!
                                                    .delete_hint)),
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                          currentSelectedDiscount == null,
                                          child: ListTile(
                                            leading: const Icon(
                                                Icons.discount_rounded),
                                            title: Text(
                                                AppLocalizations.of(context)!
                                                    .apply_discount),
                                            trailing: TextButton(
                                              child: Text(
                                                'Select',
                                                style: ThemeText.titleTextStyle,
                                              ),
                                              onPressed: () async {
                                                //TODO Open Discount Listing Page and Get Back the Discount Instance
                                                var data = (snapshot.data
                                                as DiscountResponse)
                                                    .data ??
                                                    [];
                                                if (data.isNotEmpty) {
                                                  var result =
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                          context) =>
                                                              DiscountListingPage(
                                                                data,
                                                                currentSelectedDiscount:
                                                                currentSelectedDiscount,
                                                              )));
                                                  if (result is DiscountItems) {
                                                    debugPrint(
                                                        'Result Data:${result
                                                            .toJson()}');
                                                    setState(() {
                                                      currentSelectedDiscount =
                                                          result;
                                                    });
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  } else {
                                    return const SizedBox(height: 1);
                                  }
                                }
                                if (snapshot.connectionState !=
                                    ConnectionState.done) {
                                  return const ListTile(
                                    title: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return const SizedBox(height: 1);
                              }),
                          SizedBox(
                            height: MediaQuery
                                .of(context)
                                .size
                                .height / 18,
                          ),
                          Align(
                            child: Text(
                              'Pay From',
                              style: ThemeText.subHeadingTextStyle,
                              textAlign: TextAlign.left,
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          InkWell(
                            onTap: () {
                              _showBankModelBottomSheet(_currentSelectedBank);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: UIHelper.smallSymmetricPadding(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Radio(
                                    value: 1,
                                    groupValue: 1,
                                    activeColor: appGreen400,
                                    onChanged: null,
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: [
                                          getPaymentMethodView(
                                              _currentSelectedBank)
                                        ],
                                      )),
                                  IconButton(
                                      icon: Icon(
                                        _isBankSelection
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons.keyboard_arrow_up_rounded,
                                      ),
                                      onPressed: () {
                                        _showBankModelBottomSheet(
                                            _currentSelectedBank);
                                        setState(() {
                                          _isBankSelection = !_isBankSelection;
                                        });
                                      })
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 65,
                  color: Colors.white,
                  padding: EdgeInsets.all(6.0),
                  margin: EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        proceedToSummaryPage(style, model, controllers,
                            widget.contact, _currentSelectedBank, isChecked, currentSelectedDiscount);
                      },
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(padding),
                          backgroundColor: MaterialStateProperty.all(color),
                          shape: MaterialStateProperty.all(shape),
                          elevation: MaterialStateProperty.all(5.0)),
                      child: Text(AppLocalizations.of(context)!.pay_title,
                          style: TextStyle(color: Colors.white, fontSize: 20))),
                ),
              )
            ]),
          ));
    }, onModelReady: (model) async {
      debugPrint('Model is Ready');
      this.paymentViewModel = model;
      paymentViewModel.isUserActive(
          userPhoneNumber: widget.contact!.phoneNumber).then((value) =>
      {
        print('Account is: ${value}'),
        if (!value)
          {
            CustomDialog(DialogType.INFO).buildAndShowDialog(
                context: context,
                title: 'Account',
                message:
                'Your account is not active. Please connect with Support Team',
                onPositivePressed: () {
                  Navigator.of(context, rootNavigator:true).pop();
                  Navigator.of(context).pop();
                },
                buttonPositive: 'OK')
          }
      });
      //discountController.add()
    });
  }

  _showBankModelBottomSheet(dynamic preSelected) {
    return showModalBottomSheet<dynamic>(
      context: context,
      //backgroundColor: const Color(0xFFF7F7F7),
      backgroundColor: const Color(0xF7F6F6F6),
      shape: _borderBottomSheet,
      builder: (BuildContext context) {
        return DefaultPaymentDropDown(
            voidCallback: voidCallback, preselected: preSelected);
      },
    );
  }

  Future<void> proceedToSummaryPage(ButtonStyle style,
      AccountViewModel model,
      List<TextEditingController> controllers,
      ContactsAPI? receivers,
      dynamic _currentSelected,
      bool isSelected, DiscountItems? currentSelectedDiscount) async {
    //print('${Theme.of(context).primaryColor}');

    // if (controllers.first.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar( SnackBar(
    //     content: Text(AppLocalizations.of(context)!.enter_amount),
    //   ));
    //   return;
    // }
    // if (_currentSelected == null) {
    //   ScaffoldMessenger.of(context).showSnackBar( SnackBar(
    //     content: Text(AppLocalizations.of(context)!.select_bank_accout),
    //   ));
    //   return;
    // }
    String userID = await model.getUserId();
    var amount = controllers[0].text.substring(1).replaceAll(r',', '').trim();
    print('Amount ${amount} -- ${amount.length} -- ${int.parse(amount)}');
    if (amount.length < 1 || int.parse(amount) == 0) {
      CustomDialog(DialogType.INFO).buildAndShowDialog(
          context: context,
          title: AppLocalizations.of(context)!.error,
          message: 'Please enter amount!',
          onPositivePressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          buttonPositive: AppLocalizations.of(context)!.button_ok);
      return;
    }
    if (_currentSelected == null) {
      CustomDialog(DialogType.INFO).buildAndShowDialog(
          context: context,
          title: AppLocalizations.of(context)!.error,
          message: 'Please select payment method.',
          onPositivePressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          buttonPositive: AppLocalizations.of(context)!.button_ok);
      return;
    } else {
      var addAccountModel = await getPaymentModel(
          controllers, receivers, _currentSelected, isSelected, userID, currentSelectedDiscount);

      TransactionPageItems items = TransactionPageItems(addAccountModel, widget.contact);
      // context.go(LipaQuickAppRouteMap.payment_summary, extra: items);


      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (context) =>
              TransactionSummaryPage(
                paymentRequest: addAccountModel,
                contact: widget.contact,
              )));
    }
  }

  String? title, message;

  void previousPage(bool reload) {
    // isGoBack = true;
    Navigator.of(context, rootNavigator: true).pop();
    if (widget.goToHome) {
      Navigator.of(context, rootNavigator: true)
          .pop(MaterialPageRoute(builder: (context) => const HomePage()));
    } else {
      if (reload) {
        Navigator.of(context).pop(reload);
      }
    }
  }

  Future<dynamic> checkAndloadDiscounts(String value) async {
    debugPrint(value);
    final Completer<dynamic> completer = Completer<dynamic>();
    if (value.isEmpty || value.length < 3) {
      completer.complete(DiscountResponse());
      return completer.future;
    }
    var userId = await AccountViewModel().getUserId();
    var amount = 0;
    try {
      debugPrint(value);
      var amt = value.replaceAll(r',', '').replaceAll(r'$', '').trim();
      amount = int.parse(amt);
      debugPrint('Amount: ${amount}');
    } catch (e) {
      //debugPrint(e);
    }
    return await discountViewModel.getDiscounts(userId, amount);
  }

  Widget getPaymentMethodView(currentSelectedBank) {
    if (currentSelectedBank is AccountDetails) {
      return PaymentAccountListItem(currentSelectedBank as AccountDetails);
    } else if (currentSelectedBank is MTNWalletDetails) {
      return PaymentWalletView(currentSelectedBank as MTNWalletDetails);
    } else if (currentSelectedBank is CardDetailsModel) {
      return PaymentCardListItem(currentSelectedBank as CardDetailsModel);
    } else {
      return Container();
    }
  }

  initiatePaymentHere(PaymentRequest addAccountModel,
      ContactsAPI? receivers) async {
    paymentViewModel.setState(ViewState.Loading);

    var response = await paymentViewModel.pay(addAccountModel);
    if (response == null) {
      paymentViewModel.setState(ViewState.Idle);
      CustomDialog(DialogType.FAILURE).buildAndShowDialog(
          context: context,
          title: 'Error',
          message: paymentViewModel.errorMessage,
          onPositivePressed: () {
            previousPage(false);
          },
          buttonPositive: 'OK');
    } else {
      paymentViewModel.setState(ViewState.Idle);
      if (response is ApiResponse) {
        if (response.status!) {
          UserDetails? userdetails;
          await fetchDetails().then((value) =>
          {
            userdetails = value,
          });
          var successpage = SuccessPage(
              icon: Icons.check_circle,
              positiveButton: "Feedback",
              negativeButton: "Skip",
              negativeCallback: () {},
              senderDetails: userdetails!,
              receiverDetails: receivers!,
              tranReferenceNumber: addAccountModel.transactionId!,
              positiveCallback: () {
                previousPage(true);
              });
          showGeneralDialog(
            context: context,
            pageBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,) {
              return successpage;
            },
          );
        } else {
          //print('API Response in View');
          //var errorMessage = model.
          CustomDialog(DialogType.FAILURE).buildAndShowDialog(
              context: context,
              title: 'Error',
              message: paymentViewModel.errorMessage,
              onPositivePressed: () {
                previousPage(false);
              },
              buttonPositive: 'OK');
        }
      } else if (response is APIException) {
        CustomDialog(DialogType.FAILURE).buildAndShowDialog(
            context: context,
            title: 'Error',
            message: paymentViewModel.errorMessage,
            onPositivePressed: () {
              previousPage(false);
            },
            buttonPositive: 'OK');
      }
    }
  }
}


class ReceiverWidget extends StatelessWidget {
  const ReceiverWidget({
    super.key,
    required this.contact,
  });

  final ContactsAPI? contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: appGreen400)),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery
              .of(context)
              .size
              .width / 6,
          child: Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  child: CircleAvatar(
                    backgroundColor: appGrey100,
                    child: contact!.profilePicture != null &&
                        contact!.profilePicture!.isNotEmpty
                        ? ImageUtil().imageFromBase64String(
                        contact!.getProfilePictureLogo(), 50, 50)
                        : const Icon(Icons.question_mark),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          contact!.name!,
                          style: GoogleFonts.poppins(
                            color: appSurfaceBlack,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          contact!.phoneNumber!,
                          style: GoogleFonts.poppins(
                            color: const Color(0xff535763),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

Future<UserDetails> fetchDetails() async {
  var prefs = await SharedPreferences.getInstance();
  final Completer<UserDetails> completer = Completer<UserDetails>();
  //print('Checking User Details ${prefs.getString('userDetails')}');
  // print('Null Preference, Loading Default EN');
  String rawData = prefs.getString("userDetails")!;
  debugPrint('Raw Data debugPrint: $rawData');
  var data = jsonDecode(rawData);
  debugPrint('JSON Decode Data Print: $data');
  //print(data);
  var userModel = UserDetails.fromJson(data);
  completer.complete(userModel);
  return completer.future;
}

Future<PaymentRequest?> getPaymentModel(List<TextEditingController> controllers,
    ContactsAPI? receivers,
    dynamic currentSelected,
    bool isSelected,
    String userID, DiscountItems? currentSelectedDiscount) async {
  if (currentSelected == null) {
    return null;
  }
  UserDetails? userdetails;
  await fetchDetails().then((value) =>
  {
    userdetails = value,
  });

  var sender = null;
  if (currentSelected is AccountDetails) {
    sender = SenderModel(
        userID,
        currentSelected.accountHolderName,
        userdetails!.phoneNumber,
        currentSelected.accountNumber,
        currentSelected.swiftCode,
        'Address');
  }
  else if (currentSelected is MTNWalletDetails) {
    sender = SenderModel(
        userID,
        userdetails!.firstName + " " + userdetails!.lastName,
        userdetails!.phoneNumber,
        null,
        null,
        'Address');
  }
  else {
    sender = SenderModel(
        userID,
        (currentSelected as CardDetailsModel).cardNumber,
        userdetails!.phoneNumber,
        (currentSelected as CardDetailsModel).nameOnCard,
        (currentSelected as CardDetailsModel).validTill,
        'Address');
  }
  var receiver = ReceiverModel(
      receiverId: receivers!.id,
      receiverName: receivers.name,
      receiverPhoneNumber:receivers.phoneNumber ?? '',
      receiverAccountNumber: receivers.accountNumber ?? '',
      receiverSwiftCode:receivers.swiftCode,
      receiverAddress:'Address');
  //print('Receiver Details: ${receiver.toJson()}');
  var amt = controllers[0].text.substring(1).replaceAll(r',', '').trim();
  // if(currentSelectedDiscount != null){
  //   amt = getSavedAmount(int.parse(amt), currentSelectedDiscount).toString();
  // }
  var requestModel = PaymentRequest(
      transactionId: Helper().getRandString(12),
      amount: int.parse(amt),
      sender: sender,
      discountItem: currentSelectedDiscount,
      receiver: receiver, message: controllers[1].text.trim());
  requestModel.paymentMode = (currentSelected is AccountDetails)
      ? "ECOBANKTRANSFER"
      : (currentSelected is MTNWalletDetails)
      ? "MTNWALLET"
      : "ECOBANKCREDITTRANSFER";
  return requestModel;
}
