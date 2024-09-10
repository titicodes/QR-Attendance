import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class VerifyStudentIdentityPage extends StatefulWidget {
  final String? sessionId; // Session ID to associate attendance

  const VerifyStudentIdentityPage({super.key, this.sessionId});

  @override
  _VerifyStudentIdentityPageState createState() =>
      _VerifyStudentIdentityPageState();
}

class _VerifyStudentIdentityPageState extends State<VerifyStudentIdentityPage> {
  String scannedData = '';
  Uint8List? scannedImage; // Store the image of the scanned ID
  bool isScanning = false; // Prevent multiple scans while processing

  // Handle QR code detection
  void _onBarcodeScanned(BarcodeCapture barcodeCapture) {
    if (barcodeCapture.barcodes.isNotEmpty && !isScanning) {
      setState(() {
        isScanning = true; // Lock scanning until processed
        scannedData =
            barcodeCapture.barcodes.first.rawValue ?? ''; // Extract raw value
        scannedImage = barcodeCapture.image; // Capture the image
      });

      // Send scanned data to Firestore
      sendDataToFirestore(scannedData, scannedImage);
    }
  }

  // Send scanned data and image to Firestore
  Future<void> sendDataToFirestore(String data, Uint8List? image) async {
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No data scanned. Identity not verified.'),
      ));
      setState(() {
        isScanning = false; // Reset scanning flag
      });
      return;
    }

    try {
      // Prepare data for Firestore
      Map<String, dynamic> identityData = {
        'scannedData': data,
        'timestamp': FieldValue.serverTimestamp(),
        'sessionId': widget.sessionId,
      };

      // Store identity verification record in Firestore under the specific session
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('class_sessions')
          .doc(widget.sessionId)
          .collection('identity_verifications')
          .add(identityData);

      // If an image is captured, store it
      if (image != null) {
        // Convert image to a base64 string to store in Firestore
        String base64Image = base64Encode(image);
        await docRef.update({'scannedImage': base64Image});
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Data recorded: $data'),
      ));

      // Launch URL if scanned data is a valid URL
      if (Uri.tryParse(data)?.hasScheme == true) {
        await launchUrl(Uri.parse(data));
      }

      // After saving, allow another scan
      setState(() {
        isScanning = false; // Reset scanning flag after processing
        scannedData = ''; // Clear scanned data
        scannedImage = null; // Clear image
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to record data.'),
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
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.normal,
                returnImage:
                    true, // Ensure images are returned with the QR code
              ),
              onDetect: _onBarcodeScanned, // Handle detection of the barcode
            ),
          ),
          if (scannedData.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Scanned Data:',
                style: Theme.of(context).textTheme.titleLarge),
            Text(scannedData),
            const SizedBox(height: 20),
            if (scannedImage != null)
              Image.memory(
                scannedImage!,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ), // Display the scanned image
          ],
          if (isScanning)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
