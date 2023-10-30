import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      home: CulinaryVideosEdit('Culinary Videos_edit'),
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

class CulinaryVideosEdit extends StatefulWidget {
  final List<VideoModel> _videos = [];
  late String title;

  CulinaryVideosEdit(String sTitle) {
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
  _CulinaryVideosEditState createState() => _CulinaryVideosEditState();
}

class _CulinaryVideosEditState extends State<CulinaryVideosEdit> {
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

  Future<void> deleteTile(int index) async {
    setState(() {
      widget._videos.removeAt(index);
      saveVideosToFirestore();
    });
  }

  Future<void> saveVideosToFirestore() async {
    try {
      final List<Map<String, dynamic>> videosDataList = widget._videos.map((video) => video.toJson()).toList();
      await FirebaseFirestore.instance.collection('CulinaryvideoDetails').doc('CulinaryvideosData').set({
        'videos': videosDataList,
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('CulinaryvideoDetails').doc('count').set({
        'count': widget._videos.length,
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upload YouTube Video'),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(labelText: 'YouTube Video URL'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String youtubeVideoUrl = urlController.text.trim();

                // Extract the video ID from the long URL
                String? videoId = extractVideoId(youtubeVideoUrl);

                if (videoId != null) {
                  setState(() {
                    VideoModel newVideo = VideoModel(
                      documentId: 'uniqueDocumentIdForVideo${widget._videos.length + 1}',
                      videoUrl: videoId, // Use the extracted video ID
                      title: '',
                      details: '',
                    );
                    widget._videos.add(newVideo);

                    // Call the method to save the videos to Firestore
                    saveVideosToFirestore();
                  });

                  // Update the video details in the database
                  widget.saveVideoDetails(
                    'uniqueDocumentIdForVideo${widget._videos.length}',
                    videoId, // Use the extracted video ID
                    '',
                    '',
                  );

                  // Update the video count in the Firebase database
                  await FirebaseFirestore.instance.collection('CulinaryvideoDetails').doc('count').set({
                    'count': widget._videos.length,
                  }, SetOptions(merge: true));

                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Invalid YouTube Link'),
                        content: Text('Please provide a valid YouTube video link.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  String? extractVideoId(String url) {
    RegExp regExp = RegExp(
      r"(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})",
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
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
                              deleteTile: () {
                                deleteTile(index);
                                Navigator.pop(context);
                              },
                              editVideoUrl: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Edit Video URL'),
                                      content: TextField(
                                        decoration: InputDecoration(labelText: 'YouTube Video URL'),
                                        controller: TextEditingController(text: widget._videos[index].videoUrl),
                                        onChanged: (value) {
                                          widget._videos[index].videoUrl = value;
                                        },
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Save'),
                                          onPressed: () {
                                            widget.saveVideoDetails(
                                              widget._videos[index].documentId,
                                              widget._videos[index].videoUrl,
                                              widget._videos[index].title,
                                              widget._videos[index].details,
                                            );
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: _uploadYouTubeVideoUrl,
                  child: Text(
                    'Upload YouTube Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
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
  VoidCallback deleteTile;
  VoidCallback editVideoUrl;

  DetailsPage({
    required this.video,
    required this.saveVideoDetails,
    required this.deleteTile,
    required this.editVideoUrl,
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
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: widget.editVideoUrl,
          ),
        ],
      ),
      body: Container(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Hero(
                      tag: 'logo${widget.video.documentId}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey[300],
                        ),
                        child: Center(
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
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    widget.video.title = value;
                                  });
                                },
                                controller: titleController,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Details',
                                ),
                                maxLines: null,
                                onChanged: (value) {
                                  setState(() {
                                    widget.video.details = value;
                                  });
                                },
                                controller: detailsController,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: ElevatedButton(
                                  onPressed: () {
                                    widget.saveVideoDetails(widget.video);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Save',
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
                            ElevatedButton(
                              onPressed: () {
                                widget.deleteTile();
                              },
                              child: Text(
                                'Delete Tile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
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
