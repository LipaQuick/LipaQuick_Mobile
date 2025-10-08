library otp_screen;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomOtpScreen extends StatefulWidget {
  final String title;
  final String subTitle;
  bool? showLoadingButton = false;
  int? resendCountdown = 30;
  final Future<dynamic> Function(String)? validateOtp;
  final void Function(BuildContext)? routeCallback;
  final void Function(BuildContext)? onResendCallback;
  Color? topColor;
  Color? bottomColor;
  bool? _isGradientApplied;
  final Color titleColor;
  final Color themeColor;
  final Color? keyboardBackgroundColor;
  final Widget? icon;
  bool? obsfucateKey;

  /// default [otpLength] is 4
  final int otpLength;

  CustomOtpScreen({
    Key? key,
    this.title = "Verification Code",
    this.subTitle = "please enter the OTP sent to your\n device",
    this.otpLength = 4,
    @required this.validateOtp,
    @required this.routeCallback,
    @required this.onResendCallback,
    this.themeColor = Colors.black,
    this.titleColor = Colors.black,
    this.icon,
    this.keyboardBackgroundColor,
    this.showLoadingButton,
    this.resendCountdown,
  }) : super(key: key) {
    this._isGradientApplied = false;
    this.obsfucateKey = false;
  }

  CustomOtpScreen.withGradientBackground(
      {Key? key,
        this.title = "Verification Code",
        this.subTitle = "please enter the OTP sent to your\n device",
        this.otpLength = 4,
        @required this.validateOtp,
        @required this.routeCallback,
        @required this.onResendCallback,
        this.themeColor = Colors.white,
        this.titleColor = Colors.white,
        @required this.topColor,
        @required this.bottomColor,
        this.keyboardBackgroundColor,
        this.icon})
      : super(key: key) {
    this._isGradientApplied = true;
    this.obsfucateKey = false;
  }

  CustomOtpScreen.withObsfucatedKey(
      {Key? key,
        this.title = "Verification Code",
        this.subTitle = "please enter the OTP sent to your\n device",
        this.otpLength = 4,
        @required this.validateOtp,
        @required this.routeCallback,
        @required this.onResendCallback,
        this.themeColor = Colors.black,
        this.titleColor = Colors.black,
        this.keyboardBackgroundColor,
        this.icon})
      : super(key: key) {
    this.obsfucateKey = true;
    this._isGradientApplied = false;
  }

  @override
  _CustomOtpScreenState createState() =>  _CustomOtpScreenState();
}

class _CustomOtpScreenState extends State<CustomOtpScreen>
    with SingleTickerProviderStateMixin {
  Size? _screenSize;
  int? _currentDigit;
  List<int>? otpValues;
  bool showLoadingButton = false;

  @override
  void initState() {
    otpValues = List<int>.filled(widget.otpLength, -1, growable: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return  Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
        height: MediaQuery.of(context).size.height,
        decoration: widget._isGradientApplied!
            ? BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.topColor!, widget.bottomColor!],
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.bottomRight,
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ))
            : BoxDecoration(color: Colors.white),
        width: _screenSize!.width,
        child: _getInputPart,
      ),
    );
  }

  /// Return Title label
  get _getTitleText {
    return  Text(
      widget.title,
      textAlign: TextAlign.center,
      style:  TextStyle(
          fontSize: 28.0,
          color: widget.titleColor,
          fontWeight: FontWeight.bold),
    );
  }

  /// Return subTitle label
  get _getSubtitleText {
    return  Text(
      widget.subTitle,
      textAlign: TextAlign.center,
      style:  TextStyle(
          fontSize: 18.0,
          color: widget.titleColor,
          fontWeight: FontWeight.w600),
    );
  }

  /// Return "OTP" input fields
  get _getInputField {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: getOtpTextWidgetList(),
    );
  }

  /// Returns otp fields of length [widget.otpLength]
  List<Widget> getOtpTextWidgetList() {
    List<Widget> optList = [];
    for (int i = 0; i < widget.otpLength; i++) {
      optList.add(_otpTextField(otpValues![i]));
    }
    return optList;
  }

  /// Returns Otp screen views
  get _getInputPart {
    return  Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        widget.icon != null
            ? IconButton(
          icon: widget.icon!,
          iconSize: 80,
          onPressed: () {},
        )
            : Container(
          width: 0,
          height: 0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _getTitleText,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _getSubtitleText,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _getInputField,
        ),
        showLoadingButton
            ? Center(child: CircularProgressIndicator())
            : Container(
          width: 0,
          height: 0,
        ),
        _getResendPart,
        _getOtpKeyboard
      ],
    );
  }

  get _getResendPart {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          widget.resendCountdown != 0
              ? Text(
            'Resend code in ${widget.resendCountdown} seconds',
            style: TextStyle(fontSize: 14),
          ): Container(),
          SizedBox(width: 10),
          widget.resendCountdown == 0
              ? TextButton(
            onPressed: _resendCode,
            child: Text(
              'Resend',
              style: TextStyle(fontSize: 14),
            ),
          ) : Container(),
        ],
      ),
    );
  }

  /// Returns "Otp" keyboard
  get _getOtpKeyboard {
    return  Container(
        color: widget.keyboardBackgroundColor,
        height: _screenSize!.width - 80,
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "1",
                      onPressed: () {
                        _setCurrentDigit(1);
                      }),
                  _otpKeyboardInputButton(
                      label: "2",
                      onPressed: () {
                        _setCurrentDigit(2);
                      }),
                  _otpKeyboardInputButton(
                      label: "3",
                      onPressed: () {
                        _setCurrentDigit(3);
                      }),
                ],
              ),
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _otpKeyboardInputButton(
                    label: "4",
                    onPressed: () {
                      _setCurrentDigit(4);
                    }),
                _otpKeyboardInputButton(
                    label: "5",
                    onPressed: () {
                      _setCurrentDigit(5);
                    }),
                _otpKeyboardInputButton(
                    label: "6",
                    onPressed: () {
                      _setCurrentDigit(6);
                    }),
              ],
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _otpKeyboardInputButton(
                    label: "7",
                    onPressed: () {
                      _setCurrentDigit(7);
                    }),
                _otpKeyboardInputButton(
                    label: "8",
                    onPressed: () {
                      _setCurrentDigit(8);
                    }),
                _otpKeyboardInputButton(
                    label: "9",
                    onPressed: () {
                      _setCurrentDigit(9);
                    }),
              ],
            ),
            Flexible(
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                   SizedBox(
                    width: 80.0,
                  ),
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  _otpKeyboardActionButton(
                      label:  Icon(
                        Icons.backspace,
                        color: widget.themeColor,
                      ),
                      onPressed: () {
                        setState(() {
                          for (int i = widget.otpLength - 1; i >= 0; i--) {
                            if (otpValues![i] != -1) {
                              otpValues![i] = -1;
                              break;
                            }
                          }
                        });
                      }),
                ],
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Returns "Otp text field"
  Widget _otpTextField(int digit) {
    return Container(
      width: 35.0,
      height: 45.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                width: 2.0,
                color: widget.titleColor,
              ))),
      child: Text(
        digit != -1 ? widget.obsfucateKey!? '*':digit.toString(): "",
        style: TextStyle(
          fontSize: 30.0,
          color: widget.titleColor,
        ),
      ),
    );
  }

  /// Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton({String? label, VoidCallback? onPressed}) {
    return  Material(
      color: Colors.transparent,
      child:  InkWell(
        onTap: onPressed,
        borderRadius:  BorderRadius.circular(40.0),
        child:  Container(
          height: 80.0,
          width: 80.0,
          decoration:  BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          child:  Center(
            child:  Text(
              label!,
              style:  TextStyle(
                fontSize: 30.0,
                color: widget.themeColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns "Otp keyboard action Button"
  _otpKeyboardActionButton({Widget? label, VoidCallback? onPressed}) {
    return  InkWell(
      onTap: onPressed,
      borderRadius:  BorderRadius.circular(40.0),
      child:  Container(
        height: 80.0,
        width: 80.0,
        decoration:  BoxDecoration(
          shape: BoxShape.circle,
        ),
        child:  Center(
          child: label,
        ),
      ),
    );
  }

  /// sets number into text fields n performs
  ///  validation after last number is entered
  void _setCurrentDigit(int i) async {
    setState(() {
      _currentDigit = i;
      int currentField;
      for (currentField = 0; currentField < widget.otpLength; currentField++) {
        if (otpValues![currentField] == -1) {
          otpValues![currentField] = _currentDigit!;
          break;
        }
      }
      if (currentField == widget.otpLength - 1) {
        showLoadingButton = true;
        String otp = otpValues!.join();
        widget.validateOtp!(otp).then((value) {
          showLoadingButton = false;
          if (value == -1) {
            widget.routeCallback!(context);
          } else if (value!.isNotEmpty) {
            showToast(context, value);
            clearOtp();
          }
        });
      }
    });
  }

  ///to clear otp when error occurs
  void clearOtp() {
    otpValues = List<int>.filled(widget.otpLength, -1, growable: false);
    setState(() {});
  }

  ///to show error  message
  showToast(BuildContext context, String msg) {
    Widget toast = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.grey.shade500,
          ),
          child: Center(
              child: Text(
                msg,
                maxLines: 3,
                textAlign: TextAlign.center,
              )),
        ));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: toast, duration: Duration(seconds: 2)));
  }

  void _resendCode() {
    widget.onResendCallback!(context);
  }
}