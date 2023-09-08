import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tt9_chat_app_st/screens/chat_screen.dart';
import 'package:tt9_chat_app_st/screens/registration_screen.dart';

import '../Widgets/my_text_field.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../helpers/show_snack_bar.dart';

class LoginScreen extends StatefulWidget {
  static const id = '/loginScreen';
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with ShowSnackBar {
  String _password = '';
  String _email = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
            ),
            const SizedBox(
              height: 48.0,
            ),
            MyTexField(
              textInputType: TextInputType.emailAddress,
              data: (String data) {
                _email = data;
              },
              text: 'Enter your Email',
            ),
            const SizedBox(
              height: 8.0,
            ),
            MyTexField(
              isPassword: true,
              textInputAction: TextInputAction.done,
              data: (String data) {
                _password = data;
              },
              text: 'Enter your Password',
            ),
            const SizedBox(
              height: 24.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                color: Colors.lightBlueAccent,
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () {
                    //Implement login functionality.
                    _auth
                        .signInWithEmailAndPassword(
                            email: _email, password: _password)
                        .then((value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString(
                          'user', _auth.currentUser!.email.toString()); //
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, ChatScreen.id, (routs) => false);
                      }
                    }).catchError((err) {
                      _performRegister();
                    });
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: const Text(
                    'Log In',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Material(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(30.0),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () {
                    // Go to registration screen.
                    signInWithGoogle().then((value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString(
                          'user', _auth.currentUser!.email.toString());
                      if (mounted) {
                        Navigator.pushNamed(context, ChatScreen.id);
                      }
                    }).catchError((err) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${err?.toString()}'),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(24),
                        backgroundColor: Colors.redAccent,
                      ));
                    });
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: const Text(
                    'Login by google account',
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
      _Login();
    }
  }

  bool _validateData() {
    if (_email.isEmpty) {
      showSnackBar(context,
          message: "Input Your Email Address please!", error: true);
      return false;
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_email)) {
      showSnackBar(context,
          message: '"Input valid Email Address!"', error: true);
      return false;
    } else if (_password.isEmpty) {
      showSnackBar(context,
          message: "Input Your Password please!", error: true);
      return false;
    } else if (!RegExp("(?=?[0-9])(?=.*?[A-Za-z])(?=.*[^0-9A-Za-z]).+")
        .hasMatch(_password)) {
      showSnackBar(context,
          message:
              "Password must contain at least one character (a-z)/(A-Z) or digit!",
          error: true);
      return false;
    }
    return true;
  }

  _Login() {
    ///ToDo
    showSnackBar(context, message: "logged successfully", error: false);
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }
}
