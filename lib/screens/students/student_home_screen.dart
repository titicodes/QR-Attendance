import 'package:flutter/material.dart';
import 'scan_qr_page.dart';
import 'view_attendance_page.dart';

class StudentHomePage extends StatefulWidget {
  final String regNumber; // Add regNumber as a required parameter

  const StudentHomePage({super.key, required this.regNumber});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // Track the selected index
  late AnimationController _controller; // Controller for animation
  late Animation<double> _animation; // Animation for transition

  late List<Widget>
      _pages; // Declare _pages as late to initialize it in initState

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Animation duration
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Smooth curve for animation
    );

    // Initialize the _pages list with the correct regNumber
    _pages = [
      ScanQRPage(), // Page for scanning QR codes
      ViewAttendancePage(
          regNumber: widget.regNumber), // Pass regNumber to ViewAttendancePage
    ];
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Dispose of the animation controller when not in use
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
    _controller.forward(from: 0.0); // Restart the animation on item tap
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Handle sign out
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation, // Apply animation to page transition
        child: _pages[_selectedIndex], // Display the selected page
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Highlight the selected item
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner, size: 28),
            label: 'Scan QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 28),
            label: 'Attendance',
          ),
        ],
      ),
    );
  }
}
