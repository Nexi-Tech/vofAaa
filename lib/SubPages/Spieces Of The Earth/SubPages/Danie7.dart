import 'package:flutter/material.dart';
import '../../../FillPages/AppBar.dart';
import '../../../FillPages/BackToHomePageButton.dart';
import '../../../FillPages/SideMenu.dart';

class Danie7 extends StatelessWidget{

  late String Title;

  Danie7(String sTitle){
    Title = sTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX.buildAppBar(Title),
      body: Container(
        child: CustomScrollView( //scrolowanie
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[


                  Padding( //Grafika Dania
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child:
                    Image.asset('assets/Splash_logo.png',
                      height: 150,
                      width: 400,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(147, 20, 147, 10),
                    child: Text("Ingridients",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                        fontSize: 24,),
                    ),
                  ),


                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Text("\n ◉ 2 Eggs"
                        "\n ◉ 3 Eggs"
                        "\n ◉ 4 Eggs"
                        "\n ◉ 5 Eggs"
                        "\n ◉ 6 Eggs"
                        "\n ◉ 7 Eggs"
                        "\n ◉ 8 Eggs"
                        "\n ◉ 9 Eggs"
                        "\n ◉ 10 Eggs",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                        fontSize: 18,),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(135, 10, 135, 10),
                    child: Text("Step by Step",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                        fontSize: 24,),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(35, 20, 35, 20),
                    child: Text("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXX"
                        "XXXXXXXXX XXXXXXXXXX XXXXXXXXXXX XXXXXXXXXXXXX XXXXXXXXXXXXX XXXX"
                        "X  XXXXXXXXXXX X",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                        fontSize: 18,),
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

      backgroundColor: Colors.black, //kolor tła po wcisnieciu guzika

      drawer: SideMenu().buildDrawer(context),
    );

  }


}