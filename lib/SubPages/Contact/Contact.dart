import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../FillPages/AppBar.dart';
import '../../FillPages/BackToPreviousPageButton.dart';
import '../../FillPages/SideMenu.dart';
import '../Israel Past & Present/Israel Past & Present.dart';
import '../Maps/Mapy.dart';
import '../Prayers And Reflections/Prayers & Reflections.dart';
import '../Spieces Of The Earth/Spieces Of The Earth.dart';
import '../Videos Galery/Videos Galery.dart';

class Contact extends StatelessWidget {
  late String Title;

  Contact(String sTitle) {
    Title = sTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX.buildAppBar(Title),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: Text(
                "Contact Us:",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10), // Margin between ListTile widgets
              child: ListTile(
                leading: Icon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.green,
                ),
                title: Text(
                  "WhatsApp",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  "Phone Number: +1234567890",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                onTap: () async {
                  final whatsappUrl = "https://wa.me/1234567890";
                  if (await canLaunch(whatsappUrl)) {
                    await launch(whatsappUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Could not launch WhatsApp."),
                    ));
                  }
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10), // Margin between ListTile widgets
              child: ListTile(
                leading: Icon(
                  FontAwesomeIcons.facebook,
                  color: Colors.blue,
                ),
                title: Text(
                  "Facebook",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  "URL: facebook.com/yourprofile",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                onTap: () async {
                  final facebookUrl = "https://www.facebook.com/yourprofile";
                  if (await canLaunch(facebookUrl)) {
                    await launch(facebookUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Could not launch Facebook."),
                    ));
                  }
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10), // Margin between ListTile widgets
              child: ListTile(
                leading: Icon(
                  Icons.email,
                  color: Colors.orangeAccent,
                ),
                title: Text(
                  "Send Email",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  final email = 'your@email.com';
                  final subject = 'Contact Us';
                  final emailUrl = 'mailto:$email?subject=$subject';

                  if (email.isNotEmpty) {
                    launch(emailUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Email not provided."),
                    ));
                  }
                },
              ),
            ),


            Container(
              margin: EdgeInsets.symmetric(vertical: 10), // Margin between ListTile widgets
              child: ListTile(
                leading: Icon(
                        Icons.phone,
                        color: Colors.red,
                      ),
                title: Text(
                  "Emergency Contact",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  "Phone Number: +1234567890",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                onTap: () async {
                  final whatsappUrl = "https://wa.me/1234567890";
                  if (await canLaunch(whatsappUrl)) {
                    await launch(whatsappUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Could not launch WhatsApp."),
                    ));
                  }
                },
              ),
            ),
            BackToHomePageButton(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
