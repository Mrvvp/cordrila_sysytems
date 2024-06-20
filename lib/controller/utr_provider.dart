import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UtrpageProvider with ChangeNotifier {
  // Properties related to location and timestamp
  Position? _currentPosition;
  Timestamp _timestamp = Timestamp.now();

  // Getters for position and timestamp
  Position? get currentPosition => _currentPosition;
  Timestamp get timestamp => _timestamp;

  // Controller for displaying formatted timestamp
  final TextEditingController timedateController = TextEditingController();

  // Loading state
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Dialog state
  bool _dialogShown = false;
  bool get dialogShown => _dialogShown;

  // Attendance state
  bool _isAttendanceMarked = false;
  bool get isAttendanceMarked => _isAttendanceMarked;

  // Button color
  Color _buttonColor = Colors.blue;
  Color get buttonColor => _buttonColor;

  // List of station locations with name, latitude, longitude, and radius
  final List<Map<String, dynamic>> stationLocations = [
    {'name': 'ALWD', 'latitude': 10.13449, 'longitude': 76.35766, 'radius': 0.1},
    {'name': 'COKD', 'latitude': 10.00755, 'longitude': 76.35964, 'radius': 0.1},
    {'name': 'TVCY', 'latitude': 8.489644, 'longitude': 76.930294, 'radius': 0.1},
    {'name': 'TRVM', 'latitude': 9.32715, 'longitude': 76.72961, 'radius': 0.1},
    {'name': 'TRVY', 'latitude': 9.40751, 'longitude': 76.79594, 'radius': 0.1},
    {'name': 'PNTK', 'latitude': 8.53852, 'longitude': 77.023149, 'radius': 0.25},
    {'name': 'PNTM', 'latitude': 8.51913, 'longitude': 76.94493, 'radius': 0.25},
    {'name': 'PNTS', 'latitude': 8.534636, 'longitude': 76.942233, 'radius': 0.25},
    {'name': 'PNTT', 'latitude': 8.498862, 'longitude': 76.94355, 'radius': 0.25},
    {'name': 'PNTU', 'latitude': 8.533248, 'longitude': 76.962852, 'radius': 0.25},
    {'name': 'PNTV', 'latitude': 8.525702, 'longitude': 76.991817, 'radius': 0.25},
    {'name': 'PNK1', 'latitude': 10.001869, 'longitude': 76.279236, 'radius': 0.25},
    {'name': 'PNKA', 'latitude': 10.112935, 'longitude': 76.35455, 'radius': 0.25},
    {'name': 'PNKE', 'latitude': 10.03485, 'longitude': 76.33369, 'radius': 0.25},
    {'name': 'PNKP', 'latitude': 9.963107, 'longitude': 76.295558, 'radius': 0.25},
    {'name': 'PNKV', 'latitude': 9.99489, 'longitude': 76.32606, 'radius': 0.25},
    {'name': 'PNKQ', 'latitude': 11.29278, 'longitude': 75.8177, 'radius': 0.25},
    {'name': 'KALA', 'latitude': 10.064555, 'longitude': 76.322242, 'radius': 5},
    {'name': 'PNTN', 'latitude': 9.38518, 'longitude': 76.587229, 'radius': 0.25},
    {'name': 'PNKG', 'latitude': 9.584526, 'longitude': 76.547472, 'radius': 0.25},
    {'name': 'PNKO', 'latitude': 8.879023, 'longitude': 76.609582, 'radius': 0.25},
    {'name': 'JMVH', 'latitude': 10.081877, 'longitude': 76.283371, 'radius': 0.25},
  ];

  // Initialize provider with loading data and initial state
  UtrpageProvider() {
    loadData();
    _loadAttendanceState();
  }

  // Load initial data including location and attendance state
  Future<void> loadData() async {
    try {
      await _getUpdatedLocation();
      await _loadAttendanceState();
      updateTimestamp();
    } catch (e) {
      print('Error in loadData: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get updated user location
  Future<void> _getUpdatedLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      notifyListeners();
    } catch (e) {
      print('Error in _getUpdatedLocation: $e');
      _setLoading(false);
    }
  }

  // Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
    double lat1, double lon1, double lat2, double lon2,
  ) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Check if user is at any station
  bool isAtAnyStation() {
    if (_currentPosition != null) {
      for (var station in stationLocations) {
        double distance = _calculateDistance(
          station['latitude'],
          station['longitude'],
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        if (distance <= station['radius']) {
          return true;
        }
      }
    }
    return false;
  }

  // Get location name if user is at any station
  String getLocationName() {
    String? locationName;
    if (_currentPosition != null) {
      for (var location in stationLocations) {
        double distance = _calculateDistance(
          location['latitude'],
          location['longitude'],
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        if (distance <= location['radius']) {
          locationName = location['name'];
          break;
        }
      }
    }
    return locationName ?? 'Unknown';
  }

  // Show location dialog if user is not at any station
  void showLocationDialog(BuildContext context) {
    bool atAnyStation = isAtAnyStation();

    if (!_dialogShown && !atAnyStation && _currentPosition != null) {
      _dialogShown = true;
      notifyListeners();

      showDialog(
        barrierColor: Colors.blueGrey,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'You are far away from the location!!',
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red,
              ),
            ),
            content: const Text(
              'Please go to the station',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _dialogShown = false;
                  notifyListeners();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  // Update timestamp when needed
  void updateTimestamp() {
    _timestamp = Timestamp.now();
    timedateController.text =
      DateFormat('yyyy-MM-dd hh:mm a').format(_timestamp.toDate());
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Load attendance state from SharedPreferences
 Future<void> _loadAttendanceState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _isAttendanceMarked = prefs.getBool('isAttendanceMarked') ?? false;

  String? disableDate = prefs.getString('disableDate');
  String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  if (disableDate != null && disableDate == todayDate) {
    _isAttendanceMarked = true;
    _buttonColor = Colors.grey.shade200;
  } else {
    _isAttendanceMarked = false;
    _buttonColor = Colors.blue;
    // Clear saved disable date if it's a new day
    prefs.remove('disableDate');
    _saveAttendanceState();
  }

  notifyListeners();
}

// Mark attendance and save state
void markAttendance() {
  if (!_isAttendanceMarked) {
    _isAttendanceMarked = true;
    _buttonColor = Colors.grey.shade200;

    // Save attendance state
    _saveAttendanceState();

    // Save the disable date
    _saveDisableDate();

    // Notify listeners to update UI
    notifyListeners();
  }
}

// Save disable date in SharedPreferences
Future<void> _saveDisableDate() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('disableDate', DateFormat('yyyy-MM-dd').format(DateTime.now()));
}

// Save attendance state in SharedPreferences
Future<void> _saveAttendanceState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isAttendanceMarked', _isAttendanceMarked);
}

}

