import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lipa_quick/core/models/payment/payment.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/view_models/accounts_viewmodel.dart';
import 'package:lipa_quick/gen/assets.gen.dart';
import 'package:lipa_quick/main.dart';

class MTNPaymentWaitWidget extends StatefulWidget {
  PaymentRequest addAccountModel;
  MTNPaymentWaitWidget(this.addAccountModel);

  @override
  _MTNPaymentWaitWidgetState createState() => _MTNPaymentWaitWidgetState();
}

class _MTNPaymentWaitWidgetState extends State<MTNPaymentWaitWidget> {
  late Timer _timer;
  int _start = 780;
  int _maxProgress = 780;
  int _progress = 0;
  late var response;
  AccountViewModel accountViewModel = locator<AccountViewModel>();

  _MTNPaymentWaitWidgetState(){
    _maxProgress = widget.addAccountModel.paymentMode!.toLowerCase().contains('mtn')?780:60;
  }

  @override
  Future<void> initState() async {
    super.initState();
    _startTimer();
    response = await accountViewModel.pay(widget.addAccountModel);
  }

  Future<void> _startTimer() async {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSecond,
      (Timer timer) => setState(() {
        if (_start < 1) {
          timer.cancel();
        } else {
          if(response != null){
            //Response is received, exiting the timer and checking the response
            _timer.cancel();
            _start = 0;
            _progress = _maxProgress;
            handlePaymentApiResponse();
          }
          _start = _start - 1;
          _progress++;
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Assets.icon.mtnmomo.svg(width: 100, height: 100),
          Text('Open your MTN Momo app and approve the payment request.'),
          Container(
            decoration: BoxDecoration(
              borderRadius:  BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Text('Sub-title'),
          ),
          SizedBox(height: 8.0),
          Text(
            '\u2022 Open the application linked with your number.',
            style: GoogleFonts.poppins(
              fontSize: 14,
            ),
          ),
          Text('\u2022 Approve the payment request by entering MTM Momo PIN.',
            style: GoogleFonts.poppins(
              fontSize: 14,
            ),),
          SizedBox(height: 20.0),
          LinearProgressIndicator(
            value: _progress / _maxProgress,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            backgroundColor: Colors.grey[300],
          ),
          SizedBox(height: 8.0),
          Text(
              'Approve payment within ${(_start / 60).floor()}:${(_start % 60).toString().padLeft(2, '0')} minutes'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    _progress = 0;
    super.dispose();
  }

  void handlePaymentApiResponse() {
    Navigator.of(context).pop(response);
  }
}
