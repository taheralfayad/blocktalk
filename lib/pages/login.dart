import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../design-system/button.dart';
import '../design-system/colors.dart';
import '../design-system/textfield.dart';

import '../components/navbar.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  Future<void> _login() async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    final url = Uri.parse('$backendUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful login
      print('Login successful');
    } else {
      // Handle login error
      print('Login failed: ${response.body}');
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundColor),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlockTalkTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                    ),
                    SizedBox(height: 16.0),
                    BlockTalkTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: BlockTalkButton(
                        text: 'Login',
                        type: 'solid',
                        onPressed: () {
                          print('Login button!');
                          _login();
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        print('Sign up button pressed');
                      },
                      child: const Text(
                        'Not registered? Sign up',
                        style: TextStyle(color: AppColors.primaryButtonColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Navbar(selectedIndex: 3),
            ),
          ],
        ),
      ),
    );
  }
}
