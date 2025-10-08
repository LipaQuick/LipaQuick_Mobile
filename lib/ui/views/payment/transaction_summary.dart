import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:lipa_quick/core/managers/language/language_bloc.dart';
import 'package:lipa_quick/core/models/api_exception/api_exception.dart';
import 'package:lipa_quick/core/models/contacts/contacts.dart';
import 'package:lipa_quick/core/models/discount/discount_model.dart';
import 'package:lipa_quick/core/models/payment/payment.dart';
import 'package:lipa_quick/ui/app_router.dart';
import 'package:lipa_quick/ui/views/dashboard/dashboard_page.dart';
import 'package:lipa_quick/ui/views/payment/payment_progress.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/models/service/service_response.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/core/view_models/discount_viewmodel.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/shared/app_colors.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';
import 'package:lipa_quick/ui/shared/button.dart';
import 'package:lipa_quick/ui/shared/dialogs/dialogshelper.dart';
import 'package:lipa_quick/ui/shared/empty_error_states.dart';
import 'package:lipa_quick/ui/shared/sucess_pages.dart';
import 'package:lipa_quick/ui/views/payment/payment_screen.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lipa_quick/ui/views/social_post/social_post_create.dart';

class TransactionSummaryPage extends StatefulWidget {
  final PaymentRequest? paymentRequest;
  ContactsAPI? contact;

  TransactionSummaryPage({super.key, this.paymentRequest, this.contact});

  @override
  _TransactionSummaryPageState createState() => _TransactionSummaryPageState();
}

class _TransactionSummaryPageState extends State<TransactionSummaryPage> {
  DiscountViewModel discountViewModel = locator<DiscountViewModel>();
  AccountViewModel accountViewModel = locator<AccountViewModel>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.getAppBar(
          context: context,
          title: AppLocalizations.of(context)!.transfer_confirmation,
          subTitle: '',
          enableBack: true),
      body: PopScope(
        onPopInvoked: AppRouter().onBackPressed,
    child: FutureBuilder<dynamic>(
      future: discountViewModel.checkServiceChargeAndCommission(
          amount: widget.paymentRequest!.amount!,
          paymentMode: widget.paymentRequest!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          if (snapshot.hasData && snapshot.data is ServiceApiResponse) {
            final transactions = (snapshot.data as ServiceApiResponse).data;
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: TransactionUserDetails(
                      paymentRequest: widget.paymentRequest!),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: TransactionAmountDetails(
                      serviceDetails: transactions,
                      paymentRequest: widget.paymentRequest!),
                ),
                SizedBox(height: 30),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Button.filled(
                    onPressed: () {
                      initiatePaymentHere(
                          widget.paymentRequest!, widget.contact, transactions);
                    },
                    label: AppLocalizations.of(context)!.button_send_now,
                  ),
                )
              ],
            );
          } else {
            final apiException = snapshot.data as APIException;
            var errorMessage = (apiException.errors != null &&
                apiException.errors!.isNotEmpty)
                ? getErrorMessage(apiException.errors!)
                : apiException.message!;
            return EmptyViewFailedWidget(
                title: AppLocalizations.of(context)!.transfer_confirmation,
                message: errorMessage,
                icon: Icons.summarize_rounded,
                buttonHint: AppLocalizations.of(context)!.button_retry);
          }
        }
      },
    )),
    );
  }

  getErrorMessage(List<String> list) {
    var buffer = StringBuffer();
    for (var i = 0; i < list.length; i++) {
      buffer.write('${(i + 1)}. ${list[i]}\n');
    }
    return buffer.toString();
  }

  initiatePaymentHere(
      PaymentRequest addAccountModel, ContactsAPI? receivers, List<ServiceChargeCommissionModel> transactions) async {
    //accountViewModel.setState(ViewState.Loading);
    //showLoaderDialog(context);

    int overallTotal = (addAccountModel.amount! -
        transactions[1].serviceCommissionAmount +
        transactions[0].serviceChargeAmount);

    if(addAccountModel.discountItem != null){
      overallTotal = getSavedAmount(overallTotal!, addAccountModel.discountItem);
    }

    addAccountModel.amount = overallTotal;
    addAccountModel.serviceCommissionDetails = transactions[1];
    addAccountModel.serviceChargeDetails = transactions[0];

    print('Payment Details: ${addAccountModel.toJson()}');


    var response = await showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.6),
      // Background color
      barrierDismissible: false,
      barrierLabel: 'Dialog',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, __, ___) {
        return PaymentWaitWidget(addAccountModel);
      },
    );

    if (response == null) {
      //accountViewModel.setState(ViewState.Idle);
      CustomDialog(DialogType.FAILURE).buildAndShowDialog(
          context: context,
          title: AppLocalizations.of(context)!.error_hint,
          message: accountViewModel.errorMessage ?? '',
          onPositivePressed: () {
            previousPage(false);
          },
          buttonPositive: 'OK');
    } else {
      //accountViewModel.setState(ViewState.Idle);
      if (response is PaymentApiResponse) {
        if (response.status!) {
          UserDetails? userdetails = await fetchDetails();
          var successpage = SuccessPage(
              icon: Icons.check_circle,
              positiveButton: "Create a post",
              negativeButton: 'Skip',
              senderDetails: userdetails!,
              receiverDetails: receivers!,
              tranReferenceNumber: addAccountModel.transactionId!,
              positiveCallback: () {
                print("reached here");
                Navigator.of(context).pop();
                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                    builder: (context) => CreateFeedbackPage(
                          paymentRemarks: addAccountModel,
                          nextWidget: HomePage(),
                        )));
              },
              negativeCallback: () {
                Navigator.of(context).pop();
                Navigator.of(context,  rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => route.isFirst);
              });
          showGeneralDialog(
            context: context,
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return successpage;
            },
          );
        } else {
          //print('API Response in View');
          //var errorMessage = model.
          CustomDialog(DialogType.FAILURE).buildAndShowDialog(
              context: context,
              title: AppLocalizations.of(context)!.error_hint,
              message: accountViewModel.errorMessage,
              onPositivePressed: () {
                previousPage(false);
              },
              buttonPositive: 'OK');
        }
      }
      else if (response is APIException) {
        CustomDialog(DialogType.FAILURE).buildAndShowDialog(
            context: context,
            title: AppLocalizations.of(context)!.error_hint,
            message: accountViewModel.errorMessage,
            onPositivePressed: () {
              previousPage(false);
            },
            buttonPositive: 'OK');
      }
    }
  }

  void previousPage(bool reload) {
    // isGoBack = true;
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> showMtnWalletTransactionDialog(
      PaymentRequest addAccountModel) async {
    var response = await showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.6),
      // Background color
      barrierDismissible: false,
      barrierLabel: 'Dialog',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, __, ___) {
        return PaymentWaitWidget(addAccountModel);
      },
    );
  }
}

class TransactionUserDetails extends StatelessWidget {
  PaymentRequest paymentRequest;

  TransactionUserDetails({required this.paymentRequest});

  @override
  Widget build(BuildContext context) {
    print("Transaction Data Receiver: ${paymentRequest.receiver!.toJson()}");
    return Column(
      children: [
        const SizedBox(height: 16),
        buildTransactionInfo(
            AppLocalizations.of(context)!.from_hint,
            paymentRequest.sender!.senderName!,
            '',
            (paymentRequest.sender!.senderAccountNumber == null ||
                    paymentRequest.sender!.senderAccountNumber!.isEmpty)
                ? paymentRequest.sender!.senderPhoneNumber!
                : paymentRequest.sender!.senderAccountNumber!),
        const SizedBox(height: 16),
        buildDivider(),
        const SizedBox(height: 16),
        buildTransactionInfo(
            AppLocalizations.of(context)!.to_hint,
            paymentRequest.receiver!.receiverName!,
            '',
            (paymentRequest.paymentMode!.contains('MTNWALLET'))
            ?paymentRequest.receiver!.receiverPhoneNumber!:
            (paymentRequest.paymentMode!.contains('ECOBANK'))
                ?paymentRequest.receiver!.receiverAccountNumber:''),
        const SizedBox(height: 16),
        buildDivider(),
      ],
    );
  }

  Widget buildTransactionInfo(
      String label1, String value1, String label2, String value2) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildColumn(label1, value1),
          const SizedBox(width: 16), // Add spacing between columns
          buildColumn(label2, value2, textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget buildColumn(String label, String value,
      {TextAlign textAlign = TextAlign.left}) {
    return Flexible(
      child: Column(
        crossAxisAlignment: (textAlign == TextAlign.right)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.0,
              // Use relative height
              letterSpacing: 0.30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: textAlign,
            style: TextStyle(
              color: Color(0xFF1D3A6F),
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              height: 1.0,
              // Use relative height
              letterSpacing: 0.30,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            strokeAlign: BorderSide.strokeAlignCenter,
            color: Color(0xFFF3F4F6),
          ),
        ),
      ),
    );
  }

  Widget buildTitle(String label, String value) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      child: Text(
        label,
        style: TextStyle(
          color: appGreen400,
          fontSize: 21,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          height: 1.0,
          // Use relative height
          letterSpacing: 0.30,
        ),
      ),
    );
  }
}

class TransactionAmountDetails extends StatelessWidget {
  List<ServiceChargeCommissionModel> serviceDetails;
  PaymentRequest paymentRequest;
  int? overallTotal;

  TransactionAmountDetails(
      {required this.serviceDetails, required this.paymentRequest}) {

    overallTotal = (paymentRequest.amount! -
        serviceDetails[1].serviceCommissionAmount +
        serviceDetails[0].serviceChargeAmount);

    if(paymentRequest.discountItem != null){
      overallTotal = getSavedAmount(overallTotal!, paymentRequest.discountItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = BlocProvider.of<LanguageBloc>(context).state;
    //print("Transaction Data Sender: ${paymentRequest.sender!.toJson().toString()}");
    return Column(
      children: [
        buildSubTotal(AppLocalizations.of(context)!.transfer_amount_hint,
            '${state.selectedLanguage.currency} ${paymentRequest.amount!}'),
        const SizedBox(height: 5),
        Visibility(visible: (paymentRequest.discountItem != null),
          child: buildSubTotal(getTransactionTitle(context, paymentRequest.discountItem),
            '- ${getValue(paymentRequest.discountItem)}')
          ,),
        const SizedBox(height: 5),
        buildSubTotal(AppLocalizations.of(context)!.service_charge_hint,
            '+ ${serviceDetails[0].serviceChargeAmount}'),
        const SizedBox(height: 5),
        buildSubTotal(AppLocalizations.of(context)!.service_commission_hint,
            '- ${serviceDetails[1].serviceCommissionAmount}'),
        const SizedBox(height: 15),
        buildDivider(),
        const SizedBox(height: 10),
        buildTotal(AppLocalizations.of(context)!.total_amount_hint,
            '${state.selectedLanguage.currency} ${overallTotal!.toString()}'),
      ],
    );
  }

  Widget buildDivider() {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            strokeAlign: BorderSide.strokeAlignCenter,
            color: Color(0xFFF3F4F6),
          ),
        ),
      ),
    );
  }

  Widget buildTotal(String label, String value) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 19,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              height: 1.0,
              // Use relative height
              letterSpacing: 0.30,
            ),
          ),
          const SizedBox(width: 16), // Add spacing between columns
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.black,
              fontSize: 19,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              height: 1.0,
              // Use relative height
              letterSpacing: 0.30,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSubTotal(String label, String value) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              height: 1.0,
              // Use relative height
              letterSpacing: 0.30,
            ),
          ),
          const SizedBox(width: 16), // Add spacing between columns
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              height: 1.0,
              // Use relative height
              letterSpacing: 0.30,
            ),
          ),
        ],
      ),
    );
  }

  getValue(DiscountItems? discountItem) {
    if(discountItem == null){
      return '';
    }
    return '${paymentRequest.discountItem!.amountPercentageActive!
        ?paymentRequest.discountItem!.amountPercentage!:paymentRequest.discountItem!.flatAmount!}';
  }

  String getTransactionTitle(BuildContext context, DiscountItems? discountItem) {

    if(discountItem == null){
      return '';
    }

    return AppLocalizations.of(context)!.discount_applied(paymentRequest.discountItem!.discountCode ?? '');
  }
}

int getSavedAmount(int amount, DiscountItems? currentSelectedDiscount) {
  if (currentSelectedDiscount == null) {
    return amount;
  }
  if (currentSelectedDiscount.amountPercentageActive!) {
    return (amount * currentSelectedDiscount.amountPercentage!) ~/
        100;
  } else {
    return (amount -  currentSelectedDiscount.flatAmount!);
  }
}
