import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String phoneNumber = '';
  String role = 'student'; // Default role
  String email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                onSaved: (val) => fullName = val!,
                validator: (val) => val!.isEmpty ? 'Enter full name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                onSaved: (val) => phoneNumber = val!,
                validator: (val) => val!.isEmpty ? 'Enter phone number' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (val) => email = val!,
                validator: (val) => val!.isEmpty ? 'Enter email' : null,
              ),
              DropdownButtonFormField<String>(
                value: role,
                onChanged: (String? newValue) {
                  setState(() {
                    role = newValue!;
                  });
                },
                items: <String>['admin', 'lecturer', 'student'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Add User'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    await FirebaseFirestore.instance.collection('users').add({
                      'fullName': fullName,
                      'phoneNumber': phoneNumber,
                      'role': role,
                      'email': email,
                    });

                    Navigator.pop(context); // Go back after adding the user
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
