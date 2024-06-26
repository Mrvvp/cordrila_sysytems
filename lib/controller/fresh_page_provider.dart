import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreshPageProvider with ChangeNotifier {
  String? _selectedTimeSlot;
  final List<String> _timeSlots = [
    '7 AM - 10 AM', 
    '10 AM - 1 PM',
    '1 PM - 4 PM',
    '4 PM - 7 PM',
    '7 PM - 10 PM'
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
   String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Map<String, String> _disabledSlotsWithDate = {};

  

  FreshPageProvider() {
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
    notifyListeners();
  }

  Future<void> _saveDisabledTimeSlotsToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String disabledTimeSlotsJson = jsonEncode(_disabledTimeSlots);
    prefs.setString('disabled_time_slots', disabledTimeSlotsJson);
  }

  Future<void> _loadSelectedTimeSlotFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedTimeSlot = prefs.getString('selected_time_slot');
    notifyListeners();
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
      prefs.remove('attendance_marked_date');
      prefs.remove('disabled_time_slots');
      _disabledTimeSlots.clear();
    }

    notifyListeners();
  }

  void markAttendance() {
    if (!_isAttendanceMarked) {
      _isAttendanceMarked = true;  // Corrected to mark attendance correctly
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
      _disabledSlotsWithDate[_selectedTimeSlot!] = _currentDate;
      _saveDisabledTimeSlotsToPrefs();
      notifyListeners();
    }
  }

  bool isTimeSlotSelectedForToday(String timeSlot) {
    return _disabledSlotsWithDate[timeSlot] == _currentDate;
  }

  void resetDisabledTimeSlotsIfDateChanged() {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_currentDate != todayDate) {
      _currentDate = todayDate;
      _disabledTimeSlots.clear();
      _disabledSlotsWithDate.clear();
      _saveDisabledTimeSlotsToPrefs(); // Save the reset state
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
    {'name':'PNTK', 'latitude': 8.538520, 'longitude': 77.023149, 'radius': 0.25},
    {'name':'PNTM','latitude': 8.51913, 'longitude': 76.94493, 'radius': 0.25},
    {'name':'PNTS','latitude': 8.534636, 'longitude': 76.942233, 'radius': 0.25},
    {'name':'PNTT','latitude': 8.498862, 'longitude': 76.943550, 'radius': 0.25},
    {'name':'PNTU','latitude': 8.533248, 'longitude': 76.962852, 'radius': 0.25},
    {'name':'PNTV','latitude': 8.525702, 'longitude': 76.991817, 'radius': 0.25},
    {'name':'PNK1','latitude': 10.001869, 'longitude': 76.279236, 'radius': 0.25},
    {'name':'PNKA','latitude': 10.112935, 'longitude': 76.354550, 'radius': 0.25},
    {'name':'PNKE','latitude': 10.03485, 'longitude': 76.33369, 'radius': 0.25},
    {'name':'PNKP','latitude': 9.963107, 'longitude': 76.295558, 'radius': 0.25},
    {'name':'PNKV','latitude': 9.99489, 'longitude': 76.32606, 'radius': 0.25},
    {'name':'PNKQ','latitude': 11.29278, 'longitude': 75.81770, 'radius': 0.25},
    {'name':'PNTN','latitude': 9.385180, 'longitude': 76.587229, 'radius': 0.25},
    {'name':'PNKG','latitude': 9.584526, 'longitude': 76.547472, 'radius': 0.25},
    {'name':'PNKO','latitude': 8.879023, 'longitude': 76.609582 , 'radius': 0.25},
    {'name':'KALA1','latitude': 10.081877, 'longitude': 76.283371 , 'radius': 0.25},
    {'name':'KALA','latitude': 10.064555, 'longitude': 76.322242, 'radius':0.25},
      

       
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


  


  


  