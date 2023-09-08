import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tt9_chat_app_st/screens/chat_screen.dart';
import 'package:tt9_chat_app_st/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool alreadyUser = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    Future.delayed(
      Duration(seconds: 3),
      () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return alreadyUser ? const ChatScreen() : const WelcomeScreen();
          },
        ));
      },
    );
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    alreadyUser = prefs.getBool("alreadyUser") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Icon(
          Icons.mark_unread_chat_alt,
          size: 100,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
