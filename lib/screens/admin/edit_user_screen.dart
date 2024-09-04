import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserPage extends StatefulWidget {
  final String userId;

  const EditUserPage({super.key, required this.userId});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String phoneNumber = '';
  String role = 'student';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    setState(() {
      fullName = userDoc['fullName'];
      phoneNumber = userDoc['phoneNumber'];
      role = userDoc['role'];
      email = userDoc['email'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: fullName,
                decoration: InputDecoration(labelText: 'Full Name'),
                onSaved: (val) => fullName = val!,
                validator: (val) => val!.isEmpty ? 'Enter full name' : null,
              ),
              TextFormField(
                initialValue: phoneNumber,
                decoration: InputDecoration(labelText: 'Phone Number'),
                onSaved: (val) => phoneNumber = val!,
                validator: (val) => val!.isEmpty ? 'Enter phone number' : null,
              ),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: 'Email'),
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
                items: <String>['admin', 'lecturer', 'student']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Role'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Update User'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .update({
                      'fullName': fullName,
                      'phoneNumber': phoneNumber,
                      'role': role,
                      'email': email,
                    });

                    Navigator.pop(context); // Go back after updating the user
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
