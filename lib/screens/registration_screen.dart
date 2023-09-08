import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../Widgets/my_text_field.dart';
import '../helpers/show_snack_bar.dart';
import 'chat_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const id = '/registrationScreen';
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen>
    with ShowSnackBar {
  String? _email;
  String? _password;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 200.0,
              child: Image.asset('images/logo.png'),
            ),
            const SizedBox(
              height: 48.0,
            ),
            MyTexField(
              text: 'Enter your Email',
              textInputType: TextInputType.emailAddress,
              data: (String data) {
                _email = data;
              },
            ),
            const SizedBox(
              height: 8.0,
            ),
            MyTexField(
              text: 'Enter your password',
              textInputAction: TextInputAction.done,
              data: (String data) {
                _password = data;
              },
            ),
            // TextField(
            //   onChanged: (value) {
            //     //Do something with the user input.
            //     _password = value;
            //   },
            //   decoration: InputDecoration(
            //     hintText: 'Enter your password',
            //     contentPadding:
            //         EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.all(Radius.circular(32.0)),
            //     ),
            //     enabledBorder: OutlineInputBorder(
            //       borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
            //       borderRadius: BorderRadius.all(Radius.circular(32.0)),
            //     ),
            //     focusedBorder: OutlineInputBorder(
            //       borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
            //       borderRadius: BorderRadius.all(Radius.circular(32.0)),
            //     ),
            //   ),
            // ),
            const SizedBox(
              height: 24.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () {
                    //Implement registration functionality.
                    if (_email != null && _password != null) {
                      firebaseAuth
                          .createUserWithEmailAndPassword(
                              email: _email!, password: _password!)
                          .then((value) {
                        print(value.user!.email);
                        Navigator.pushNamed(context, ChatScreen.id);
                      }).catchError((err) {
                        _performRegister();
                      });
                    }
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _performRegister() {
    //  bool result = _validateData();
    if (_validateData()) {
      _Register();
    }
  }

  bool _validateData() {
    if (_email!.isEmpty) {
      showSnackBar(context,
          message: "Input Your Email Address please!", error: true);
      return false;
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_email!)) {
      showSnackBar(context, message: '"c"', error: true);
      return false;
    } else if (_password!.isEmpty) {
      showSnackBar(context,
          message: "Input Your Password please!", error: true);

      return false;
    } else if (!RegExp("(?=?[0-9])(?=.*?[A-Za-z])(?=.*[^0-9A-Za-z]).+")
        .hasMatch(_password!)) {
      showSnackBar(context,
          message:
              "Password must contain at least one character (a-z)/(A-Z) or digit!",
          error: true);
      return false;
    }
    return true;
  }

  _Register() {
    ///ToDo
    showSnackBar(context, message: "Registered successfully", error: false);
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }
}
