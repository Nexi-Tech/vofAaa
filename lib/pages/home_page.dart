import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vof/FillPages/AppBar.dart';
import 'package:vof/SubPages/Culinary%20Videos/Culinary%20Videos_edit.dart';
import 'package:vof/SubPages/Israel%20Past%20&%20Present/Israel%20Past%20&%20Present_edit.dart';
import 'package:vof/SubPages/Maps/Maps_edit.dart';
import 'package:vof/SubPages/Prayers%20And%20Reflections/SubPagesCatholic/Catholic_edit.dart';
import 'package:vof/SubPages/Prayers%20And%20Reflections/SubPagesProtestant/Protestant_edit.dart';
import 'package:vof/SubPages/Spieces%20Of%20The%20Earth/SubPagesHerbsSpices/HerbsSpices_edit.dart';
import 'package:vof/SubPages/Spieces%20Of%20The%20Earth/SubPagesRecipies/Recipies_edit.dart';
import 'package:vof/SubPages/Videos%20Galery/Videos%20Galery_edit.dart';
import 'package:vof/main.dart';
import 'package:vof/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  List<QueryDocumentSnapshot> userList = [];
  QueryDocumentSnapshot? selectedUser;
  QueryDocumentSnapshot? selectedUserMigrate;

  void loadUserList() async {
    QuerySnapshot usersSnapshot =
    await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      userList = usersSnapshot.docs;
    });
  }

  void onUserSelected(QueryDocumentSnapshot user) {
    setState(() {
      selectedUser = user;
      nameController.text = user['name'];
      lastnameController.text = user['lastname'];
      emailController.text = user['email'];
      phoneNumberController.text = user['phoneNumber'];
    });
  }

  void saveUserData() async {
    if (selectedUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedUser!.id)
            .update({
          'name': nameController.text,
          'lastname': lastnameController.text,
          'email': emailController.text,
          'phoneNumber': phoneNumberController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Changes saved successfully'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No user selected'),
        ),
      );
    }
  }

  void changePassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to ${user.email}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send password reset email: $e'),
        ),
      );
    }
  }

  DateTime? lastActivityTime;
  late Timer inactivityTimer;

  void startInactivityTimer() {
    const inactivityDuration = Duration(minutes: 60);
    lastActivityTime = DateTime.now();

    inactivityTimer = Timer(inactivityDuration, () {
      FirebaseAuth.instance.signOut();
    });
  }

  void onUserInteraction() {
    inactivityTimer.cancel();
    startInactivityTimer();
  }

  @override
  void initState() {
    super.initState();
    loadUserList();
    loadUserData();

    startInactivityTimer();

    loadUserData();
  }

  void loadUserData() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      nameController.text = userData['name'];
      lastnameController.text = userData['lastname'];
      emailController.text = userData['email'];
      phoneNumberController.text = userData['phoneNumber'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
              icon: Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              icon: Icon(Icons.logout),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'User data'),
              Tab(text: 'EditPage'),
              Tab(text: 'Migrate Notes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "LOGGED IN AS: " + user.email!,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  DropdownButtonFormField(
                    value: selectedUser,
                    items: userList.map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text('${user['name']} ${user['lastname']}'),
                      );
                    }).toList(),
                    onChanged: (QueryDocumentSnapshot? user) {
                      onUserSelected(user!);
                    },
                    decoration: InputDecoration(
                      labelText: 'Select User',
                    ),
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextFormField(
                    controller: lastnameController,
                    decoration: InputDecoration(labelText: 'Lastname'),
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextFormField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),
                  ElevatedButton(
                    onPressed: saveUserData,
                    child: Text('Save Changes'),
                  ),
                  ElevatedButton(
                    onPressed: changePassword,
                    child: Text('Change Password'),
                  ),
                ],
              ),
            ),
            ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                ListTile(
                  title: Text('Maps_edit'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapsEdit(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Israel Past & Present_edit'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            IsraelPastPresentEdit('Israel Past and Present_edit'),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Recipies_edit'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipiesEdit('Recipies_edit'),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Herbs & Spices_edit'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HerbsSpicesEdit('Herbs & Spices_edit'),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Catholic_edit'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CatholicEdit('Catholic_edit'),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Protestant_edit'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProtestantEdit('Protestant_edit'),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Videos Galery_edit'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideosGaleryEdit('Videos Galery_edit'),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Culinary Videos_edit'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CulinaryVideosEdit('Culinary Videos_edit'),
                      ),
                    );
                  },
                ),
              ],
            ),
            Center(
              child: Column(
                children: <Widget>[
                  DropdownButtonFormField(
                    value: selectedUserMigrate,
                    items: userList.map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text('${user['name']} ${user['lastname']}'),
                      );
                    }).toList(),
                    onChanged: (QueryDocumentSnapshot? user) {
                      setState(() {
                        selectedUserMigrate = user;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select User',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: navigateToNotes,
                    child: Text('Migrate Notes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotesScreen(
          user: user,
          userList: userList,
          selectedUser: selectedUserMigrate,
        ),
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  final User user;
  final List<QueryDocumentSnapshot> userList;
  final QueryDocumentSnapshot? selectedUser;

  NotesScreen({required this.user, required this.userList, this.selectedUser});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.pink,
    Colors.purple,
    Colors.orange,
  ];

  List<Note> notes = [];

  Future<void> loadUserNotes() async {
    if (widget.selectedUser != null) {
      QuerySnapshot notesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.selectedUser!.id)
          .collection('notes')
          .get();

      setState(() {
        notes = notesSnapshot.docs.map((noteDoc) {
          return Note(
            id: noteDoc.id,
            title: noteDoc['title'],
            content: noteDoc['content'],
            modifiedTime: noteDoc['modifiedTime'].toDate(),
          );
        }).toList();
      });
    }
  }

  Future<dynamic> confirmDialog(BuildContext context, Note note) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
                child: Text(
                  'Yes',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
                child: Text(
                  'No',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    ).then((result) async {
      if (result != null && result) {
        await deleteNoteFromFirestore(note.id);
        deleteNote(note);
      }
    });
  }

  void deleteNote(Note note) {
    setState(() {
      notes.remove(note);
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserNotes();
  }

  Future<void> addNoteToFirestore(Note note) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.selectedUser!.id)
        .collection('notes')
        .add({
      'title': note.title,
      'content': note.content,
      'modifiedTime': note.modifiedTime,
    });
  }

  Future<void> deleteNoteFromFirestore(String noteId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.selectedUser!.id)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  void addNote() async {
    Note newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Note',
      content: 'New Note Content',
      modifiedTime: DateTime.now(),
    );

    await addNoteToFirestore(newNote);

    setState(() {
      notes.add(newNote);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX.buildAppBar("Notes"),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            color: colors[index % colors.length],
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => EditScreen(note: note),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      int originalIndex = notes.indexWhere((n) => n.id == note.id);
                      notes[originalIndex] = Note(
                        id: note.id,
                        title: result[0],
                        content: result[1],
                        modifiedTime: DateTime.now(),
                      );
                      updateNoteInFirestore(notes[originalIndex]);
                    });
                  }
                },
                title: RichText(
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: '${note.title} \n',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: note.content,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Edited: ${DateFormat('EEE MMM d, yyyy h:mm a').format(note.modifiedTime)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                trailing: IconButton(
                  onPressed: () async {
                    final result = await confirmDialog(context, note);
                    if (result != null && result) {
                      deleteNoteFromFirestore(note.id);
                      deleteNote(note);
                    }
                  },
                  icon: Icon(
                    Icons.delete,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> updateNoteInFirestore(Note note) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.selectedUser!.id)
        .collection('notes')
        .doc(note.id)
        .update({
      'title': note.title,
      'content': note.content,
      'modifiedTime': note.modifiedTime,
    });
  }
}

class EditScreen extends StatefulWidget {
  final Note? note;

  const EditScreen({Key? key, this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: const EdgeInsets.all(0),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Title',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 30),
                    ),
                  ),
                  TextField(
                    controller: _contentController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type something here',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(
            context,
            [_titleController.text, _contentController.text],
          );
        },
        backgroundColor: Colors.grey.shade800,
        child: const Icon(Icons.save),
      ),
    );
  }
}

class Note {
  String id;
  String title;
  String content;
  DateTime modifiedTime;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.modifiedTime,
  });
}
