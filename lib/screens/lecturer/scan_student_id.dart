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

  // Function to handle QR code scanning
  void _onBarcodeScanned(BarcodeCapture? barcodeCapture) {
    if (barcodeCapture != null &&
        barcodeCapture.barcodes.isNotEmpty &&
        !isScanning) {
      setState(() {
        isScanning = true;
        scannedData = barcodeCapture.barcodes.first.rawValue ?? '';
      });

      // Assuming the scanned data is in a specific format: "studentId|name|regNumber"
      var dataParts = scannedData.split('|');
      if (dataParts.length == 3) {
        String studentId = dataParts[0];
        String studentName = dataParts[1];
        String studentRegNumber = dataParts[2];

        // Show and verify the student identity with the scanned data
        _showVerificationDialog(studentId, studentName, studentRegNumber);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid QR code format.'),
        ));
        setState(() {
          isScanning = false;
        });
      }
    }
  }

  // Show dialog to confirm student information
  void _showVerificationDialog(String studentId, String studentName, String studentRegNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Student Information'),
        content: Text('Name: $studentName\nReg Number: $studentRegNumber'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              saveAttendance(studentId); // Save attendance using studentId
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
  }

  // Save attendance in Firestore
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
      setState(() {
        isScanning = false;
      });
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
