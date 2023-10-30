import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomExpansionTile extends StatelessWidget {
  final String image;
  final String title;
  final Function(String) navigateToDestination;

  CustomExpansionTile({
    required this.image,
    required this.title,
    required this.navigateToDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Builder(
        builder: (context) {
          return CupertinoButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              navigateToDestination(title); // Call the callback with the title
            },
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                boxShadow: [
                  BoxShadow(),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Image.asset(
                      'assets/$image.png',
                      height: 100,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Flexible(
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}