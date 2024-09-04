import 'package:flutter/material.dart';
import 'package:qr_attemdance/models/user_model.dart';
import '../services/firestore_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 100),
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please log in to your account.',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                      label: 'Email',
                      icon: Icons.email,
                      onSaved: (val) => email = val!,
                      validator: (val) => val!.isEmpty ? 'Enter your email' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                      onSaved: (val) => password = val!,
                      validator: (val) => val!.isEmpty ? 'Enter your password' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 18, color: Colors.blueAccent),
                        minimumSize: Size(double.infinity, 50), // Full width
                      ),
                      child: const Text('Login'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          AppUser? user = await _auth.signIn(email, password);
                          if (user != null) {
                            _navigateToHomeScreen(user);
                          } else {
                            setState(() {
                              errorMessage = 'Failed to sign in. Please check your credentials.';
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signUp');
                            },
                            child: const Text(
                              'Don’t have an account? Sign Up',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextButton(
                            onPressed: () => _showForgotPasswordDialog(),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool obscureText = false,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: obscureText,
      onSaved: onSaved,
      validator: validator,
    );
  }

  void _navigateToHomeScreen(AppUser user) {
    if (user.role == 'admin') {
      Navigator.pushReplacementNamed(context, '/adminHome');
    } else if (user.role == 'lecturer') {
      Navigator.pushReplacementNamed(context, '/lecturerHome');
    } else if (user.role == 'student') {
      Navigator.pushReplacementNamed(context, '/studentHome');
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String email = '';
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            decoration: const InputDecoration(hintText: "Enter your email"),
            onChanged: (value) {
              email = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (email.isNotEmpty) {
                  await _auth.resetPassword(email);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset email sent')),
                  );
                }
              },
              child: const Text('Send Reset Link'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}