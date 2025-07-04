import 'package:flutter/material.dart';
import 'package:textify/Logic/AuthenticationService.dart';
import 'package:textify/Logic/Routes.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SigState();
}

class _SigState extends State<Signup> {
  var _authservice = AuthenticationService();
  late String username;
  late String password;
  late String email;
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(height: 80),
                Column(
                  children: [
                    Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Join us by creating an account"),
                  ],
                ),
                Container(height: 80),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: emailcontroller,
                      decoration: InputDecoration(
                        hintText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        filled: true,
                        prefixIcon: Icon(Icons.mail),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: usernamecontroller,
                      decoration: InputDecoration(
                        hintText: "Username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        filled: true,
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordcontroller,
                      decoration: InputDecoration(
                        hintText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        filled: true,
                        prefixIcon: Icon(
                          Icons.lock,
                        ), // Changed to lock icon for password
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        username = usernamecontroller.text;
                        password = passwordcontroller.text;
                        email = emailcontroller.text;
                        if (await _authservice.register(
                          username,
                          password,
                          email,
                        )) {
                          Navigator.pushNamed(context, Routes.Mainpage);
                        }
                      },
                      child: Text("Sign Up", style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an accoount? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.login);
                      },
                      child: Text("Log in"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
