import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/app_states.dart';
import 'package:lipa_quick/core/models/payment/payment.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/main.dart';
import 'package:lipa_quick/ui/app_router.dart';
import 'package:lipa_quick/ui/shared/app_theme.dart';

import '../../shared/dialogs/dialogshelper.dart';

class PaymentWaitWidget extends StatefulWidget {
  PaymentRequest addAccountModel;

  PaymentWaitWidget(this.addAccountModel, {super.key});

  @override
  _PaymentWaitWidgetState createState() => _PaymentWaitWidgetState();
}

class _PaymentWaitWidgetState extends State<PaymentWaitWidget> {
  late Timer _timer;
  StreamController<dynamic> _apiStream = new StreamController<dynamic>();
  int _start = 780;
  int _maxProgress = 780;
  int _progress = 0;
  AccountViewModel accountViewModel = locator<AccountViewModel>();

  _PaymentWaitWidgetState();

  @override
  void initState() {
    super.initState();
    //print(widget.addAccountModel.toJson());
    _maxProgress =
        widget.addAccountModel.paymentMode!.toLowerCase().contains('mtn')
            ? 780
            : 60;
    _startTimer();
  }

  Future<void> _startTimer() async {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSecond,
      (Timer timer) => setState(() {
        if (_maxProgress < 1) {
          timer.cancel();
          handlePaymentTimeout();
        } else {
          _maxProgress = _maxProgress - 1;
          _progress++;
        }
      }),
    );

    await accountViewModel.pay(widget.addAccountModel).then((value) => {
      _apiStream.add(value)
    });

  }

  @override
  Widget build(BuildContext context) {
    return PopScope(onPopInvoked: AppRouter().onBackPressed,
        canPop: false,
        child: Scaffold(
          appBar: AppTheme.getAppBar(context: context, title: '', subTitle: '', enableBack: true),
          body: SafeArea(
            child: StreamBuilder<dynamic>(
                stream: _apiStream.stream,
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      handlePaymentApiResponse(snapshot.data);
                    });
                    return getProgressWidgetForPaymentMode(widget.addAccountModel);
                  }
                  return getProgressWidgetForPaymentMode(widget.addAccountModel);
                }),
          ),
        ));
  }

  @override
  void dispose() {
    _timer.cancel();
    _progress = 0;
    super.dispose();
  }

  void handlePaymentApiResponse(dynamic data) {
    _timer.cancel();
    _start = 0;
    _progress = _maxProgress;
    Navigator.of(context).pop(data);
  }

  Widget getProgressWidgetForPaymentMode(PaymentRequest addAccountModel) {
    if (addAccountModel.paymentMode!.toLowerCase().contains('mtn')) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Assets.icon.mtnmomo.svg(width: 100, height: 100),
            Text('Open your MTN Momo app and approve the payment request.'),
            const SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.only(left: 20, right:20, top:10, bottom:10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  border: Border.all(width: 2)
              ),
              child: Text(addAccountModel.sender!.senderPhoneNumber!
                ,style: GoogleFonts.poppins(),),
            ),
            const SizedBox(height: 20.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u2022 Open the application linked with your number.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  '\u2022 Approve the payment request by entering MTM Momo PIN.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height/5),
            LinearProgressIndicator(
              value: _progress / _maxProgress,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8.0),
            Text(
                'Approve payment within ${(_start / 60).floor()}:${(_start % 60).toString().padLeft(2, '0')} minutes'),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Assets.icon.ecobankLogo.svg(width: 100, height: 100),
            Text('Please wait while we complete the payment.'),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Text(''),
            ),
            const SizedBox(height: 8.0),
            Text(
              '\u2022 Please do no close the application. ',
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
            Text(
              '\u2022 Please do not press the back button.',
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20.0),
            LinearProgressIndicator(
              value: _progress / _maxProgress,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8.0),
            Text(
                'Please wait till the payment is complete in ${(_start / 60).floor()}:${(_start % 60).toString().padLeft(2, '0')} minutes'),
          ],
        ),
      );
    }
  }

  void handlePaymentTimeout() {
    CustomDialog(DialogType.FAILURE).buildAndShowDialog(
        context: context,
        title: 'Timeout',
        message:
            'Oops! It looks like we\'re having trouble processing your payment at the moment. Please be patient and  try again. If the problem persists, please check your internet connection or try again later. Thank you for your patience!',
        onPositivePressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
        buttonPositive: 'OK');
  }
}
