import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>(); // Form key to validate form inputs
  String courseCode = ''; // Store the course code
  String courseTitle = ''; // Store the course title

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Course')), // App bar title
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the form
        child: Form(
          key: _formKey, // Assigning form key to the form
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Course Code'), // Input field for course code
                onSaved: (val) => courseCode = val!, // Save the input value
                validator: (val) => val!.isEmpty
                    ? 'Enter course code'
                    : null, // Validate the input
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Course Title'), // Input field for course title
                onSaved: (val) => courseTitle = val!, // Save the input value
                validator: (val) => val!.isEmpty
                    ? 'Enter course title'
                    : null, // Validate the input
              ),
              const SizedBox(
                  height: 20), // Space between input fields and button
              ElevatedButton(
                child: const Text('Add Course'), // Button label
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Check if the form is valid
                    _formKey.currentState!.save(); // Save the form state

                    // Add course to Firestore
                    await FirebaseFirestore.instance.collection('courses').add({
                      'courseCode': courseCode,
                      'courseTitle': courseTitle,
                    });

                    Navigator.pop(context); // Go back after adding the course
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
