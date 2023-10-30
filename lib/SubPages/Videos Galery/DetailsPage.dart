import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../FillPages/AppBar.dart';

class DetailsPage extends StatefulWidget {
  final String videoUrl;
  final String smallImage;
  final String title;
  final String details;
  final int index;

  DetailsPage({
    required this.videoUrl,
    required this.smallImage,
    required this.title,
    required this.details,
    required this.index,
  });

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  double sliderValue = 0.5; // Initialize with the middle value

  String extractVideoId(String videoUrl) {
    final regExp = RegExp(r'v=([a-zA-Z0-9-]+)');
    final match = regExp.firstMatch(videoUrl);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    return 'INVALID_VIDEO_ID';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX.buildAppBar(widget.title),
      body: Container(
      child: CustomScrollView(
      slivers: [
      SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        children: <Widget>[
      Expanded(
      child: Hero(
        tag: 'logo${widget.index}',
        child: YoutubePlayer(
          controller: YoutubePlayerController(
            initialVideoId: extractVideoId(widget.videoUrl),
            flags: YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          ),
          showVideoProgressIndicator: true,
        ),
      ),
    ),
    Container(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
    Padding(
    padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
    Text(
    widget.title,
    style: TextStyle(
    color: Colors.black,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(
    height: 10,
    ),
    Text(
    widget.details,
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
    Row(
    children: <Widget>[
    Padding(
      padding: const EdgeInsets.fromLTRB(95, 15, 50, 0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
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
    )
    ],
    ),
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

