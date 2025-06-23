import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../design-system/button.dart';
import '../design-system/colors.dart';
import '../design-system/textfield.dart';

import '../components/navbar.dart';
import '../components/notification.dart';

enum _AuthState { login, signup }

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  _AuthState _authState = _AuthState.login;
  String? _notificationMessage;
  Color _notificationColor = Colors.red;


  bool _obscurePassword = true; // Add this to your _LoginPageState


  Future<void> _login(isAuthenticated) async {

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
      setState(() {
        _notificationMessage = 'Login successful';
        _notificationColor = Colors.green;
      });
    } else {
      setState(() {
        _notificationMessage = 'Login failed: ${response.body}';
        _notificationColor = Colors.red;
      });
    }
  }


  Future<void> _signup() async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    final url = Uri.parse('$backendUrl/create-user');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      setState(() {
        _notificationMessage = 'Signup successful';
        _notificationColor = Colors.green;
      });
    } else {
      setState(() {
        _notificationMessage = 'Signup failed: ${response.body}';
        _notificationColor = Colors.red;
      });
    }
  }


  Center _buildLoginPage(isAuthenticated) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlockTalkTextField(
                controller: _usernameController,
                labelText: 'Username',
              ),
              const SizedBox(height: 16.0),
              BlockTalkTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: 24.0),
              BlockTalkButton(text: 'Login', type: 'solid', onPressed: () => _login(isAuthenticated)),
              TextButton(
                onPressed: () {
                  setState(() => _authState = _AuthState.signup);
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
    );
  }


  Center _buildSignupPage() {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlockTalkTextField(
                controller: _firstNameController,
                labelText: 'First Name',
              ),
              const SizedBox(height: 12.0),
              BlockTalkTextField(
                controller: _lastNameController,
                labelText: 'Last Name',
              ),
              const SizedBox(height: 12.0),
              BlockTalkTextField(
                controller: _emailController,
                labelText: 'Email',
              ),
              const SizedBox(height: 12.0),
              BlockTalkTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
              ),
              const SizedBox(height: 12.0),
              BlockTalkTextField(
                controller: _usernameController,
                labelText: 'Username',
              ),
              const SizedBox(height: 12.0),
              BlockTalkTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: 24.0),
              BlockTalkButton(
                text: 'Sign Up',
                type: 'solid',
                onPressed: () {
                  _signup();
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() => _authState = _AuthState.login);
                },
                child: const Text(
                  'Already registered? Login',
                  style: TextStyle(color: AppColors.primaryButtonColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider); 
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundColor),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
          if (_notificationMessage != null)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: BlockTalkNotification(
                message: _notificationMessage!,
                color: _notificationColor,
              ),
            ),
            if (_authState == _AuthState.login)
              _buildLoginPage(isAuthenticated)
            else
              _buildSignupPage(),
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
