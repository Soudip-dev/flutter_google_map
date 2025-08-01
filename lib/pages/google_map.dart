import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

Location _locationController = Location();


  static const LatLng _target = LatLng(22.36304, 87.97209);
  static const LatLng _mark = LatLng(22.36834, 87.97410);
  LatLng ?currentP;

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
  print(_locationData);
  _locationController.onLocationChanged.listen((LocationData currentLocation) {
  
    if(currentLocation.latitude != null && currentLocation.longitude != null){
       setState(() {
      currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        print(currentLocation);
    });
    }
    
  });

}

@override
  void initState() {
    
    super.initState();
    getlocation();
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:currentP == null ? Center(child: CircularProgressIndicator(),) :  GoogleMap(initialCameraPosition: CameraPosition(target: _target, zoom: 13,),markers: {
      Marker(markerId: MarkerId("_currentLocation"),position: currentP!,icon: BitmapDescriptor.defaultMarker,),
      Marker(markerId: MarkerId("_sourceLocation"),position: _mark,icon: BitmapDescriptor.defaultMarker,),
      Marker(markerId: MarkerId("_destinationLocation"),position: _target,icon: BitmapDescriptor.defaultMarker,),
    },),);
  }

}