import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _selectedLocation = const LatLng(13.7563, 100.5018); // เริ่มต้นที่กรุงเทพ
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("เลื่อนหมุดเพื่อเลือกที่อยู่"), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 16),
            onCameraMove: (position) => _selectedLocation = position.target,
            myLocationEnabled: true,
          ),
          // หมุดกลางหน้าจอ
          const Center(child: Icon(Icons.location_on, size: 50, color: Colors.red)),
          // ปุ่มยืนยัน
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B14F), padding: const EdgeInsets.all(15)),
              onPressed: () => Navigator.pop(context, _selectedLocation),
              child: const Text("ยืนยันตำแหน่งนี้", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }
}