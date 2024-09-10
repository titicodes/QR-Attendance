import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageAttendancePage extends StatefulWidget {
  const ManageAttendancePage({super.key});

  @override
  _ManageAttendancePageState createState() => _ManageAttendancePageState();
}

class _ManageAttendancePageState extends State<ManageAttendancePage> {
  String selectedSessionId = ''; // Track which session is selected
  String searchQuery = '';
  String filterStatus = 'All'; // All, Present, Absent

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Attendance'),
      ),
      body: Column(
        children: [
          // Dropdown to select session
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('class_sessions')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var sessions = snapshot.data!.docs;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: selectedSessionId.isEmpty ? null : selectedSessionId,
                  hint: const Text('Select a class session'),
                  items: sessions.map((session) {
                    return DropdownMenuItem<String>(
                      value: session.id,
                      child: Text(
                          '${session['courseTitle']} - ${session['courseCode']}'),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedSessionId = value!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                  ),
                ),
              );
            },
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search by Registration Number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Filter dropdown for attendance status
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonFormField<String>(
              value: filterStatus,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Present', child: Text('Present')),
                DropdownMenuItem(value: 'Absent', child: Text('Absent')),
              ],
              onChanged: (String? value) {
                setState(() {
                  filterStatus = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
              ),
            ),
          ),

          Expanded(
            child: selectedSessionId.isEmpty
                ? const Center(
                    child: Text('Please select a class session to manage.'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('class_sessions')
                        .doc(selectedSessionId)
                        .collection('attendances')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var students = snapshot.data!.docs;

                      // Filter based on attendance status (Present/Absent)
                      if (filterStatus != 'All') {
                        students = students.where((doc) {
                          return doc['attendanceStatus'] == filterStatus;
                        }).toList();
                      }

                      // Search by registration number
                      if (searchQuery.isNotEmpty) {
                        students = students.where((doc) {
                          return doc['regNumber']
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase());
                        }).toList();
                      }

                      return students.isEmpty
                          ? const Center(child: Text('No students found.'))
                          : ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                var student = students[index];

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Display registration number and QR URL as key-value pairs
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Expanded(
                                              child: Text(
                                                'Reg No.:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                student['regNumber'],
                                                style: const TextStyle(
                                                    fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Expanded(
                                              child: Text(
                                                'QR URL:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () => _launchUrl(
                                                    student['qrUrl']),
                                                child: Text(
                                                  student['qrUrl'],
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.copy),
                                              onPressed: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                      text: student['qrUrl']),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'URL copied to clipboard'),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.share),
                                              onPressed: () {
                                                Share.share(student['qrUrl']);
                                              },
                                            ),
                                            Switch(
                                              value:
                                                  student['attendanceStatus'] ==
                                                      'Present',
                                              onChanged: (bool value) {
                                                _toggleAttendanceStatus(
                                                  student.id,
                                                  value ? 'Present' : 'Absent',
                                                );
                                              },
                                              activeColor: Colors.green,
                                              inactiveThumbColor: Colors.red,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                _deleteAttendanceRecord(
                                                    student.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Toggle attendance status between Present and Absent
  Future<void> _toggleAttendanceStatus(
      String studentId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('class_sessions')
        .doc(selectedSessionId)
        .collection('attendances')
        .doc(studentId)
        .update({'attendanceStatus': newStatus});
  }

  // Delete an attendance record
  Future<void> _deleteAttendanceRecord(String studentId) async {
    await FirebaseFirestore.instance
        .collection('class_sessions')
        .doc(selectedSessionId)
        .collection('attendances')
        .doc(studentId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance record deleted')),
    );
  }

  // Launch the URL in the browser
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }
}
