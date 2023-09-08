import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class MyTexField extends StatefulWidget {
  String? text;
  bool isPassword;
  TextInputType? textInputType;
  TextInputAction? textInputAction;
  Function(String)? data;
  MyTexField(
      {Key? key,
      required this.data,
      this.textInputType = TextInputType.text,
      this.textInputAction = TextInputAction.next,
      required this.text,
      this.isPassword = false})
      : super(key: key);

  @override
  State<MyTexField> createState() => _MyTexFieldState();
}

class _MyTexFieldState extends State<MyTexField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.data,
      obscureText: widget.isPassword,
      keyboardType: widget.textInputType,
      textInputAction: widget.textInputAction,

      ///on changed take the data we enter in the text field
      decoration: InputDecoration(
        hintText: widget.text,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        border: kBorderOutLinedTextField,
        enabledBorder: kBorderOutLinedFocusOrEnabledTextField,
        focusedBorder: kBorderOutLinedFocusOrEnabledTextField,
      ),
    );
  }
}
