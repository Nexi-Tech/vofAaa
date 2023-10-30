import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vof/components/my_button.dart';
import 'package:vof/components/my_textfield.dart';
import 'package:vof/main.dart';
import 'package:vof/pages/home_page.dart';
import 'package:vof/pages/home_page_user.dart';
import 'package:vof/pages/registration_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signUserIn() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final user = userCredential.user;
      final userDoc = await FirebaseFirestore.instance.collection("users").doc(user?.uid).get();
      final role = userDoc.get("role");

      if (role == "user") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePageUser()));
      } else if (role == "admin") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        showErrorMessage("Wrong email. Please check your email.");
      } else if (e.code == 'too-many-requests' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        showErrorMessage("Invalid password. Please try again.");
      // }else if(e.code == 'INVALID_LOGIN_CREDENTIALS'){
      //   showErrorMessage("Invalid password. Please try again.");
    }else {
        showErrorMessage("An error occurred: ${e.code}");
      }
    }
    catch (e) {
      showErrorMessage("An error occurred: $e");
    }
  }

  void navigateToRegistration() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage()));
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red,
        title: Center(
          child: Text(message, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MyTextField(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: sendPasswordResetEmail,
              child: Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }

  void sendPasswordResetEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset email sent to ${emailController.text}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send password reset email: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
                    },
                  ),
                  SizedBox(width: 90),
                  Icon(Icons.lock, size: 100),
                ],
              ),
              SizedBox(height: 50),
              Text('Welcome back you\'ve been missed!', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
              SizedBox(height: 25),
              MyTextField(controller: emailController, hintText: 'Email', obscureText: false),
              SizedBox(height: 10),
              MyTextField(controller: passwordController, hintText: 'Password', obscureText: true),
              SizedBox(height: 25),
              MyButton(onTap: signUserIn),
              SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                    Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ElevatedButton(onPressed: forgotPassword, child: Text('Forgot Password'))],
                ),
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not a member?', style: TextStyle(color: Colors.grey[700])),
                  SizedBox(width: 4),
                  TextButton(
                    onPressed: navigateToRegistration,
                    child: Text('Register now', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
