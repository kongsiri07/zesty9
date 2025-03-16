import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mobilethree/postpage/creatpost.dart';
import 'package:mobilethree/profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'All';
  final user = FirebaseAuth.instance.currentUser;

  void _navigateToPage(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _goToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePostPage()),
    );
  }

  // ฟังก์ชันกดหัวใจโพสต์
  void _toggleLike(String postId, List<dynamic> likes) async {
    if (user == null) return;
    String userId = user!.uid;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (likes.contains(userId)) {
      await postRef.update({'likes': FieldValue.arrayRemove([userId])});
    } else {
      await postRef.update({'likes': FieldValue.arrayUnion([userId])});
    }
  }

  // ฟังก์ชันเพิ่มคอมเมนต์
void _addComment(String postId) {
  TextEditingController commentController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Add a Comment"),
      content: TextField(
        controller: commentController,
        decoration: InputDecoration(hintText: "Write a comment..."),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () async {
            if (commentController.text.trim().isNotEmpty && user != null) {
              String userId = user!.uid;
              String userName = "Unknown User";
              String profileImage = "";

              try {
                DocumentSnapshot userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get();

                if (userDoc.exists) {
                  var userData = userDoc.data() as Map<String, dynamic>;

                  // เช็คว่ามีข้อมูลหรือไม่
                  userName = userData['userName'] ?? "Unknown User";
                  profileImage = userData['profileImage'] ?? "";
                }
              } catch (e) {
                print("🔥 ERROR: $e");
              }

              await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .add({
                'userId': userId,
                'userName': userName,
                'profileImage': profileImage,
                'comment': commentController.text.trim(),
                'timestamp': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            }
          },
          child: Text("Post", style: TextStyle(color: Colors.purple[400])),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/imgs/logo.png', height: 60, width: 80),
            SizedBox(width: 8),
            Text('Zesty9', style: TextStyle(fontFamily: 'Gorditas', fontSize: 24, color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.purple[100],
      ),
      body: _selectedIndex == 0
          ? Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.amber[50],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['All', 'Food', 'Travel', 'Music', 'Fashion', 'Game']
                          .map((category) => GestureDetector(
                                onTap: () => _navigateToPage(category),
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.purple[200]!),
                                    borderRadius: BorderRadius.circular(12),
                                    color: _selectedCategory == category ? Colors.purple[300] : Colors.purple[100],
                                  ),
                                  child: Text(category, style: TextStyle(color: Colors.white, fontSize: 16)),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No posts available.'));
                      }

                      var posts = snapshot.data!.docs;
                      if (_selectedCategory != 'All') {
                        posts = posts.where((doc) {
                          final data = doc.data() as Map<String, dynamic>?;
                          return data != null && data['category'] == _selectedCategory;
                        }).toList();
                      }

                      return ListView(
                        children: posts.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          String postId = doc.id;
                          String imageUrl = data['imageUrl'] ?? '';
                          String userName = data['userName'] ?? user?.displayName ?? 'Unknown User';
                          String description = data['description'] ?? 'No description';
                          Timestamp? timestamp = data['timestamp'] as Timestamp?;
                          List<dynamic> likes = data['likes'] ?? [];
                          bool isLiked = user != null && likes.contains(user!.uid);
                          String formattedTime = timestamp != null
                              ? DateFormat('MMM d, yyyy • HH:mm').format(timestamp.toDate())
                              : 'Unknown date';

                          return Card(
                            color:Colors.white,
                            margin: EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.purple[200]!)),
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
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.purple[100],
                                        radius: 14,
                                        backgroundImage: data['profileImage'] != null && data['profileImage'].isNotEmpty
                                            ? NetworkImage(data['profileImage'])
                                            : AssetImage('assets/imgs/default_profile.png') as ImageProvider,
                                      ),

                                          SizedBox(width: 8),
                                          Text(userName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple[400])),
                                          Spacer(),
                                          Text(formattedTime, style: TextStyle(color: Colors.purple[600], fontSize: 14)),
                                        ],
                                      ),

                                      SizedBox(height: 5),
                                      Text(description, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey),
                                            onPressed: () => _toggleLike(postId, likes),
                                          ),
                                          Text('${likes.length}', style: TextStyle( color: Colors.black, fontSize: 16)),
                                          IconButton(
                                            icon: Icon(Icons.comment, color: Colors.purple[400]),
                                            onPressed: () => _addComment(postId),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      StreamBuilder(
                                        stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').orderBy('timestamp', descending: true).snapshots(),
                                        builder: (context, AsyncSnapshot<QuerySnapshot> commentSnapshot) {
                                          if (!commentSnapshot.hasData || commentSnapshot.data!.docs.isEmpty) {
                                            return SizedBox();
                                          }
                                          return Column(
                                            children: commentSnapshot.data!.docs.map((commentDoc) {
                                              final commentData = commentDoc.data() as Map<String, dynamic>;
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  radius: 16,
                                                    backgroundColor: Colors.white,
                                                    backgroundImage: commentData['profileImage'] != null && commentData['profileImage'].isNotEmpty
                                                        ? NetworkImage(commentData['profileImage'])
                                                        : AssetImage('assets/imgs/default_profile.png') as ImageProvider,
                                                  ),


                                                title: Text(commentData['userName'] ?? 'Unknown User', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[300])),
                                                subtitle: Text(commentData['comment'] ?? '',style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black)),
                                              );
                                            }).toList(),
                                          );
                                        },
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
            )
          : ProfilePage(),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreatePostPage()),
                  );
                },
                backgroundColor: Colors.purple[400],
                child: Icon(Icons.add, color: Colors.white, size: 30),
                shape: CircleBorder(),
                elevation: 8,
              ),

              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

              bottomNavigationBar: BottomAppBar(
                shape: CircularNotchedRectangle(),
                color: Colors.purple[100], // สีของแถบบาร์ด้านล่าง
                child: Container(
                  height: 10,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.home, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 0;
                          });
                        },
                      ),
                      SizedBox(width: 40),
                      IconButton(
                        icon: Icon(Icons.person, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
             );
            }
        }