import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobilethree/mainpage.dart';
import 'package:mobilethree/repasswpage.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordPage extends StatefulWidget {
  final String email;

  const PasswordPage({super.key, required this.email});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> { 
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  bool _isObscure = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: widget.email,
          password: passwordController.text,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );

        print("Login Successful: ${userCredential.user?.email}");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Login failed",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        title: Text(
          "Login",
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[100],
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 50, 30, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ลดขนาดเนื้อหา
            children: [
              SizedBox(
                height: 200, // จำกัดขนาดรูปภาพเพื่อป้องกัน Overflow
                child: Image.asset("assets/imgs/logo.png"),
              ),
              const SizedBox(height: 10),
              Text(
                "for ${widget.email}",
                style: GoogleFonts.poppins(
                    color: Colors.purple[400],
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                'Please enter your password ',
                style: GoogleFonts.poppins(color: Colors.purple[400], fontSize: 14),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromARGB(255, 216, 186, 221), width: 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock, color: Colors.purple[100]),
                          label: Text(
                            "Password",
                            style: GoogleFonts.poppins(
                                color: Colors.purple[100],
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          filled: true,
                          fillColor: Colors.amber[50],
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                            icon: Icon(
                              _isObscure ? Icons.visibility_off : Icons.visibility,
                              color: Colors.purple[100],
                            ),
                          ),
                        ),
                        style: GoogleFonts.poppins(color: Colors.purple[400]),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 120, // กำหนดขนาดปุ่มเพื่อให้เหมาะกับ UI
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[100],
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => resetPasswordPage()),
                  );
                },
                child: Text(
                  "Forgot Password?",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
