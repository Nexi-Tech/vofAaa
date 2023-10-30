import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vof/SubPages/Prayers%20And%20Reflections/Prayers%20&%20Reflections.dart';
import 'package:vof/SubPages/Spieces%20Of%20The%20Earth/Spieces%20Of%20The%20Earth.dart';
import 'package:vof/SubPages/Videos%20Galery/Videos%20Galery.dart';

import 'FillPages/AppBar.dart';
import 'FillPages/SideMenu.dart';
import 'SubPages/Contact/Contact.dart';
import 'SubPages/Culinary Videos/Culiany Videos.dart';
import 'SubPages/Israel Past & Present/Israel Past & Present.dart';
import 'SubPages/Maps/Mapy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp()
      .then((value) {
    print("Firebase initialized"); // Dodaj to
  });
  FirebaseStorage storage = FirebaseStorage.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Splash extends StatefulWidget {
  Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 208, 188, 172),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Splash_logo.png',
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandedButton extends StatelessWidget {
  final String image;
  final String mainTileTitle;
  final Function onPressed;

  ExpandedButton({
    required this.image,
    required this.mainTileTitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.all(0),
        child: Container(
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/$image.png',
                fit: BoxFit.fitHeight,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                mainTileTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(),
            ],
          ),
        ),
        onPressed: () {
          onPressed();
        },
      ),
    );
  }
}

class Home extends StatelessWidget {
  final String htmlUrl = 'https://nexitech.pl';

  _launchHTMLURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX.buildAppBar("VoF Tours"),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ExpandedButton(
                          image: "earthmap",
                          mainTileTitle: "Maps",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapSample(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ExpandedButton(
                          image: "Spices",
                          mainTileTitle: "Israel Past & Present",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IsraelPastPresent("Israel Past & Present"),
                              ),
                            );
                          },
                        ),
                        ExpandedButton(
                          image: "Spices",
                          mainTileTitle: "Spices Of The Earth",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SpiecesOfTheEarth("Spices Of The Earth"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ExpandedButton(
                          image: "prayersandreflections",
                          mainTileTitle: "Prayers & Reflections",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrayersReflections("Prayers & Reflections"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ExpandedButton(
                          image: "videos",
                          mainTileTitle: "Videos",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideosGalery("Videos"),
                              ),
                            );
                          },
                        ),
                        ExpandedButton(
                          image: "cookingvideos",
                          mainTileTitle: "Culinary Videos",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CulinaryVideos("Culinary Videos"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ExpandedButton(
                          image: "ebook",
                          mainTileTitle: "eBook",
                          onPressed: () {
                            _launchHTMLURL(htmlUrl);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ExpandedButton(
                          image: "contact",
                          mainTileTitle: "Contact",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Contact("Contact"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: SideMenu().buildDrawer(context),
    );
  }
}
