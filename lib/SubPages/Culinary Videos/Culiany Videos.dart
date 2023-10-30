import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:before_after/before_after.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:vof/FillPages/AppBar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) {
    print("Firebase initialized");
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CulinaryVideos('Culinary Videos'),
    );
  }
}

class VideoModel {
  String documentId;
  String videoUrl;
  String title;
  String details;

  VideoModel({
    required this.documentId,
    required this.videoUrl,
    required this.title,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'videoUrl': videoUrl,
      'title': title,
      'details': details,
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      documentId: json['documentId'],
      videoUrl: json['videoUrl'],
      title: json['title'],
      details: json['details'],
    );
  }
}

class CulinaryVideos extends StatefulWidget {
  final List<VideoModel> _videos = [];
  late String title;

  CulinaryVideos(String sTitle) {
    title = sTitle;
  }

  void saveVideoDetails(
      String documentId,
      String videoUrl,
      String title,
      String details,
      ) async {
    try {
      await FirebaseFirestore.instance.collection('CulinaryvideoDetails').doc(documentId).set({
        'videoUrl': videoUrl,
        'title': title,
        'details': details,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating video details: $e');
    }
  }

  @override
  _CulinaryVideosState createState() => _CulinaryVideosState();
}

class _CulinaryVideosState extends State<CulinaryVideos> {
  Future<void> loadVideosFromFirestore() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('CulinaryvideoDetails').doc('CulinaryvideosData').get();
      if (doc.exists) {
        List<Map<String, dynamic>> videosDataList = List<Map<String, dynamic>>.from(doc['videos']);
        List<VideoModel> videos = videosDataList.map((json) => VideoModel.fromJson(json)).toList();
        setState(() {
          widget._videos.clear();
          widget._videos.addAll(videos);
        });

        doc = await FirebaseFirestore.instance.collection('CulinaryvideoDetails').doc('count').get();
        if (doc.exists) {
          int count = doc['count'];
          setState(() {
            widget._videos.length = count;
          });
        }
      }
    } catch (e) {
      print('Error fetching video data from Firestore: $e');
    }
  }



  Future<void> saveVideosToFirestore() async {
    try {
      final List<Map<String, dynamic>> videosDataList = widget._videos.map((video) => video.toJson()).toList();
      await FirebaseFirestore.instance.collection('CulinaryvideoDetails').doc('CulinaryvideosData').set({
        'videos': videosDataList,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving videos to Firestore: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadVideosFromFirestore();
  }

  Future<void> _uploadYouTubeVideoUrl() async {
    final TextEditingController urlController = TextEditingController();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX.buildAppBar(widget.title),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            Text(
              'Gallery',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return RawMaterialButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(
                              video: widget._videos[index],
                              saveVideoDetails: (video) {
                                setState(() {
                                  widget._videos[index] = video;
                                });
                                saveVideosToFirestore();
                              },
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'logo$index',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[300],
                          ),
                          child: Center(
                            child: YoutubePlayer(
                              controller: YoutubePlayerController(
                                initialVideoId: widget._videos[index].videoUrl,
                                flags: YoutubePlayerFlags(
                                  autoPlay: false,
                                  mute: false,
                                ),
                              ),
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: Colors.blueAccent,
                              progressColors: ProgressBarColors(
                                playedColor: Colors.amber,
                                handleColor: Colors.amberAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: widget._videos.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final VideoModel video;
  Function(VideoModel) saveVideoDetails;


  DetailsPage({
    required this.video,
    required this.saveVideoDetails,

  });

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.video.title;
    detailsController.text = widget.video.details;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          widget.video.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: 'logo${widget.video.documentId}',
                  child: Container(
                    height: 350,
                    child: YoutubePlayer(
                      controller: YoutubePlayerController(
                        initialVideoId: widget.video.videoUrl,
                        flags: YoutubePlayerFlags(
                          autoPlay: false,
                          mute: false,
                        ),
                      ),
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.blueAccent,
                      progressColors: ProgressBarColors(
                        playedColor: Colors.amber,
                        handleColor: Colors.amberAccent,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              widget.video.details,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
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
        ],
      ),

      backgroundColor: Colors.black,
    );
  }
}