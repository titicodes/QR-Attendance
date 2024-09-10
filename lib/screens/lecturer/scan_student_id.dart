import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_attemdance/screens/lecturer/manage_attendance_page.dart';
import 'package:qr_attemdance/screens/lecturer/lecturer_home_screen.dart'; // Import Lecturer Home Page

class ScanStudentIDPage extends StatefulWidget {
  final String sessionId;

  const ScanStudentIDPage({super.key, required this.sessionId});

  @override
  State<ScanStudentIDPage> createState() => _ScanStudentIDPageState();
}

class _ScanStudentIDPageState extends State<ScanStudentIDPage> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: true,
  );
  bool isScanning = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // Disable back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan Student ID'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      const ManageAttendancePage(),
                ));
              },
              icon: const Icon(Icons.list_alt),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 4,
              child: MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  if (!isScanning) {
                    setState(() => isScanning = true);
                    final Barcode barcode = capture.barcodes.first;
                    _handleScannedQRCode(barcode.rawValue ?? "");
                  }
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ManageAttendancePage(),
                      ));
                    },
                    child: const Text('View Scanned Students'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      cameraController.start();
                      setState(() => isScanning = false);
                    },
                    child: const Text('Scan Next Student'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _finishScanning();
                    },
                    child: const Text('Finish Scanning'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleScannedQRCode(String qrData) async {
    if (qrData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR Code')),
      );
      return;
    }

    String? regNumber = await _promptForRegNumber();

    if (regNumber != null && regNumber.isNotEmpty) {
      await _saveToFirestore(qrData, regNumber);
    }

    setState(() => isScanning = false);
  }

  Future<String?> _promptForRegNumber() async {
    String? regNumber;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Registration Number'),
          content: TextField(
            onChanged: (value) {
              regNumber = value;
            },
            decoration: const InputDecoration(hintText: "Enter reg number"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(regNumber);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    return regNumber;
  }

  Future<void> _saveToFirestore(String qrData, String regNumber) async {
    try {
      await FirebaseFirestore.instance
          .collection('class_sessions')
          .doc(widget.sessionId)
          .collection('attendances')
          .add({
        'qrUrl': qrData,
        'regNumber': regNumber,
        'timestamp': FieldValue.serverTimestamp(),
        'attendanceStatus': 'Present',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  void _finishScanning() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) =>
              const LecturerHomePage()), // Navigate back to the home page
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
