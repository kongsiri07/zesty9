import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Fashion', 'Game', 'Music', 'Food', 'Travel'];

  Future<void> _submitPost() async {
    String description = _descriptionController.text.trim();
    String imageUrl = _imageUrlController.text.trim();
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please LOGIN!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'description': description.isNotEmpty ? description : "",
        'category': _selectedCategory,
        'imageUrl': imageUrl.isNotEmpty ? imageUrl : "",
        'userId': user.uid,
        'userName': user.displayName ?? user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post success!')),
      );

      _descriptionController.clear();
      _imageUrlController.clear();
      setState(() {
        _selectedCategory = 'All';
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple[100],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Post Details', style: TextStyle(color: Colors.purple[400], fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _descriptionController,
              cursorColor: Colors.purple[400],
              style: TextStyle(color: Colors.purple[400]), 
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your post details...',
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                  ),
                enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.purple[100]!, width: 1.5),
                  ),
                focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.purple[400]!, width: 2.0),
               ),
              ),
            ),
            SizedBox(height: 16),

            Text('Select Category', style: TextStyle(color: Colors.purple[400], fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(
                    category,
                    style: TextStyle(
                      color: Colors.purple[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              icon: Icon(
              Icons.arrow_drop_down, 
              color: Colors.purple[400],
              size: 28,
            ),
                decoration: InputDecoration(
                filled: true,
                fillColor: Colors.amber[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.purple[100]!, 
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.purple[100]!,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.purple[100]!,
                    width: 2.0,
                  ),
                ),
              ),
              dropdownColor: Colors.purple[50],
            ),

            SizedBox(height: 16),

            Text('Image URL', style: TextStyle(color: Colors.purple[400], fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _imageUrlController,
              cursorColor: Colors.purple[400],
              style: TextStyle(color: Colors.purple[400]), 
              decoration: InputDecoration(
                hintText: 'Enter Image URL...',
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                  ),
                enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.purple[100]!, width: 1.5),
                  ),
                focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.purple[400]!, width: 2.0),
               ),
              ),
            ),
            SizedBox(height: 16),

            Center(
              child: ElevatedButton(
                onPressed: _submitPost,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[200]),
                child: Text('Post', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
