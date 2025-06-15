import 'package:flutter/material.dart';
import 'package:textify/Logic/Routes.dart';
import 'package:textify/pages/ChatScreen.dart';
import 'package:textify/pages/ForgotPassword.dart';
import 'package:textify/pages/LoadingScreen.dart';
import 'package:textify/pages/LoginScreen.dart';
import 'package:textify/pages/MainScreen.dart';
import 'package:textify/pages/SignUp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.LoadingScreen,
      routes: {
        Routes.signup: (context) => Signup(),
        Routes.login: (context) => Loginscreen(),
        Routes.ChatScreen: (context) => ChatScreen(),
        Routes.Mainpage: (context) => RecentChatsPage(),
        Routes.Forgotpassword: (context) => ForgotPasswordPage(),
        Routes.LoadingScreen: (context) => LoadingScreen(),
      },
    );
  }
}
