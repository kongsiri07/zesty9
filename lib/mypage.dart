import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String userName = "Loading...";
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get('userName') ?? "Unknown User";
          profileImageUrl = userDoc.get('profileImageUrl') ??
              "https://i.pinimg.com/236x/59/af/9c/59af9cd100daf9aa154cc753dd58316d.jpg"; // Default Image
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  void _deletePost(String postId) async {
  try {
    DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    QuerySnapshot commentsSnapshot = await postRef.collection('comments').get();

    for (QueryDocumentSnapshot doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }

    await postRef.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post and comments deleted successfully')),
    );
  } catch (e) {
    print("Error deleting post and comments: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete post')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Page",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.purple[100],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: Colors.purple[200]!, width: 1.5), 
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3), 
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple[300]!, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  userName,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[400]),
                ),
                SizedBox(width: 10),
                Icon(Icons.verified_user, color: Colors.blue, size: 28),
              ],
            ),
          ),
          Divider(thickness: 1, color: Colors.purple[100]),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('userId', isEqualTo: user?.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Don't have post.",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    String postId = doc.id;
                    String imageUrl = data['imageUrl'] ?? '';
                    String description = data['description'] ?? 'No description';
                    Timestamp? timestamp = data['timestamp'] as Timestamp?;
                    String formattedTime = timestamp != null
                        ? DateFormat('MMM d, yyyy • HH:mm').format(timestamp.toDate())
                        : 'Unknown date';

                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                              child: Image.network(
                                imageUrl,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                          color: Colors.purple[400], fontSize: 14),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.purple[100]),
                                      onPressed: () {
                                        _deletePost(postId);
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  description,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
