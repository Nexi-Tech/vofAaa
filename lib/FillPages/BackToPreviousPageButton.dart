import 'package:flutter/material.dart';

class BackToHomePageButton extends StatelessWidget {
  final void Function() onPressed;

  BackToHomePageButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(
                  'Back To Previous Page',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orangeAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
