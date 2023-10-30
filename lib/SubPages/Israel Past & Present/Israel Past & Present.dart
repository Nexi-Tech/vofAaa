import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CustomExpansionTileView extends StatelessWidget {
  final String image;
  final String title;
  final Function(String) navigateToDestination;

  CustomExpansionTileView({
    required this.image,
    required this.title,
    required this.navigateToDestination,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateToDestination(title);
      },
      child: Container(
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IsraelPastPresent('Israel Past & Present'),
    );
  }
}

class IsraelPastPresent extends StatefulWidget {
  final String title;

  IsraelPastPresent(this.title);

  @override
  _IsraelPastPresentState createState() => _IsraelPastPresentState();
}

class _IsraelPastPresentState extends State<IsraelPastPresent> {
  late String Title;
  late CollectionReference prayersCollection;

  @override
  void initState() {
    super.initState();
    Title = widget.title;
    prayersCollection = FirebaseFirestore.instance.collection('IsraelPastPresent');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          Title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: prayersCollection.orderBy('createdAt').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 3.0,
              childAspectRatio: 0.75,
            ),
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = documents[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

              return CustomExpansionTileView(
                image: data["imageUrl"],
                title: data["title"],
                navigateToDestination: (title) {
                  navigateToDetailsPage(index, document.id, data["imageUrl"], title, data["afterImageUrl"]);
                },
              );
            },
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }

  void navigateToDetailsPage(int index, String documentId, String imagePath, String title, String afterImagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          index: index,
          documentId: documentId,
          imagePath: imagePath,
          afterImagePath: afterImagePath,
          title: title,
        ),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final int index;
  final String documentId;
  final String imagePath;
  final String afterImagePath;
  final String title;

  DetailsPage({
    required this.index,
    required this.documentId,
    required this.imagePath,
    required this.afterImagePath,
    required this.title,
  });

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  double sliderValue = 0.5;

  late String editedTitle = '';
  late String editedDetails = '';

  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    editedTitle = widget.title;
    titleController = TextEditingController(text: editedTitle);
    _fetchImageDetailsOffline();
  }

  Future<void> _fetchImageDetailsOffline() async {
    try {
      String? cachedDetails = await readDetailsFromFile(widget.documentId);
      if (cachedDetails != null) {
        setState(() {
          editedTitle = widget.title;
          editedDetails = cachedDetails;
          titleController.text = editedTitle;
          detailsController.text = editedDetails;
        });
      } else {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('IsraelPastPresentDetails')
            .doc(widget.documentId)
            .get();
        if (doc.exists) {
          setState(() {
            editedTitle = widget.title;
            editedDetails = doc['details'] ?? '';
            titleController.text = editedTitle;
            detailsController.text = editedDetails;
            writeDetailsToFile(widget.documentId, editedDetails);
          });
        }
      }
    } catch (e) {
      print('Error fetching image details: $e');
    }
  }

  Future<void> writeDetailsToFile(String documentId, String details) async {
    try {
      final File file = await _localFile(documentId);
      await file.writeAsString(details);
    } catch (e) {
      print('Error writing details to file: $e');
    }
  }

  Future<String?> readDetailsFromFile(String documentId) async {
    try {
      final File file = await _localFile(documentId);
      return await file.readAsString();
    } catch (e) {
      print('Error reading details from file: $e');
      return null;
    }
  }

  Future<File> _localFile(String documentId) async {
    final String dir = (await getApplicationDocumentsDirectory()).path;
    return File('$dir/$documentId.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          editedTitle,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  double newValue = sliderValue +
                      details.delta.dx / 350;
                  sliderValue = newValue.clamp(0.0, 1.0);
                });
              },
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: widget.imagePath,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  Positioned.fill(
                    child: FractionallySizedBox(
                      widthFactor: sliderValue,
                      alignment: Alignment.centerLeft,
                      child: CachedNetworkImage(
                        imageUrl: widget.afterImagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 5, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 20), // Adjust bottom padding here
                    child: Slider(
                      value: sliderValue,
                      onChanged: (newValue) {
                        setState(() {
                          sliderValue = newValue;
                        });
                      },
                      activeColor: Colors.blue, // Change slider color to blue
                    ),
                  ),
                  Text(
                    editedDetails,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
      backgroundColor: Colors.black,

    );
  }
}
