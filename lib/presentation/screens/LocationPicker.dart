import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class LocationPicker extends StatefulWidget {
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? selectedLocation;
  Set<Marker> _markers = {};
  LatLng? initialPosition;
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _goToUserLocation();
  }

   @override
  void initState() {
    super.initState();
  }

   Future<LatLng?> _getCurrentUserLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

Future<void> _goToUserLocation() async {
  final Position position = await Geolocator.getCurrentPosition();
  mapController.animateCamera(CameraUpdate.newCameraPosition(
    CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.5,
    ),
  ));
}

_setSelectedLocation(LatLng location) {
    setState(() {
      selectedLocation = location;
      Navigator.of(context).pop(selectedLocation);

    });
  }

   _onSendCurrentLocation() async {
    LatLng? currentUserLocation = await _getCurrentUserLocation();
    if (currentUserLocation != null) {
      _setSelectedLocation(currentUserLocation);
      mapController.animateCamera(CameraUpdate.newLatLng(currentUserLocation));
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 44, 59, 88),
      appBar: AppBar(
        backgroundColor: Color(0xFF4D6596),
        title: Text("Selecciona una ubicación"),
        actions: [
          if(selectedLocation!=null)
          IconButton(
            
            icon: Icon(Icons.check),
            onPressed: selectedLocation != null
                ? () {
                    Navigator.of(context).pop(selectedLocation);
                  }
                : Navigator.of(context).pop,
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
        myLocationEnabled: true,
        onTap: (location) {
          setState(() {
            selectedLocation = location;
            _markers.clear();
            _markers.add(
              Marker(markerId: MarkerId("selected"), position: location),
            );
          });
        },
        markers: _markers,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: initialPosition ?? LatLng(0, 0),
          zoom: 5.0,
        ),
      ),
      Positioned(
          top: 10.0, 
          left: 10.0, 
          child: ElevatedButton(
            onPressed: _onSendCurrentLocation,
            style: ElevatedButton.styleFrom(
              primary: Colors.blueAccent,
            ),
            child: Text("Enviar mi Ubicación Actual"),
          ),
        ),
        ],
      )
    ); 
  }
}
