import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vof/SubPages/Prayers%20And%20Reflections/SubPagesCatholic/Catholic.dart';
import 'package:vof/SubPages/Prayers%20And%20Reflections/SubPagesProtestant/Protestant.dart';

import '../../FillPages/AppBar.dart';
import '../../FillPages/BackToPreviousPageButton.dart';
import 'package:vof/SubPages/Spieces%20Of%20The%20Earth/CustomExpansionTile.dart';



class PrayersReflections extends StatelessWidget {
  late String Title;

  PrayersReflections(String sTitle) {
    Title = sTitle;
  }

  Widget build(BuildContext context) {
    // Strona glowna + naglowek
    return Scaffold(
      appBar: AppBarX.buildAppBar(Title),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        // odstep kafelkow od krawedzi apki
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  //Kafelek 1
                  Expanded(
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomExpansionTile(
                            image: "Splash_logo",
                            title: "Catholic",
                            navigateToDestination: (title) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Catholic(title), // tutaj trzeba zmienic strone do ktorej kieruje
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Kafelek 2
                  Expanded(
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomExpansionTile(
                            image: "Splash_logo",
                            title: "Protestant",
                            navigateToDestination: (title) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Protestant(title), // tutaj trzeba zmienic strone do ktorej kieruje
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
          ],
        ),
      ),
    );
  }
}
