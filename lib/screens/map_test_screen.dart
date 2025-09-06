import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MapTestScreen extends StatefulWidget {
  const MapTestScreen({super.key});

  @override
  State<MapTestScreen> createState() => _MapTestScreenState();
}

class _MapTestScreenState extends State<MapTestScreen> {
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(25.0330, 121.5654), // Taipei 101
    zoom: 15.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地圖測試'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: PointerInterceptor(
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kInitialPosition,
            onMapCreated: (GoogleMapController controller) {
              print('測試地圖創建成功');
            },
            markers: {
              const Marker(
                markerId: MarkerId('test_marker'),
                position: LatLng(25.0330, 121.5654),
                infoWindow: InfoWindow(title: '測試標記'),
              ),
            },
          ),
        ),
      ),
    );
  }
}
