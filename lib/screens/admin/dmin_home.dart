import 'package:flutter/material.dart';
import 'package:qr_attemdance/screens/admin/manage_course.dart';
import 'package:qr_attemdance/screens/admin/manage_user.dart';
import 'package:qr_attemdance/screens/admin/view_starts.dart';
import 'package:qr_attemdance/services/firestore_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  final AuthService _auth = AuthService(); // Initialize AuthService

  final List<Widget> _pages = [
    const ManageUsersPage(),
    ManageCoursesPage(),
    const SystemStatisticsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.forward(from: 0.0);
  }

  Future<void> _signOut() async {
    await _auth.signOut(); // Sign out the user using AuthService
    Navigator.pushReplacementNamed(context, '/'); // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard',
            style: Theme.of(context).textTheme.titleLarge),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _signOut(); // Call the sign-out method when pressed
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school, size: 28),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics, size: 28),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
