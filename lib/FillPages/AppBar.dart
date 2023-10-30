import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppBarX {
  static AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.black,
    );
  }
}