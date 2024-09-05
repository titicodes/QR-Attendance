import 'package:flutter/material.dart';
import 'package:qr_attemdance/models/user_model.dart';
import 'package:qr_attemdance/services/firestore_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String fullName = '';
  String phoneNumber = '';
  String role = 'student'; // default role
  bool isLoading = false; // Loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Your Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Full Name',
                  icon: Icons.person,
                  onSaved: (val) => fullName = val!,
                  validator: (val) =>
                      val!.isEmpty ? 'Enter your full name' : null,
                ),
                _buildTextField(
                  label: 'Phone Number',
                  icon: Icons.phone,
                  onSaved: (val) => phoneNumber = val!,
                  validator: (val) =>
                      val!.isEmpty ? 'Enter your phone number' : null,
                ),
                _buildTextField(
                  label: 'Email',
                  icon: Icons.email,
                  onSaved: (val) => email = val!,
                  validator: (val) => val!.isEmpty ? 'Enter your email' : null,
                ),
                _buildTextField(
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  onSaved: (val) => password = val!,
                  validator: (val) =>
                      val!.isEmpty ? 'Enter your password' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: role,
                  onChanged: (String? newValue) {
                    setState(() {
                      role = newValue!;
                    });
                  },
                  items: <String>['admin', 'lecturer', 'student']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blueAccent,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              setState(() {
                                isLoading = true; // Start loading
                              });
                              AppUser? user = await _auth.signUp(
                                  email, password, role, fullName, phoneNumber);
                              setState(() {
                                isLoading = false; // Stop loading
                              });
                              if (user != null) {
                                _navigateToLoginScreen(); // Navigate to the login screen
                              }
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Already have an account? Log In',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        obscureText: obscureText,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  void _navigateToLoginScreen() {
    Navigator.pushReplacementNamed(
        context, '/login'); // Navigate to the login screen
  }
}
