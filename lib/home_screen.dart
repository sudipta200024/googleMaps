import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController googleMapController;
  Position? position;
  Marker? currentMarker;
  Polyline? currentPolyline;
  LatLng? lastPosition;
  final Set<Polyline> polylines = {};
  final List<LatLng> polylinePoints = [];
  Timer? locationUpdateTimer;

  Future<void> getCurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();
    if (isGranted) {
      final isServiceEnabled = await checkGPSServiceEnable();
      if (isServiceEnabled) {
        Position p = await Geolocator.getCurrentPosition();
        position = p;
        updateMarkerAndPolyline(LatLng(p.latitude, p.longitude));
        setState(() {});
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();
      if (result) {
        getCurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  void updateMarkerAndPolyline(LatLng newPosition) {
    setState(() {
      // Update the current marker
      currentMarker = Marker(
        markerId: const MarkerId('current-location'),
        position: newPosition,
        infoWindow: InfoWindow(
          title: "My Current Location",
          snippet: "${newPosition.latitude}, ${newPosition.longitude}",
        ),
      );

      // Add a new polyline point
      if (lastPosition != null) {
        polylinePoints.add(newPosition);
        currentPolyline = Polyline(
          polylineId: const PolylineId('path'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        );
        polylines.add(currentPolyline!);
      }

      lastPosition = newPosition;
    });

    // Animate the camera to the new position
    googleMapController.animateCamera(
      CameraUpdate.newLatLng(newPosition),
    );
  }

  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> checkGPSServiceEnable() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  void initState() {
    super.initState();
    // Start periodic location updates
    locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      getCurrentLocation();
    });
    getCurrentLocation();
  }

  @override
  void dispose() {
    locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real-Time Location Tracker"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              zoom: 16,
              target: LatLng(22.348903360876747, 91.85110613631802),
            ),
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            trafficEnabled: true,
            markers: currentMarker != null ? {currentMarker!} : {},
            polylines: polylines,
          ),
          Positioned(
            bottom: 150,
            right: 5,
            child: FloatingActionButton(
              onPressed: getCurrentLocation,
              child: const Icon(Icons.gps_fixed),
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//
//   late GoogleMapController googleMapController;
//
//   Position? position;
//   Future<void> getCurrentLocation() async{
//     final isGranted = await isLocationPermissionGranted();
//     if(isGranted){
//       final isServiceEnable = await checkGPSServiceEnable();
//       if(isServiceEnable){
//        Position p = await Geolocator.getCurrentPosition();
//        position = p;
//        setState(() {
//
//        });
//       }else{
//         Geolocator.openLocationSettings();
//       }
//     }else{
//       final result = await requestLocationPermission();
//       if(result){
//         getCurrentLocation();
//       }else{
//         Geolocator.openAppSettings();
//       }
//     }
//   }
//
//   Future<bool> isLocationPermissionGranted() async{
//    LocationPermission permission = await Geolocator.checkPermission();
//    if(permission == LocationPermission.always || permission==LocationPermission.whileInUse ){
//      return true;
//    }else{
//      return false;
//    }
//   }
//   Future<bool> requestLocationPermission() async{
//    LocationPermission permission = await Geolocator.requestPermission();
//    if(permission == LocationPermission.always || permission==LocationPermission.whileInUse ){
//      return true;
//    }else{
//      return false;
//    }
//   }
//   Future<bool> checkGPSServiceEnable()async{
//     return await Geolocator.isLocationServiceEnabled();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home"),
//       ),
//       body:  Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: const CameraPosition(
//               zoom: 16,
//               target: LatLng(22.348903360876747, 91.85110613631802),
//             ),
//             onTap: (LatLng? latlng) {
//               print(latlng);
//             },
//             zoomControlsEnabled: true,
//             zoomGesturesEnabled: true,
//             onMapCreated: (GoogleMapController controller) {
//               googleMapController = controller;
//             },
//             trafficEnabled: true,
//             markers: <Marker>{
//               const Marker(
//                 markerId: MarkerId('initial-positions'),
//                 position: LatLng(22.346665400938956, 91.85078356415033),
//               ),
//               Marker(
//                   markerId: const MarkerId('home'),
//                   position: const LatLng(22.352290447174607, 91.85135923326015),
//                   infoWindow: InfoWindow(
//                     title: "Home",
//                     onTap: () {
//                       print("on tap home");
//                     },
//                   ),
//                   draggable: true,
//                   onDragStart: (LatLng onStartLatLng) {
//                     print("on start drag : $onStartLatLng");
//                   },
//                   onDragEnd: (LatLng onStopLatLng) {
//                     print("on End drag : $onStopLatLng");
//                   }),
//             },
//
//           ),
//           Positioned(
//               bottom: 150,
//               right: 5,
//               child: FloatingActionButton(
//                 onPressed: () {
//                   googleMapController.animateCamera(
//                     CameraUpdate.newCameraPosition(
//                       CameraPosition(target: LatLng(22.34781678638016, 91.85232348740101),
//                       zoom: 16)
//                     ),
//                   );
//                 },
//                 child: const Icon(Icons.gps_fixed),
//               ))
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
//
//
