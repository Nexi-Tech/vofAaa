import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vof/SubPages/Spieces%20Of%20The%20Earth/SubPagesHerbsSpices/HerbsSpices.dart';
import '../../FillPages/AppBar.dart';
import '../../FillPages/BackToPreviousPageButton.dart';
import 'CustomExpansionTile.dart';
import 'SubPagesRecipies/Recipies.dart';

class SpiecesOfTheEarth extends StatelessWidget {
  late String Title;

  SpiecesOfTheEarth(String sTitle) {
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CustomExpansionTile(
                            image: "Splash_logo",
                            title: "Recipies",
                            navigateToDestination: (title) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Recipies(title), // tutaj trzeba zmienic strone do ktorej kieruje
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CustomExpansionTile(
                            image: "Splash_logo",
                            title: "Herbs & Spices",
                            navigateToDestination: (title) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HerbsSpices(title), // tutaj trzeba zmienic strone do ktorej kieruje
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
