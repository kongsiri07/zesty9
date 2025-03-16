import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class resetPasswordPage extends StatefulWidget {
  const resetPasswordPage({super.key});

  @override
  State<resetPasswordPage> createState() => _resetPasswordPageState();
}

class _resetPasswordPageState extends State<resetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  // ฟังก์ชันรีเซ็ตรหัสผ่าน
  Future<void> passwordReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);

        // แสดง SnackBar แจ้งเตือนเมื่อส่งอีเมลสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Password reset link sent! Check your email.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color:Colors.purple[400])),
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 100, left: 30, right: 30),
          ),
        );

        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // ถ้าเกิดข้อผิดพลาด ให้แสดงข้อความที่ได้รับจาก Firebase
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? "Something went wrong. Try again!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 100, left: 30, right: 30),
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
        title: Center(
          child: Text('confirm', style: GoogleFonts.poppins(
            color: Colors.white , 
            fontSize: 20 , 
            fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.purple[100],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter your email to get a password reset link',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.purple[400], fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), //สีกรอบ
                  icon: Icon(Icons.mail, color: Colors.purple[100]), 
                  label: Text("Email" , style: GoogleFonts.poppins(color: Colors.purple[100], fontSize: 16 , fontWeight: FontWeight.w200),),
                ),
                style: GoogleFonts.poppins(color: Colors.purple[400]),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: passwordReset,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[100],
                    side: BorderSide(color: Colors.white, width: 1),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    ),
                     minimumSize: Size(150, 60),
              ),
                child: Text(
                  'Reset Password',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}