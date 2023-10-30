import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:vof/FillPages/AppBar.dart';

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
        margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: CachedNetworkImage(
                  imageUrl: image,
                  height: 100,
                  fit: BoxFit.fitWidth,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10.0),

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
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true, // Włącz tryb offline
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Protestant('Protestant'),
    );
  }
}

class Protestant extends StatefulWidget {
  final String title;

  Protestant(this.title);

  @override
  _ProtestantState createState() => _ProtestantState();
}

class _ProtestantState extends State<Protestant> {
  late String Title;
  late CollectionReference prayersCollection;

  @override
  void initState() {
    super.initState();
    Title = widget.title;
    prayersCollection = FirebaseFirestore.instance.collection('Protestant_prayers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX.buildAppBar(Title),
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

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = documents[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

              return CustomExpansionTileView(
                image: data["imageUrl"],
                title: data["title"],
                navigateToDestination: (title) {
                  navigateToDetailsPage(index, document.id, data["imageUrl"], title);
                },
              );
            },
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }

  void navigateToDetailsPage(int index, String documentId, String imagePath, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          index: index,
          documentId: documentId,
          imagePath: imagePath,
          afterImagePath: '',
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
  _DetailsPageState createState() => _DetailsPageState(
    index: index,
    documentId: documentId,
    imagePath: imagePath,
    afterImagePath: afterImagePath,
    title: title,
  );
}

class _DetailsPageState extends State<DetailsPage> {
  final int index;
  final String documentId;
  final String imagePath;
  final String afterImagePath;
  final String title;

  _DetailsPageState({
    required this.index,
    required this.documentId,
    required this.imagePath,
    required this.afterImagePath,
    required this.title,
  });

  double sliderValue = 0.5; // Dodane sliderValue

  late String editedTitle = '';
  late String editedDetails = '';

  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: title);
    _fetchImageDetailsOffline();
  }

  Future<void> _fetchImageDetailsOffline() async {
    try {
      print('Fetching image details...');
      String? cachedDetails = await readDetailsFromFile(documentId);
      if (cachedDetails != null) {
        print('Details found in local file.');
        setState(() {
          editedTitle = title;
          editedDetails = cachedDetails;
          titleController.text = editedTitle;
          detailsController.text = editedDetails;
        });
      } else {
        print('Details not found in local file.');
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection(
            'ProtestantDetails').doc(documentId).get();
        if (doc.exists) {
          setState(() {
            editedTitle = title;
            editedDetails = doc['details'] ?? '';
            titleController.text = editedTitle;
            detailsController.text = editedDetails;
            writeDetailsToFile(documentId, editedDetails); // Zapisz do pliku
            print('Details fetched from Firestore and saved in local file.');
          });
        } else {
          print('Document not found in Firestore.');
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
          title,
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
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        double newValue = sliderValue + details.delta.dx / 350;
                        sliderValue = newValue.clamp(0.0, 1.0);
                      });
                    },
                    child: CachedNetworkImage(
                      imageUrl: sliderValue >= 0.5 ? imagePath : afterImagePath,
                      height: 350,
                      width: 400,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
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
                        SizedBox(
                          height: 10,
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
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
