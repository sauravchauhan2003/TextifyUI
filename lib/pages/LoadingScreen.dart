import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkJwtAndUsername();
  }

  Future<void> _checkJwtAndUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    final username = prefs.getString('username');

    print('🟡 LoadingScreen: JWT Token from SharedPreferences: $jwt');
    print('🟡 LoadingScreen: Username from SharedPreferences: $username');

    // Delay to show the animation briefly
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (jwt != null &&
        jwt.isNotEmpty &&
        username != null &&
        username.isNotEmpty) {
      print("✅ JWT and Username found. Navigating to /mainpage");
      Navigator.pushReplacementNamed(context, '/mainpage');
    } else {
      print("❌ Missing JWT or Username. Navigating to /login");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Textify",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Loading, please wait...",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset('assets/Animation - 1749826237546.json'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
