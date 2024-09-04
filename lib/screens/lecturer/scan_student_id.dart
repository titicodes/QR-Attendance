import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanStudentIDPage extends StatefulWidget {
  final String sessionId;

  const ScanStudentIDPage({super.key, required this.sessionId});

  @override
  _ScanStudentIDPageState createState() => _ScanStudentIDPageState();
}

class _ScanStudentIDPageState extends State<ScanStudentIDPage> {
  String scannedData = '';
  bool isScanning = false;

  void _onBarcodeScanned(BarcodeCapture? barcodeCapture) {
    if (barcodeCapture != null &&
        barcodeCapture.barcodes.isNotEmpty &&
        !isScanning) {
      setState(() {
        isScanning = true;
        scannedData = barcodeCapture.barcodes.first.rawValue ?? '';
      });

      // Verify the student identity with the scanned data
      verifyStudentIdentity(scannedData);
    }
  }

  Future<void> verifyStudentIdentity(String studentId) async {
    if (studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No student ID scanned.'),
      ));
      setState(() {
        isScanning = false;
      });
      return;
    }

    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        String studentName = studentDoc['name'];
        String studentRegNumber = studentDoc['regNumber'];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Student Verified'),
            content: Text('Name: $studentName\nReg Number: $studentRegNumber'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  saveAttendance(studentId);
                },
                child: const Text('Confirm'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    scannedData = '';
                    isScanning = false;
                  });
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Student not found.'),
        ));
        setState(() {
          isScanning = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error fetching student data.'),
      ));
      setState(() {
        isScanning = false;
      });
    }
  }

  Future<void> saveAttendance(String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('class_sessions')
          .doc(widget.sessionId)
          .collection('attendances')
          .add({
        'studentId': studentId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Attendance recorded for $studentId'),
      ));
      setState(() {
        isScanning = false; // Allow rescan after recording attendance
        scannedData = ''; // Clear scanned data
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to record attendance.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Student ID')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: _onBarcodeScanned,
            ),
          ),
          if (scannedData.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Scanned Data: $scannedData'),
            ),
        ],
      ),
    );
  }
}
