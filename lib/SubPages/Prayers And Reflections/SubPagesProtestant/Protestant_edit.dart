import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:before_after/before_after.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';

import 'package:vof/FillPages/AppBar.dart';

class CustomExpansionTile extends StatelessWidget {
  final String image;
  final String title;
  final Function(String) navigateToDestination;
  final Function() onDelete;

  CustomExpansionTile({
    required this.image,
    required this.title,
    required this.navigateToDestination,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateToDestination(title);
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirmation"),
              content: Text("Are you sure you want to delete this prayer?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDelete();
                  },
                  child: Text("Delete"),
                ),
              ],
            );
          },
        );
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
                child: Image.network(
                  image,
                  height: 100,
                  fit: BoxFit.fitWidth,
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProtestantEdit('Protestant_edit'),
    );
  }
}

class ProtestantEdit extends StatefulWidget {
  final String title;

  ProtestantEdit(this.title);

  @override
  _ProtestantEditState createState() => _ProtestantEditState();
}

class _ProtestantEditState extends State<ProtestantEdit> {
  late String Title;
  late CollectionReference ProtestantprayersCollection;
  final ImagePicker _picker = ImagePicker();
  List<DocumentReference> customTiles = [];
  List<String> imagePaths = []; // Dodana lista ścieżek obrazów
  TextEditingController newPrayerTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Title = widget.title;
    ProtestantprayersCollection = FirebaseFirestore.instance.collection('Protestant_prayers');
    getPrayers();
  }

  Future<void> addPrayer(String title, PickedFile imageFile) async {
    try {
      String imageUrl = await uploadImage(title, imageFile);
      DocumentReference docRef = await ProtestantprayersCollection.add({
        'title': title,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        customTiles.insert(0, docRef);
        imagePaths.insert(0, imageUrl); // Dodanie ścieżki obrazu do listy
      });

      print("Prayer Added");
    } catch (e) {
      print("Failed to add prayer: $e");
    }
  }

  Future<String> uploadImage(String fileName, PickedFile imageFile) async {
    try {
      File file = File(imageFile.path);
      Reference ref = FirebaseStorage.instance.ref().child('pimages/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  Future<void> getPrayers() async {
    var querySnapshot = await ProtestantprayersCollection.orderBy('createdAt').get();
    setState(() {
      customTiles = querySnapshot.docs.map((doc) => doc.reference).toList();
      imagePaths = querySnapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
      // Uzupełnienie listy ścieżek obrazów
    });
  }

  void deletePrayer(String id) async {
    try {
      await ProtestantprayersCollection.doc(id).delete();
      getPrayers();
      print("Prayer Deleted");
    } catch (e) {
      print("Failed to delete prayer: $e");
    }
  }

  void navigateToDetailsPage(int index, String documentId, String imagePath, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          index: index,
          documentId: documentId,
          imagePath: imagePath,
          afterImagePath: '', // Dodałem pusty string dla afterImagePath
          title: title,
          replaceImage: _replaceImage,
          deleteTile: () => deletePrayer(documentId), // Przekazanie funkcji usuwającej
        ),
      ),
    );
  }

  Future<void> _replaceImage(String imagePathType, int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);

      try {
        String fileName = image.path.split('/').last;
        await firebase_storage.FirebaseStorage.instance.ref('pimages/$fileName').putFile(image);
        String downloadURL = await firebase_storage.FirebaseStorage.instance.ref('pimages/$fileName').getDownloadURL();

        setState(() {
          if (imagePathType == 'imagePath') {
            customTiles[index].update({'imageUrl': downloadURL});
            imagePaths[index] = downloadURL; // Aktualizacja ścieżki obrazu w liście
          } else if (imagePathType == 'afterImagePath') {
            customTiles[index].update({'afterImageUrl': downloadURL});
          }
        });

        // Dodaj to wywołanie, które zapisze zmiany do Firestore
        _saveChangesToFirestore();
      } catch (e) {
        print('Error replacing image: $e');
      }
    }
  }

  Future<void> _saveChangesToFirestore() async {
    try {
      // Możesz dodać dodatkową logikę, jeśli to konieczne
    } catch (e) {
      print('Error saving changes to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX.buildAppBar(Title),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: () async {
              TextEditingController prayerTitleController = TextEditingController();

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Add New Prayer"),
                  content: TextField(
                    controller: prayerTitleController,
                    decoration: InputDecoration(
                      labelText: 'New Prayer Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        PickedFile? imageFile = await _picker.getImage(source: ImageSource.gallery);
                        if (imageFile != null) {
                          String newPrayerTitle = prayerTitleController.text.trim();
                          if (newPrayerTitle.isNotEmpty) {
                            addPrayer(newPrayerTitle, imageFile);
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: Text("Add"),
                    ),
                  ],
                ),
              );
            },
            child: Text('Add New Prayer'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: customTiles.length,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder<DocumentSnapshot>(
                  future: customTiles[index].get(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Something went wrong");
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                      return CustomExpansionTile(
                        image: imagePaths[index], // Użyj ścieżki obrazu z listy
                        title: data["title"],
                        navigateToDestination: (title) {
                          navigateToDetailsPage(index, customTiles[index].id, imagePaths[index], title); // Przekazanie indeksu
                        },
                        onDelete: () {
                          deletePrayer(customTiles[index].id);
                        },
                      );
                    }

                    return Text("Loading");
                  },
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}

class DetailsPage extends StatefulWidget {
  final int index;
  final String documentId;
  final String imagePath;
  final String afterImagePath;
  final String title;
  final Function(String, int) replaceImage;
  final Function() deleteTile;

  DetailsPage({
    required this.index,
    required this.documentId,
    required this.imagePath,
    required this.afterImagePath,
    required this.title,
    required this.replaceImage,
    required this.deleteTile,
  });

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  double sliderValue = 0.5;
  late String editedTitle = ''; // Dodana inicjalizacja
  late String editedDetails = ''; // Dodana inicjalizacja
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.title); // Inicjalizacja wartości z widget.title

    _fetchImageDetails();
  }

  Future<void> _uploadImage(String imagePathType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);

      try {
        String fileName = image.path.split('/').last;
        await firebase_storage.FirebaseStorage.instance.ref('pimages/$fileName').putFile(image);
        String downloadURL = await firebase_storage.FirebaseStorage.instance.ref('pimages/$fileName').getDownloadURL();

        setState(() {
          if (imagePathType == 'imagePath') {
            widget.replaceImage(downloadURL, widget.index);
          } else if (imagePathType == 'afterImagePath') {
            widget.replaceImage(downloadURL, widget.index);
          }
        });

        _saveChangesToFirestore();
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _fetchImageDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('ProtestantDetails').doc(widget.documentId).get();
      if (doc.exists) {
        setState(() {
          editedTitle = doc['title'] ?? ''; // Dodana obsługa null
          editedDetails = doc['details'] ?? ''; // Dodana obsługa null
          titleController.text = editedTitle;
          detailsController.text = editedDetails;
        });
      }
    } catch (e) {
      print('Error fetching image details: $e');
    }
  }


  Future<void> _saveChangesToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('ProtestantDetails').doc(widget.documentId).set({
        'title': editedTitle,
        'details': editedDetails,
        'imagePath': widget.imagePath,
        'afterImagePath': widget.afterImagePath,
      });
    } catch (e) {
      print('Error saving changes to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () => widget.replaceImage('imagePath', widget.index),
                        child: Text('Replace Image 1'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Change Title"),
                                content: TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    labelText: 'New Title',
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      String newTitle = titleController.text;

                                      try {
                                        // Pobranie referencji do dokumentu w kolekcji 'prayers'
                                        DocumentReference prayerDocRef = FirebaseFirestore.instance.collection('Protestant_prayers').doc(widget.documentId);

                                        // Zaktualizowanie tytułu w dokumencie
                                        await prayerDocRef.update({
                                          'title': newTitle,
                                        });

                                        // Zaktualizuj lokalny tytuł
                                        setState(() {
                                          editedTitle = newTitle;
                                        });
                                      } catch (e) {
                                        print('Error updating title in Firebase: $e');
                                      }

                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Save"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Change Title'),
                      ),

                    ],
                  ),
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          double newValue = sliderValue + details.delta.dx / 350;
                          sliderValue = newValue.clamp(0.0, 1.0);
                        });
                      },
                      child: Image.network(
                        sliderValue >= 0.5 ? widget.imagePath : widget.afterImagePath,
                        height: 350,
                        width: 400,
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
                                    editedDetails = value;
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
                                    _saveChangesToFirestore();
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
