import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:vof/SubPages/Maps/location_service.dart';
import '../../FillPages/AppBar.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final String phoneNumber = '1234567890';
  final String email = 'example@example.com';

  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = Set<Marker>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.768566873616884, 35.21449478029992),
    zoom: 5.0746,
  );

  @override
  void initState() {
    super.initState();
    _loadMarkersLocally().then((localMarkers) {
      if (localMarkers.isNotEmpty) {
        setState(() {
          _markers = localMarkers;
        });
      }
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        _syncMarkersWithFirestore();
      }
    });

    // Load markers from Firestore on app launch
    _loadMarkersFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX.buildAppBar("Map"),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black)),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: TextFormField(
                      controller: _searchController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: 'Search by City'),
                      onChanged: (value) {
                        print(value);
                      },
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    var place = await LocationService().getPlace(_searchController.text);
                    _goToPlace(place);
                  },
                  icon: Icon(Icons.search, color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _markers,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  Future<void> _loadMarkersFromFirestore() async {
    Set<Marker> firestoreMarkers = await _getMarkersFromFirestore();
    setState(() {
      _markers.clear(); // Clear existing markers
      _markers.addAll(firestoreMarkers);
    });
  }

  Future<Set<Marker>> _getMarkersFromFirestore() async {
    Set<Marker> markers = Set<Marker>();
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Maps').get();
    snapshot.docs.forEach((document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      double lat = data['latitude'];
      double lng = data['longitude'];
      String placeName = data['name'];

      markers.add(
        Marker(
          markerId: MarkerId(document.id),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: placeName),
        ),
      );

      _saveMarkersLocally(markers);
    });

    return markers;
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    double lat = place['geometry']['location']['lat'];
    double lng = place['geometry']['location']['lng'];
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15),
      ),
    );
  }

  void _updateMarkersState(Set<Marker> markers) {
    setState(() {
      _markers = markers;
      _saveMarkersLocally(markers);
    });
  }

  Future<void> _saveMarkersLocally(Set<Marker> markers) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File markersFile = File('${appDocDir.path}/markers.json');

    // Create a list of marker data to be saved
    List<Map<String, dynamic>> markerDataList = markers.map((marker) {
      return {
        'id': marker.markerId.value,
        'latitude': marker.position.latitude,
        'longitude': marker.position.longitude,
        'name': marker.infoWindow.title,
      };
    }).toList();

    // Serialize the list to JSON and write it to the file
    markersFile.writeAsString(jsonEncode(markerDataList));
  }

  Future<Set<Marker>> _loadMarkersLocally() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File markersFile = File('${appDocDir.path}/markers.json');
    if (!await markersFile.exists()) return Set<Marker>();

    String markersJson = await markersFile.readAsString();
    List<dynamic> markersData = jsonDecode(markersJson);
    Set<Marker> markers = markersData.map((data) {
      return Marker(
        markerId: MarkerId(data['id']),
        position: LatLng(data['latitude'], data['longitude']),
        infoWindow: InfoWindow(title: data['name']),
      );
    }).toSet();

    return markers;
  }

  Future<void> _syncMarkersWithFirestore() async {
    Set<Marker> localMarkers = await _loadMarkersLocally();
    Set<Marker> firestoreMarkers = await _getMarkersFromFirestore();

    Set<Marker> combinedMarkers = {...localMarkers, ...firestoreMarkers};

    await FirebaseFirestore.instance.collection('Maps').doc('document_id').set({
      'markers': combinedMarkers.map((marker) => {
        'id': marker.markerId.value,
        'latitude': marker.position.latitude,
        'longitude': marker.position.longitude,
        'name': marker.infoWindow.title,
      }).toList(),
    });

    Directory appDocDir = await getApplicationDocumentsDirectory();
    File markersFile = File('${appDocDir.path}/markers.json');
    await markersFile.delete();
  }
}

void main() {
  runApp(MaterialApp(
    home: MapSample(),
  ));
}
