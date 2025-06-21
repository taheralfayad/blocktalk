import 'package:flutter/material.dart';

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
                          print('Login button pressed');
                        },
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
