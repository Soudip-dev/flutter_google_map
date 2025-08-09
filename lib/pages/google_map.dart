import 'dart:async' show Completer;

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map/const.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
Location _locationController = Location();


  static const LatLng _target = LatLng(22.36304, 87.97209);
  static const LatLng _mark = LatLng(22.36834, 87.97410);
  LatLng ?currentP;

Future<List<LatLng>> getPolylinePoints()async{
  List <LatLng> polilineCoordinates = [];
 // Initialize PolylinePoints
PolylinePoints polylinePoints = PolylinePoints(apiKey: GOOGLE_MAP_API_KEY);

// Get route using legacy Directions API
PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  request: PolylineRequest(
    origin: PointLatLng(22.36304, 87.97209), // San Francisco
    destination: PointLatLng(22.36834, 87.97410), // San Jose
    mode: TravelMode.driving,
  ),
);
print("Result>>>>>>>>>>>>${result.points.toString()}");
if (result.points.isNotEmpty) {
  // print("result.points>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<${result.toString()}");
  // Convert to LatLng for Google Maps
  // List<LatLng> polylineCoordinates = result.points
  //     .map((point) => LatLng(point.latitude, point.longitude))
  //     .toList();
  result.points.forEach((PointLatLng points){
     polilineCoordinates.add(LatLng(points.latitude, points.longitude));
  });
}
// print("polilineCoordinates((((((((((((((())))))))))))))) $polilineCoordinates");
  return polilineCoordinates;
}

Future<void> _cameraToPosition(LatLng pos)async{
  final GoogleMapController controller = await _mapController.future;
  CameraPosition newCameraPosition =  CameraPosition(target: pos,zoom: 13);
 await controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
}

Future<void > getlocation()async{
   bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await _locationController.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await _locationController.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await _locationController.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await _locationController.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  _locationData = await _locationController.getLocation();
  
  _locationController.onLocationChanged.listen((LocationData currentLocation) {
  
    if(currentLocation.latitude != null && currentLocation.longitude != null){
       setState(() {
       
      currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      
      _cameraToPosition(currentP!);
        
    });
    }
    
  });

}

@override
  void initState() {
    
    super.initState();
    getlocation().then((_){
      print("getPolylinePoints fun hit>>>>>>>>>>>>>>>>>>>>>.");
      getPolylinePoints().then((coordinate)=>print("coordinate"));
    });
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:currentP == null ? Center(child: CircularProgressIndicator(),) :  GoogleMap(
      onMapCreated: (GoogleMapController controller){
        _mapController.complete(controller);
      },
      initialCameraPosition: CameraPosition(target: _target, zoom: 13,),markers: {
      Marker(markerId: MarkerId("_currentLocation"),position: currentP!,icon: BitmapDescriptor.defaultMarker,),
      Marker(markerId: MarkerId("_sourceLocation"),position: _mark,icon: BitmapDescriptor.defaultMarker,),
      Marker(markerId: MarkerId("_destinationLocation"),position: _target,icon: BitmapDescriptor.defaultMarker,),
    },),);
  }

}