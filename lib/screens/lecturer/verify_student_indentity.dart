import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class VerifyStudentIdentityPage extends StatefulWidget {
  final String? sessionId; // Make sessionId optional

  const VerifyStudentIdentityPage({super.key, this.sessionId});

  @override
  _VerifyStudentIdentityPageState createState() => _VerifyStudentIdentityPageState();
}

class _VerifyStudentIdentityPageState extends State<VerifyStudentIdentityPage> {
  String scannedData = '';
  String studentName = '';
  String studentRegNumber = '';
  bool isScanning = false; // Prevent multiple scans while processing

  void _onBarcodeScanned(BarcodeCapture? barcodeCapture) {
    if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty && !isScanning) {
      setState(() {
        isScanning = true;
        scannedData = barcodeCapture.barcodes.first.rawValue ?? ''; // Get the first barcode's rawValue
        parseScannedData(scannedData);
      });

      // Record attendance after parsing data
      recordAttendance();
    }
  }

  void parseScannedData(String data) {
    List<String> parts = data.split(';');
    for (String part in parts) {
      if (part.startsWith('name:')) {
        studentName = part.substring(5);
      } else if (part.startsWith('regNumber:')) {
        studentRegNumber = part.substring(10);
      }
    }
  }

  Future<void> recordAttendance() async {
    try {
      if (studentName.isEmpty || studentRegNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid student data. Attendance not recorded.'),
        ));
        setState(() {
          isScanning = false; // Reset scanning flag
        });
        return;
      }

      // Prepare data for Firestore
      Map<String, dynamic> attendanceData = {
        'studentName': studentName,
        'studentRegNumber': studentRegNumber,
        'timestamp': FieldValue.serverTimestamp(),
        'sessionId': widget.sessionId,
      };

      // Store attendance record in Firestore under the specific session
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .collection('attendance')
          .add(attendanceData);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Attendance recorded successfully!'),
      ));

      setState(() {
        isScanning = false; // Reset scanning flag after processing
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to record attendance.'),
      ));

      setState(() {
        isScanning = false; // Reset scanning flag after error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Student Identity')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: _onBarcodeScanned,
            ),
          ),
          if (studentName.isNotEmpty || studentRegNumber.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Student Information:', style: Theme.of(context).textTheme.titleLarge),
            Text('Name: $studentName'),
            Text('Registration Number: $studentRegNumber'),
          ],
        ],
      ),
    );
  }
}
