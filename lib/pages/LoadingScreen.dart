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
    _checkJwtAndNavigate();
  }

  Future<void> _checkJwtAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');

    if (jwt != null && jwt.isNotEmpty) {
      // Delay a bit to show the animation
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/mainpage',
      ); // use your actual route name
    } else {
      // You can also navigate to login if JWT not found
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login'); // fallback
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
              // App Name
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

              // Lottie Animation
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
