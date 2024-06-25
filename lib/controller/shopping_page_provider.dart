import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingPageProvider with ChangeNotifier {
  String? _selectedTimeSlot;
  final List<String> _timeSlots = [
    'Morning (before 12 PM)' , 'Evening (after 12 PM)'
  ];
  List<String> _disabledTimeSlots = [];
  Timestamp _timestamp = Timestamp.now();
    bool _isAttendanceMarked = false;

  String? get selectedTimeSlot => _selectedTimeSlot;
  List<String> get timeSlots => _timeSlots;
  List<String> get disabledTimeSlots => _disabledTimeSlots;
  bool get isAttendanceMarked => _isAttendanceMarked;
  Color get buttonColor => _isAttendanceMarked ? Colors.grey.shade200 : Colors.blue;
  Timestamp get timestamp => _timestamp;
  final TextEditingController timedateController = TextEditingController();

  ShoppingPageProvider() {
    initializeData();
  }

  Future<void> initializeData() async {
  try {
      await _loadDisabledTimeSlotsFromPrefs();
      await _loadSelectedTimeSlotFromPrefs();
        await _loadAttendanceState();

      await _getCurrentUserLocation();

      bool atWarehouse = isWithinPredefinedLocation();
      if (atWarehouse) {
        await _saveDisabledTimeSlotsToPrefs();
      }

      updateTimestamp();
    } catch (e) {
      print('Error in fetchData: $e');
    } finally {
      _isFetchingData = false;
      notifyListeners();
    }
  }

  Future<void> _loadDisabledTimeSlotsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? disabledTimeSlotsJson = prefs.getString('disabled_time_slots');
    if (disabledTimeSlotsJson != null) {
      _disabledTimeSlots = List<String>.from(jsonDecode(disabledTimeSlotsJson));
    }
    notifyListeners(); // Notify listeners to update UI after loading
  }

  Future<void> _saveDisabledTimeSlotsToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String disabledTimeSlotsJson = jsonEncode(_disabledTimeSlots);
    prefs.setString('disabled_time_slots', disabledTimeSlotsJson);
  }

  Future<void> _loadSelectedTimeSlotFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedTimeSlot = prefs.getString('selected_time_slot');
    notifyListeners(); // Notify listeners to update UI after loading
  }

  Future<void> _saveSelectedTimeSlotToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_selectedTimeSlot != null) {
      prefs.setString('selected_time_slot', _selectedTimeSlot!);
    }
  }

  Future<void> _saveAttendanceMarkedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('attendance_marked_date', formattedDate);
  }

  Future<void> _loadAttendanceState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAttendanceMarked = prefs.getBool('isAttendanceMarked') ?? false;

    String? attendanceDate = prefs.getString('attendance_marked_date');
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (attendanceDate != null && attendanceDate == todayDate) {
      _isAttendanceMarked = true;
    } else {
      _isAttendanceMarked = false;
      // Clear saved attendance date and disabled time slots if it's a new day
      prefs.remove('attendance_marked_date');
      prefs.remove('disabled_time_slots');
      _disabledTimeSlots.clear();
    }

    notifyListeners();
  }

  void markAttendance() {
    if (!_isAttendanceMarked) {
      _isAttendanceMarked = true;
      _saveAttendanceMarkedDate();
      notifyListeners();
    }
  }

  void setSelectedTimeSlot(String? value) {
    _selectedTimeSlot = value;
    _saveSelectedTimeSlotToPrefs();
    notifyListeners();
  }

  void disableSelectedTimeSlot() {
    if (_selectedTimeSlot != null &&
        !_disabledTimeSlots.contains(_selectedTimeSlot)) {
      _disabledTimeSlots.add(_selectedTimeSlot!);
      _saveDisabledTimeSlotsToPrefs();
      notifyListeners();
    }
  }
  

  Position? _currentUserPosition;

  Position? get currentUserPosition => _currentUserPosition;

  void updatePosition(Position position) {
    _currentUserPosition = position;
    notifyListeners();
  }

  bool _isFetchingData = true;
  bool _alertShown = false;

  final List<Map<String, dynamic>> predefinedLocations = [
    {'name': 'ALWD', 'latitude': 10.13449, 'longitude': 76.35766, 'radius': 0.1},
    {'name': 'COKD', 'latitude': 10.00755, 'longitude': 76.35964, 'radius': 0.1},
    {'name': 'TVCY', 'latitude': 8.489644, 'longitude': 76.930294, 'radius': 0.1},
    {'name': 'TRVM', 'latitude': 9.32715, 'longitude': 76.72961, 'radius': 0.1},
    {'name': 'TRVY', 'latitude': 9.40751, 'longitude': 76.79594, 'radius': 0.1},
    {'name':'KALA','latitude': 10.064555, 'longitude': 76.322242, 'radius':0.25},
    {'name':'KALA1','latitude': 10.081877, 'longitude': 76.283371 , 'radius': 0.25},

       
  ];

  bool get isFetchingData => _isFetchingData;
  bool get alertShown => _alertShown;

  Future<void> _getCurrentUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _currentUserPosition = position;
      notifyListeners();
    } catch (e) {
      _isFetchingData = false;
      notifyListeners();
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  bool isWithinPredefinedLocation() {
    if (_currentUserPosition != null) {
      for (var location in predefinedLocations) {
        double distance = _calculateDistance(
            location['latitude']!,
            location['longitude']!,
            _currentUserPosition!.latitude,
            _currentUserPosition!.longitude);
        if (distance <= location['radius']!) {
          return true;
        }
      }
    }
    return false;
  }
  String getLocationName() {
    String? locationName;
    if (_currentUserPosition != null) {
      for (var location in predefinedLocations) {
        double distance = _calculateDistance(
            location['latitude']!,
            location['longitude']!,
            _currentUserPosition!.latitude,
            _currentUserPosition!.longitude);
        if (distance <= location['radius']!) {
          locationName = location['name'];
          break; // No need to continue looping if the location is found
        }
      }
    }
    return locationName ?? 'Unknown'; // Return 'Unknown' if the user is not within any predefined location
  }

  void resetAlertShown() {
    _alertShown = false;
    notifyListeners();
  }

  void showLocationAlert(BuildContext context) {
    bool atPredefinedLocation = isWithinPredefinedLocation();

    if (!_alertShown && !atPredefinedLocation && _currentUserPosition != null) {
      _alertShown = true;
      notifyListeners();

      showDialog(
        barrierColor: Colors.blueGrey,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'You are far away from the location!!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red),
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
                  _alertShown = true;
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
    void updateTimestamp() {
    _timestamp = Timestamp.now();
    timedateController.text =
        DateFormat('yyyy-MM-dd hh:mm a').format(_timestamp.toDate());
    notifyListeners();
  }
}


  