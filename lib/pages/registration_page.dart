import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vof/components/my_button.dart';
import 'package:vof/components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:vof/pages/home_page_user.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController organizationIdController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  bool validatePassword(String password) {
    return RegExp(r'^(?=.*?[!@#\$&*~]).{8,}$').hasMatch(password);
  }

  Future<List<String>> getEmailCredentials() async {
    String username = await FirebaseFirestore.instance.collection('admins').doc('admin_document').get().then((doc) => doc['username']);
    String password = await FirebaseFirestore.instance.collection('admins').doc('admin_document').get().then((doc) => doc['password']);
    return [username, password];
  }

  void sendEmailToSupport(String username, String password) async {
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Your Name')
      ..recipients.add('support@nexitech.pl')
      ..subject = 'Nowy użytkownik czeka na akceptację'
      ..text = 'Nowy użytkownik czeka na akceptację.';
    try {
      final sendReport = await send(message, smtpServer);
    } on MailerException catch (e) {}
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<bool> validateOrganizationId(String organizationId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('organizations').doc(organizationId).get();
    return doc.exists;
  }

  void registerUser() async {
    final users = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: emailController.text).get();
    if(users.docs.isNotEmpty) {
      showErrorDialog("Email already taken");
      return;
    }
    if(!validatePassword(passwordController.text)) {
      showErrorDialog("Password must be at least 8 symbols including one special sign.");
      return;
    }
    if(organizationIdController.text.length != 6) {
      showErrorDialog("Organization ID must be a 6-digit code.");
      return;
    }

    bool validOrganizationId = await validateOrganizationId(organizationIdController.text);
    if(!validOrganizationId) {
      showErrorDialog("Invalid Organization ID.");
      return;
    }

    try {
      UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      await userCredential?.user?.updateProfile(displayName: "${nameController.text} ${lastnameController.text}");
      Map<String, dynamic> userData = {
        'organizationId': organizationIdController.text,
        'name': nameController.text,
        'lastname': lastnameController.text,
        'email': emailController.text,
        'phoneNumber': phoneNumberController.text,
        'role': 'user',
      };
      await FirebaseFirestore.instance.collection('users').doc(userCredential?.user?.uid).set(userData);
      List<String> credentials = await getEmailCredentials();
      sendEmailToSupport(credentials[0], credentials[1]);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account created correctly.')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePageUser()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showErrorDialog('The password is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showErrorDialog('The email address is already in use.');
      } else {
        showErrorDialog('Error occurred: ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyTextField(controller: organizationIdController, hintText: 'Organization ID (6 digits)', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: nameController, hintText: 'Name', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: lastnameController, hintText: 'Lastname', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: emailController, hintText: 'Email', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: passwordController, hintText: 'Password (8 symbols including one special sign)', obscureText: true),
                const SizedBox(height: 10),
                MyTextField(controller: phoneNumberController, hintText: 'Phone Number (optional)', obscureText: false),
                const SizedBox(height: 20),
                MyButton(onTap: registerUser),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
