import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_attemdance/screens/admin/add_user_screen.dart';
import 'package:qr_attemdance/screens/admin/edit_user_screen.dart';

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Users', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(user['fullName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Role: ${user['role']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () {
                                  // Edit user action
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditUserPage(userId: user.id),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () async {
                                  // Delete user action
                                  await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
                                },
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
        onPressed: () {
          // Navigate to add user page
          Navigator.push(context, MaterialPageRoute(builder: (context) =>  AddUserPage()));
        },
      ),
    );
  }
}
