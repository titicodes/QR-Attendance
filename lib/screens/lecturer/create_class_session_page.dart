import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'scan_student_id.dart';

class CreateClassSessionPage extends StatefulWidget {
  const CreateClassSessionPage({super.key});

  @override
  _CreateClassSessionPageState createState() => _CreateClassSessionPageState();
}

class _CreateClassSessionPageState extends State<CreateClassSessionPage> {
  final _formKey = GlobalKey<FormState>();
  String courseTitle = '';
  String courseCode = '';
  String date = '';
  String time = '';
  String level = '';
  String venue = '';

  Future<void> _createSession() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Add session data to Firestore
      DocumentReference sessionRef =
          await FirebaseFirestore.instance.collection('class_sessions').add({
        'courseTitle': courseTitle,
        'courseCode': courseCode,
        'date': date,
        'time': time,
        'level': level,
        'venue': venue,
      });

      // Navigate to ScanStudentIDPage after session creation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScanStudentIDPage(sessionId: sessionRef.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Class Session'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Course Title', (value) => courseTitle = value),
                _buildTextField('Course Code', (value) => courseCode = value),
                _buildTextField('Date', (value) => date = value),
                _buildTextField('Time', (value) => time = value),
                _buildTextField('Level', (value) => level = value),
                _buildTextField('Venue', (value) => venue = value),
                const SizedBox(height: 20),
                Center(
                  // Center the button
                  child: SizedBox(
                    width: double
                        .infinity, // Make the button width match the text fields
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blueAccent,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: _createSession,
                      child: const Text(
                        'Create Session',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
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

  Widget _buildTextField(String label, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: onChanged,
        validator: (value) => value?.isEmpty == true ? 'Required' : null,
      ),
    );
  }
}
