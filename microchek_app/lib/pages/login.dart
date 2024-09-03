// pages/login.dart
// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:microchek_app/pages/dashboard.dart';
import 'package:microchek_app/pages/start_details.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:microchek_app/utils/loading.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Perform login logic (e.g., authenticate user)
      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();
        loadingDialog(context);
        User? user = await getUserCredentials(email, password);
        if (user != null) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Logging in...')),
          // );
          if (await checkInstitution(user.uid)) {
            debugPrint('institution exists');
            InstitutionProvider institutionProvider =
                Provider.of<InstitutionProvider>(context, listen: false);
            debugPrint('fetching user data');
            await fetchInstitutionData(user.uid, institutionProvider);
            debugPrint('done fetching');
            if (mounted) {
              Navigator.pop(context);
            }

            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => GhanaCardValidationPage(),
            ));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) =>
                  OnboardingPage(uid: user.uid, email: user.email!),
            ));
          }
        }
        //user does not exist we lead to onboarding page:
        else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sorry, Account not found.')),
          );
        }
      } catch (e) {
        //Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sorry, Account not found.')),
        );
        // if (mounted) {
        //   Navigator.pop(context);
        // }
        // debugPrint('Error logging in: $e');
      }

      //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => GhanaCardValidationPage(),));
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Logging in...')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 100,
                  color: Colors.amber[50],
                ),
                Text(
                  "MicroCheck",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.amber[50],
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  // topRight: Radius.circular(50),
                ),
              ),
              child: Form(
                autovalidateMode: AutovalidateMode.onUnfocus,
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 50,
                  ),
                  children: [
                    SizedBox(
                      height: 0.6 * MediaQuery.sizeOf(context).height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              child: Text(
                                "Login",
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(fontSize: 40),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "Enter your email",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                } else if (!RegExp(r'\S+@\S+\.\S+')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: "Password",
                                hintText: "Enter your password",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // showDialog(
                                //   context: context,
                                //   builder: (context) => LoadingScreen(),
                                // );
                                _handleLogin();
                                //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => GhanaCardValidationPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                  // padding: EdgeInsets.symmetric(vertical: 15.0),
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(30.0),
                                  // ),
                                  ),
                              child: Text(
                                "Login",
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
