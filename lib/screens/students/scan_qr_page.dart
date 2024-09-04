import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  _ScanQRPageState createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  final _formKey = GlobalKey<FormState>();
  String regNumber = ''; // Variable to store registration number
  String fullName = ''; // Variable to store full name
  String? scannedSessionId; // Store the scanned session ID
  bool isScanning = false;

  void _onBarcodeScanned(BarcodeCapture? barcodeCapture) {
    if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty && !isScanning) {
      setState(() {
        isScanning = true;
        scannedSessionId = barcodeCapture.barcodes.first.rawValue; // Use the first barcode's rawValue
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: MobileScanner(
                onDetect: _onBarcodeScanned,
              ),
            ),
            const SizedBox(height: 20),
            if (scannedSessionId != null)
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Registration Number'),
                      onSaved: (val) => regNumber = val!,
                      validator: (val) => val!.isEmpty ? 'Enter your registration number' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      onSaved: (val) => fullName = val!,
                      validator: (val) => val!.isEmpty ? 'Enter your full name' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      child: const Text('Confirm Attendance'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          // Store attendance record in Firestore under the specific session
                          await FirebaseFirestore.instance
                              .collection('sessions')
                              .doc(scannedSessionId)
                              .collection('attendances')
                              .add({
                            'regNumber': regNumber,
                            'studentName': fullName,
                          });

                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Attendance Confirmed!'),
                          ));

                          setState(() {
                            scannedSessionId = null; // Reset after submission
                            isScanning = false; // Allow new scans
                          });
                        }
                      },
                    ),
                  ],
                ),
              )
            else
              const Text('Scan a QR code to register your attendance'),
          ],
        ),
      ),
    );
  }
}
