import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vof/pages/login_page.dart';
import 'package:vof/pages/home_page.dart'; // Dodaj import HomePage
import 'package:vof/pages/home_page_user.dart'; // Dodaj import HomePageUser

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Dodaj loader, jeśli potrzebny
          }

          // Jeśli użytkownik jest zalogowany
          if (snapshot.hasData) {
            return FutureBuilder<String>(
              future: getUserRole(snapshot.data!.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Dodaj loader, jeśli potrzebny
                }

                if (roleSnapshot.hasData) {
                  String userRole = roleSnapshot.data!;

                  if (userRole == 'admin') {
                    return HomePage();
                  } else if (userRole == 'user') {
                    return HomePageUser();
                  } else {
                    return Container(); // Obsłuż inne role, jeśli istnieją
                  }
                } else {
                  return Container(); // Obsłuż brak roli, jeśli to konieczne
                }
              },
            );
          }
          // Jeśli użytkownik nie jest zalogowany
          else {
            return LoginPage();
          }
        },
      ),
    );
  }

  Future<String> getUserRole(String userId) async {
    // Pobierz rolę użytkownika na podstawie userId
    // Przykład zwracania roli z Firestore:
    // (zakładając, że pole 'role' przechowuje rolę użytkownika)
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) => doc['role']);

    return 'user'; // Tutaj zastąp tym kodem, który pobiera rolę z Firestore
  }
}
