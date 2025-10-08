import 'package:flutter/material.dart';

import '../../../shared/app_colors.dart';

class OTPDigitTextFieldBox extends StatelessWidget {
  final bool first;
  final bool last;
  final Function(String) onChanged;

  const OTPDigitTextFieldBox(
      {Key? key, required this.first, required this.last, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var primaryColor = appGreen400;
    var hintTextStyle = const TextStyle(
        fontWeight: FontWeight.normal, fontSize: 19, color: Colors.red);
    var inputTextStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 19);
    return SizedBox(
      height: 65,
      child: AspectRatio(
        aspectRatio: 0.8,
        child: TextField(
          autofocus: true,
          onChanged: (value) {
            if (value.length == 1 && last == false) {
              Future.delayed(Duration(milliseconds: 50)).then((value) => {
                FocusScope.of(context).nextFocus()
              });
            }
            if (value.isEmpty && first == false) {
              Future.delayed(Duration(milliseconds: 50)).then((value) => {
                FocusScope.of(context).previousFocus()
              });
            }
            onChanged(value);
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: inputTextStyle,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          maxLength: 1,
          decoration: InputDecoration(
            // contentPadding: EdgeInsets.all(0),
            counter: const Offstage(),
            enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(width: 2, color: Colors.grey),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(width: 2, color: primaryColor),
                borderRadius: BorderRadius.circular(10)),
            hintText: "*",
            hintStyle: hintTextStyle,
          ),
        ),
      ),
    );
  }
}

class OTPDigitTextField extends StatefulWidget{
  final bool first;
  final bool last;
  final Function(String) onChanged;

  const OTPDigitTextField(
      {Key? key, required this.first, required this.last, required this.onChanged})
      : super(key: key);

  @override
  State<OTPDigitTextField> createState() => OTPDigitTextState();

}

class OTPDigitTextState extends State<OTPDigitTextField>{
  final TextEditingController _controller = TextEditingController();

  var inputTextStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 19);
  var filledTextStyle = const TextStyle(color: appGreen400, fontWeight: FontWeight.normal, fontSize: 19);

  var defaultDecoration =  InputDecoration(
  // contentPadding: EdgeInsets.all(0),
  counter: const Offstage(),
  enabledBorder: UnderlineInputBorder(
      borderSide: const BorderSide(width: 2, color: Colors.grey),
      borderRadius: BorderRadius.circular(10)),
  focusedBorder: UnderlineInputBorder(
  borderSide: const BorderSide(width: 2, color: appGreen400),
  borderRadius: BorderRadius.circular(10)),
  hintText: "*",
  hintStyle: const TextStyle(
      fontWeight: FontWeight.normal, fontSize: 19, color: Colors.red),
  );

  var filledDecoration =  InputDecoration(
    // contentPadding: EdgeInsets.all(0),
    counter: const Offstage(),
    border: UnderlineInputBorder(
        borderSide: const BorderSide(width: 2, color: appGreen400),
        borderRadius: BorderRadius.circular(10)),
  );

  @override
  Widget build(BuildContext context) {
    print('Widget init :'+_controller.text);
    return SizedBox(
      height: 65,
      child: AspectRatio(
        aspectRatio: 0.8,
        child: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (value) {
            if (value.length == 1 && widget.last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.isEmpty && widget.first == false) {
              FocusScope.of(context).previousFocus();
            }
            widget.onChanged(value);
            setState(() {
              print('Rebuilding Widget');
            });
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: _controller.text.isNotEmpty?filledTextStyle:inputTextStyle,
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: _controller.text.isNotEmpty?filledDecoration:defaultDecoration,
        ),
      ),
    );
  }

}
