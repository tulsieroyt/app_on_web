import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> addTodo(String title, String description) async {
    try {
      await FirebaseFirestore.instance.collection('todo').add({
        'title': title,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Todo added successfully!");
    } catch (e) {
      print("Error adding todo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('App on Web'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('todo')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No todos available"));
            }
            final todos = snapshot.data!.docs;
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    todos[index].data() as Map<String, dynamic>;
                String docId = todos[index].id; // Get document ID for deletion

                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'), // Show serial number
                  ),
                  title: Text(data['title'] ?? 'No Title'),
                  subtitle: Text(data['description'] ?? 'No Description'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        FirebaseFirestore.instance
                            .collection('todo')
                            .doc(docId)
                            .delete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    icon: Icon(Icons.more_vert),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      Text(
                        'Add ToDo',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              addTodo(
                                titleController.text.trim(),
                                descriptionController.text.trim(),
                              );
                              setState(() {});
                            }
                            Navigator.pop(context);
                          },
                          child: Text('Add'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
