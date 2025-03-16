import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobilethree/mainpage.dart';
import 'package:mobilethree/passwordpage.dart';
import 'package:mobilethree/signup_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // บันทึกข้อมูลลง Firestore
        await saveUserToFirestore(user);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }
      }
    } catch (e) {
      print("Error signing in with Google: $e");
    }
  }

  Future<void> saveUserToFirestore(User user) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  final doc = await userRef.get();
  if (!doc.exists) {
    // ถ้ายังไม่มีข้อมูล ให้บันทึกลง Firestore
    await userRef.set({
      'userName': user.displayName ?? "Unknown User",
      'email': user.email,
      'profileImageUrl': user.photoURL ?? "https://via.placeholder.com/150",
      'createdAt': FieldValue.serverTimestamp(),
    });
  } else {
    // อัปเดตข้อมูลล่าสุด
    await userRef.update({
      'userName': user.displayName ?? "Unknown User",
      'profileImageUrl': user.photoURL ?? "https://via.placeholder.com/150",
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(60, 100, 60, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                "assets/imgs/logo.png",
                height: 250,
                width: 250,
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 350,
                child: ElevatedButton.icon(
                  onPressed: signInWithGoogle,
                  icon: Image.asset(
                    "assets/imgs/google.png",
                    height: 20,
                    width: 20,
                  ),
                  label: Text(
                    "Sign in with Google ",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[100],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.purple[100], thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "or",
                      style: TextStyle(
                        color: Colors.purple[100],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.purple[100], thickness: 1),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromARGB(255, 202, 184, 206), width: 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        autofocus: true,
                        decoration: InputDecoration(
                          icon: Icon(Icons.mail, color: Colors.purple[100]),
                          labelText: 'Email',
                          labelStyle: GoogleFonts.poppins(
                              color: Colors.purple[400],
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                          filled: true,
                          fillColor: Colors.amber[50],
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                        ),
                        style: GoogleFonts.poppins(color: Colors.purple[400]),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 350,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PasswordPage(email: emailController.text)),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.purple[100],
                        side: BorderSide(color: Colors.white, width: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: SizedBox(width: double.infinity, height: 20),
                    ),
                    Positioned(
                      child: Text(
                        "Next",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 70),
              SizedBox(
                width: 350,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple[100],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return registPage();
                        }));
                      },
                      child: Text(
                        "Sign up",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.purple[400],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
