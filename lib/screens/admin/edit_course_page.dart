import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCoursePage extends StatefulWidget {
  final String courseId;  // Course ID passed from the ManageCoursesPage

  const EditCoursePage({super.key, required this.courseId});

  @override
  _EditCoursePageState createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  final _formKey = GlobalKey<FormState>();  // Form key for validation
  String courseCode = '';  // Variable to hold course code
  String courseTitle = '';  // Variable to hold course title

  @override
  void initState() {
    super.initState();
    _loadCourseData();  // Load the course data when the page initializes
  }

  // Function to load course data from Firestore
  void _loadCourseData() async {
    DocumentSnapshot courseDoc = await FirebaseFirestore.instance.collection('courses').doc(widget.courseId).get();

    setState(() {
      courseCode = courseDoc['courseCode'];  // Set course code
      courseTitle = courseDoc['courseTitle'];  // Set course title
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: courseCode,  // Set initial value of course code
                decoration: const InputDecoration(labelText: 'Course Code'),
                onSaved: (val) => courseCode = val!,  // Save the updated course code
                validator: (val) => val!.isEmpty ? 'Enter course code' : null,  // Validate the course code input
              ),
              TextFormField(
                initialValue: courseTitle,  // Set initial value of course title
                decoration: const InputDecoration(labelText: 'Course Title'),
                onSaved: (val) => courseTitle = val!,  // Save the updated course title
                validator: (val) => val!.isEmpty ? 'Enter course title' : null,  // Validate the course title input
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Update Course'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {  // Validate the form
                    _formKey.currentState!.save();  // Save the form state

                    // Update the course in Firestore
                    await FirebaseFirestore.instance.collection('courses').doc(widget.courseId).update({
                      'courseCode': courseCode,
                      'courseTitle': courseTitle,
                    });

                    Navigator.pop(context);  // Navigate back after updating
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
