import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vof/SubPages/Culinary%20Videos/Culiany%20Videos.dart';

import 'package:vof/main_page.dart';
import '../SubPages/Contact/Contact.dart';
import '../SubPages/Israel Past & Present/Israel Past & Present.dart';
import '../SubPages/Maps/Mapy.dart';
import '../SubPages/Prayers And Reflections/Prayers & Reflections.dart';
import '../SubPages/Spieces Of The Earth/Spieces Of The Earth.dart';
import '../SubPages/Videos Galery/Videos Galery.dart';

class SideMenu {

  final String phoneNumber = '1234567890'; // Replace with an actual phone number
  final String email = 'example@example.com'; // Replace with an actual email address

  //URL JEST TEZ W MAIN OSOBNY DO EBOOK KAFELKA
  final String ebookUrl = 'https://nexitech.pl'; // Replace with the actual e-book URL

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black87,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.black87,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                  child: Text(
                    'VoF Tours Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.0,
                    ),
                  ),
                ),
                SizedBox(height: 10), // Adjust the spacing as needed
                Image.asset(
                  'assets/Splash_logo.png', // Replace with your logo image path
                  height: 60, // Adjust the height of the logo as needed
                ),
              ],
            ),
          ),
          // ListTile(
          //   title: Text('Main Page', style: TextStyle(
          //     color: Colors.white,
          //     fontSize: 24.0,
          //   ),),
          //   onTap: () {
          //     Navigator.popUntil(context, (route) => route.isFirst);
          //   },
          // ),
          ListTile(
            title: Text('Maps', style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapSample()),
              );
            },
          ),
          ListTile(
            title: Text('Israel Past & Present', style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        IsraelPastPresent('Israel Past & Present')),
              );
            },
          ),
          ListTile(
            title: Text('Species Of The Earth', style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SpiecesOfTheEarth('Species Of The Earth')),
              );
            },
          ),
          ListTile(
            title: Text('Prayers & Reflections', style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PrayersReflections('Prayers & Reflections')),
              );
            },
          ),
          ListTile(
            title: Text('Videos', style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideosGalery('Videos')),
              );
            },
          ),
          ListTile(
            title: Text('Culinary Videos', style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CulinaryVideos('Culinary Videos')),
              );
            },
          ),
          ListTile(
            title: Text('Contact', style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Contact('Contact')),
              );
            },
          ),
          ListTile(
            title: Text(
              'E-book',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
              ),
            ),
            onTap: () async {
              Navigator.pop(context); // Close the drawer
              await launch(ebookUrl); // Launch the e-book URL
            },
          ),
          ListTile(
            title: Text('User Panel', style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyApp2()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.facebook, // Facebook icon
              color: Colors.blue, // Customize the color as needed
              size: 24, // Customize the size as needed
            ),
            title: Text('Facebook', style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              launchFacebook(); // Launch Facebook when tapped
            },
          ),

          ListTile(
            leading: Icon(
              FontAwesomeIcons.whatsapp, // WhatsApp icon
              color: Colors.green, // Customize the color as needed
              size: 24, // Customize the size as needed
            ),
            title: Text('WhatsApp', style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              launchWhatsApp(); // Launch WhatsApp when tapped
            },
          ),
        ],
      ),
    );
  }

  void launchWhatsApp() async {
    final url = 'https://wa.me/$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  void launchEmail() async {
    final url = 'mailto:$email';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch email';
    }
  }

  void launchFacebook() async {
    final facebookUrl = 'https://www.facebook.com/your-facebook-profile-url'; // Replace with your Facebook URL
    if (await canLaunch(facebookUrl)) {
      await launch(facebookUrl);
    } else {
      throw 'Could not launch Facebook';
    }
  }
}