import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_attemdance/screens/admin/add_course_page.dart';

import 'edit_course_page.dart';

class ManageCoursesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Courses',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .snapshots(), // Listen to changes in Firestore
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Show loading indicator if no data
                  }

                  var courses =
                      snapshot.data!.docs; // Get list of course documents

                  return ListView.builder(
                    itemCount: courses.length, // Number of courses
                    itemBuilder: (context, index) {
                      var course =
                          courses[index]; // Get a single course document
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.book,
                                color: Colors.white), // Course icon
                          ),
                          title: Text(course['courseTitle'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)), // Course title
                          subtitle: Text(
                              'Course Code: ${course['courseCode']}'), // Course code
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blueAccent),
                                onPressed: () {
                                  // Edit course action
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditCoursePage(courseId: course.id),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () async {
                                  // Delete course action
                                  await FirebaseFirestore.instance
                                      .collection('courses')
                                      .doc(course.id)
                                      .delete();
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
          // Navigate to add course page
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddCoursePage()));
        },
      ),
    );
  }
}
