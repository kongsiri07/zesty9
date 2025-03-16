import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobilethree/loginpage.dart';
import 'package:mobilethree/mypage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController urlController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  //ฟังก์ชันอัปเดตรูปโปรไฟล์
  Future<void> _updateProfileImage() async {
  String newUrl = urlController.text.trim();

  if (newUrl.isNotEmpty && user != null) {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'profileImageUrl': newUrl,
      });

      urlController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile picture updated successfully!")),
      );

      setState(() {});
    } catch (e) {
      print("Error updating profile image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update image URL")),
      );
    }
  }
}

  //ฟังก์ชันอัปเดตชื่อผู้ใช้
  Future<void> _updateUserName() async {
    String newName = nameController.text.trim();
    if (newName.isNotEmpty && user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'userName': newName,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Username updated successfully!")),
        );
      } catch (e) {
        print("Error updating username: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update username")),
        );
      }
    }
  }


//Dialog สำหรับแก้ไขรูปโปรไฟล์
  void _showImageUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Profile Picture"),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(labelText: "Enter Image URL"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              urlController.clear();
              Navigator.pop(context);
            },
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateProfileImage();
            },
            child: Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  //สำหรับแก้ไขชื่อผู้ใช้
  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Username"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: "Enter new username"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateUserName();
            },
            child: Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!;
          String userName = userData['userName'] ?? "Unknown User";
          String profileImageUrl = userData['profileImageUrl'] ?? "https://via.placeholder.com/150";

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(profileImageUrl),
                          onBackgroundImageError: (_, __) {
                            setState(() {
                              profileImageUrl = "https://via.placeholder.com/150";
                            });
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImageUrlDialog,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.edit, size: 16, color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    color: Colors.purple[400],
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _showEditNameDialog,
                                child: Icon(Icons.edit, size: 18, color: Colors.red),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            user?.email ?? "Email not available",
                            style: TextStyle(fontSize: 16, color: Colors.purple[200]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(thickness: 1, color: Colors.purple[100]),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyPage()),
                        );
                      },
                      splashColor: Colors.purple[50], 
                      borderRadius: BorderRadius.circular(12), 
                      child: ListTile(
                        leading: Icon(Icons.home, color: Colors.purple[400]),
                        title: Text("My page", style: TextStyle(color: Colors.purple[400], fontSize: 18)),
                      ),
                    ),

                    Divider(thickness: 1, color: Colors.purple[100]),

                    InkWell(
                      onTap: () {},
                      splashColor: Colors.purple[50], 
                      borderRadius: BorderRadius.circular(12), 
                      child: ListTile(
                        leading: Icon(Icons.notifications, color: Colors.purple[400]),
                        title: Text("Notifications", style: TextStyle(color: Colors.purple[400], fontSize: 18)),
                      ),
                    ),

                    InkWell(
                      onTap: () {},
                      splashColor: Colors.purple[50], 
                      borderRadius: BorderRadius.circular(12), 
                      child: ListTile(
                        leading: Icon(Icons.share, color: Colors.purple[400]),
                        title: Text("Share profile", style: TextStyle(color: Colors.purple[400], fontSize: 18)),
                      ),
                    ),

                    InkWell(
                      onTap: () {},
                      splashColor: Colors.purple[50], 
                      borderRadius: BorderRadius.circular(12), 
                      child: ListTile(
                        leading: Icon(Icons.settings, color: Colors.purple[400]),
                        title: Text("Settings", style: TextStyle(color: Colors.purple[400], fontSize: 18)),
                      ),
                    ),

                    Divider(thickness: 1, color: Colors.purple[100]),

                    InkWell(
                      onTap: () {},
                      splashColor: Colors.purple[50], 
                      borderRadius: BorderRadius.circular(12), 
                      child: ListTile(
                        leading: Icon(Icons.quiz, color: Colors.purple[400]),
                        title: Text("Hlep center", style: TextStyle(color: Colors.purple[400], fontSize: 18)),
                      ),
                    ),

                    InkWell(
                      onTap: () {},
                      splashColor: Colors.purple[50], 
                      borderRadius: BorderRadius.circular(12), 
                      child: ListTile(
                        leading: Icon(Icons.diamond, color: Colors.purple[400]),
                        title: Text("About Zesty9", style: TextStyle(color: Colors.purple[400], fontSize: 18)),
                      ),
                    ),

                    Divider(thickness: 1, color: Colors.purple[100]),

                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.purple[400]),
                      title: Text("Sign Out", style: TextStyle(color: Colors.purple[400], fontSize: 18)),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Sign Out"),
                          content: Text("Are you sure you want to sign out?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen()),
                                );
                              },
                              child: Text("Yes", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}