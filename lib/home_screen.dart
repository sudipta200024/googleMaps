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
  bool isLoading = false;

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      final isGranted = await isLocationPermissionGranted();
      if (isGranted) {
        final isServiceEnabled = await checkGPSServiceEnable();
        if (isServiceEnabled) {
          Position p = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          position = p;
          updateMarkerAndPolyline(LatLng(p.latitude, p.longitude));
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
    } catch (e) {
      print("Error getting location: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
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
          snippet: "${newPosition.latitude.toStringAsFixed(6)}, ${newPosition.longitude.toStringAsFixed(6)}",
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
      } else {
        // First location, just add the point
        polylinePoints.add(newPosition);
      }

      lastPosition = newPosition;
    });

    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: newPosition,
          zoom: 16,
        ),
      ),
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

  }

  @override
  void dispose() {
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
              onPressed: isLoading ? null : getCurrentLocation,
              backgroundColor: isLoading ? Colors.grey : null,
              child: isLoading
                  ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
                  : const Icon(Icons.gps_fixed),
            ),
          ),
        ],
      ),
    );
  }
}