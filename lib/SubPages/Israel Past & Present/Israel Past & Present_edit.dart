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
      home: IsraelPastPresentEdit('IsraelPastPresent_edit'),
    );
  }
}

class IsraelPastPresentEdit extends StatefulWidget {
  final String title;

  IsraelPastPresentEdit(this.title);

  @override
  _IsraelPastPresentEditState createState() => _IsraelPastPresentEditState();
}

class _IsraelPastPresentEditState extends State<IsraelPastPresentEdit> {
  late String Title;
  late CollectionReference IsraelPPprayersCollection;
  final ImagePicker _picker = ImagePicker();
  List<DocumentReference> customTiles = [];
  List<String> imagePaths = [];
  String afterImagePath = '';
  TextEditingController newPrayerTitleController = TextEditingController();

  Future<void> _saveImageDetails(String documentId, String imagePath, String title, String details, String afterImagePath) async {
    try {
      await FirebaseFirestore.instance.collection('IsraelPastPresentDetails').doc(documentId).set({
        'title': title,
        'details': details,
        'imagePath': imagePath,
        'afterImagePath': afterImagePath,
      });
    } catch (e) {
      print('Error saving image details: $e');
    }
  }

  void _changeGalleryImage(String newImagePath) {
    setState(() {
      afterImagePath = newImagePath;
    });
  }

  @override
  void initState() {
    super.initState();
    Title = widget.title;
    IsraelPPprayersCollection = FirebaseFirestore.instance.collection('IsraelPastPresent');
    getPrayers();
  }

  Future<void> addPrayer(String title, PickedFile imageFile) async {
    try {
      String imageUrl = await uploadImage(title, imageFile);
      DocumentReference docRef = await IsraelPPprayersCollection.add({
        'title': title,
        'imageUrl': imageUrl,
        'afterImageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        customTiles.insert(0, docRef);
        imagePaths.insert(0, imageUrl);
      });

      print("Prayer Added");
    } catch (e) {
      print("Failed to add prayer: $e");
    }
  }

  Future<String> uploadImage(String fileName, PickedFile imageFile) async {
    try {
      File file = File(imageFile.path);
      Reference ref = FirebaseStorage.instance.ref().child('isimages/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  Future<void> getPrayers() async {
    var querySnapshot = await IsraelPPprayersCollection.orderBy('createdAt').get();
    setState(() {
      customTiles = querySnapshot.docs.map((doc) => doc.reference).toList();
      imagePaths = querySnapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    });
  }

  void deletePrayer(String id) async {
    try {
      await IsraelPPprayersCollection.doc(id).delete();
      getPrayers();
      print("Prayer Deleted");
    } catch (e) {
      print("Failed to delete prayer: $e");
    }
  }

  void navigateToDetailsPage(int index, String documentId, String imagePath, String title, String afterImagePath, String details) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          documentId: documentId,
          imagePath: imagePath,
          afterImagePath: afterImagePath,
          title: title,
          details: details, // Dodana zmienna details
          index: index,
          saveImageDetails: _saveImageDetails,
          deleteTile: () => deletePrayer(documentId),
          changeGalleryImage: _changeGalleryImage,
          replaceImage: _replaceImage,
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
        await firebase_storage.FirebaseStorage.instance.ref('isimages/$fileName').putFile(image);
        String downloadURL = await firebase_storage.FirebaseStorage.instance.ref('isimages/$fileName').getDownloadURL();

        setState(() {
          if (imagePathType == 'imagePath') {
            customTiles[index].update({'imageUrl': downloadURL});
            imagePaths[index] = downloadURL;
          } else if (imagePathType == 'afterImagePath') {
            customTiles[index].update({'afterImageUrl': downloadURL});
            afterImagePath = downloadURL;
          }
        });

        _saveChangesToFirestore();
      } catch (e) {
        print('Error replacing image: $e');
      }
    }
  }

  Future<void> _saveChangesToFirestore() async {
    try {
      // Dodatkowa logika, jeśli jest potrzebna
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
                        image: imagePaths[index],
                        title: data["title"],
                        navigateToDestination: (title) {
                          navigateToDetailsPage(index, customTiles[index].id, imagePaths[index], title, data['afterImageUrl'], "Tutaj znajdą się szczegóły");
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
  String documentId;
  String imagePath;
  String afterImagePath;
  String title;
  String details;
  int index;
  Function(String, String, String, String, String) saveImageDetails;
  VoidCallback deleteTile;
  Function(String) changeGalleryImage;
  final Function(String, int) replaceImage;

  DetailsPage({
    required this.documentId,
    required this.imagePath,
    required this.afterImagePath,
    required this.title,
    required this.details,
    required this.index,
    required this.saveImageDetails,
    required this.deleteTile,
    required this.changeGalleryImage,
    required this.replaceImage,
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

    titleController = TextEditingController(text: widget.title);

    _fetchImageDetails();
  }

  Future<void> _uploadImage(String imagePathType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);

      try {
        String fileName = image.path.split('/').last;
        await firebase_storage.FirebaseStorage.instance.ref('isimages/$fileName').putFile(image);
        String downloadURL = await firebase_storage.FirebaseStorage.instance.ref('isimages/$fileName').getDownloadURL();

        setState(() {
          if (imagePathType == 'imagePath') {
            widget.imagePath = downloadURL;
            widget.changeGalleryImage(downloadURL);
          } else if (imagePathType == 'afterImagePath') {
            widget.afterImagePath = downloadURL;
          }
        });

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
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('IsraelPastPresentDetails').doc(widget.documentId).get();
      if (doc.exists) {
        setState(() {
          editedTitle = doc['title'];
          editedDetails = doc['details'];
          titleController.text = editedTitle;
          detailsController.text = editedDetails;
          widget.imagePath = doc['imagePath'];
          widget.afterImagePath = doc['afterImagePath'];
        });
      }
    } catch (e) {
      print('Error fetching image details: $e');
    }
  }

  Future<void> _saveChangesToFirestore() async {
    try {
      await widget.saveImageDetails(
        widget.documentId,
        widget.imagePath,
        editedTitle,
        editedDetails,
        widget.afterImagePath,
      );

      // Aktualizuj tytuł w kolekcji IsraelPastPresent
      await FirebaseFirestore.instance.collection('IsraelPastPresent').doc(widget.documentId).update({
        'title': editedTitle,
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
                        onPressed: () => _uploadImage('imagePath'),
                        child: Text('Upload Image 1'),
                      ),
                      ElevatedButton(
                        onPressed: () => _uploadImage('afterImagePath'),
                        child: Text('Upload Image 2'),
                      ),
                      ElevatedButton(
                        onPressed: () => widget.replaceImage('imagePath', widget.index),
                        child: Text('Replace Image'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(1.0), // Ustaw margines
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Hero(
                      tag: 'logo${widget.index}',
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            double newValue = sliderValue + details.delta.dx / 350;
                            sliderValue = newValue.clamp(0.0, 1.0);
                          });
                        },
                        child: BeforeAfter(
                          height: 350,
                          width: 400,
                          before: Image.network(widget.imagePath, fit: BoxFit.cover),
                          after: Image.network(widget.afterImagePath, fit: BoxFit.cover),
                          thumbColor: Colors.red,
                          value: sliderValue,
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
                                    editedTitle = value;
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

                                    widget.saveImageDetails(
                                      widget.documentId,
                                      widget.imagePath,
                                      editedTitle,
                                      editedDetails,
                                      widget.afterImagePath,
                                    );
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
