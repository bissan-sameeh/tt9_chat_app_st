import 'package:flutter/material.dart';
import 'package:tt9_chat_app_st/screens/chat_screen.dart';
import 'package:tt9_chat_app_st/screens/login_screen.dart';
import 'package:tt9_chat_app_st/screens/registration_screen.dart';
import 'package:tt9_chat_app_st/screens/welcome_screen.dart';

void main() => runApp(const FlashChat());

class FlashChat extends StatelessWidget {
  const FlashChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const WelcomeScreen(),
      routes: {
        LoginScreen.id: (context) => const LoginScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
      },
    );
  }
}
