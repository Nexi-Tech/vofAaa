import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vof/FillPages/AppBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Maps_edit',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: MapsEdit(),
      ),
    );
  }
}

class MapsEdit extends StatefulWidget {
  @override
  _MapsEditState createState() => _MapsEditState();
}

class _MapsEditState extends State<MapsEdit> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>(); // Store markers
  final CollectionReference mapCollection =
  FirebaseFirestore.instance.collection('Maps');

  // Function to add a new marker with user-defined lat/lng and name
  Future<void> addMarker(double latitude, double longitude, String name) async {
    try {
      await mapCollection.add({
        'latitude': latitude,
        'longitude': longitude,
        'name': name,
      });
    } catch (e) {
      print('Error adding marker: $e');
    }
  }

  // Function to show a dialog for the user to enter lat/lng and name
  void showAddMarkerDialog() {
    double lat = 0.0; // Provide initial values
    double lng = 0.0; // Provide initial values
    String name = ''; // Provide an initial value for the name
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Marker'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Latitude'),
                onChanged: (value) {
                  lat = double.tryParse(value) ?? 0.0;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Longitude'),
                onChanged: (value) {
                  lng = double.tryParse(value) ?? 0.0;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                addMarker(lat, lng, name);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void loadMarkers() async {
    QuerySnapshot snapshot = await mapCollection.get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?; // Safely cast to Map

      if (data != null) {
        final double? latitude = data['latitude'] as double?;
        final double? longitude = data['longitude'] as double?;
        final String name = data['name'] as String;

        if (latitude != null && longitude != null) {
          setState(() {
            Marker marker = Marker(
              markerId: MarkerId('marker_${_markers.length + 1}'),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(title: name),
            );
            _markers.add(marker);
          });
        }
      }
    }
  }


  @override
  void initState() {
    super.initState();
    loadMarkers(); // Load markers from Firebase Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX.buildAppBar("Maps Edit"),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(31.768566873616884, 35.21449478029992),
          zoom: 5.0746,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // Set the position to bottom-left
      floatingActionButton: FloatingActionButton(
        onPressed: showAddMarkerDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
