import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UtrPageProvider with ChangeNotifier {
  Timestamp _timestamp = Timestamp.now();
  bool _isAttendanceMarked = false;
  Position? _currentUserPosition;
  bool _isFetchingData = true;
  bool _alertShown = false;

  final TextEditingController timedateController = TextEditingController();

  UtrPageProvider();

  bool get isAttendanceMarked => _isAttendanceMarked;
  bool get isFetchingData => _isFetchingData;
  bool get alertShown => _alertShown;
  Timestamp get timestamp => _timestamp;
  Position? get currentUserPosition => _currentUserPosition;

  void updatePosition(Position position) {
    _currentUserPosition = position;
    notifyListeners();
  }

  Future<void> initializeData(String empCode) async {
    try {
      await _loadAttendanceState();
      await getLocationName();
      await _getCurrentUserLocation();

      updateTimestamp();
    } catch (e) {
      print('Error in initializeData: $e');
    } finally {
      _isFetchingData = false;
      notifyListeners();
    }
  }

  Future<void> _saveAttendanceMarkedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      DateTime currentTime = await NTP.now(); // Get time from NTP
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentTime);
      await prefs.setString('attendance_marked_date', formattedDate);
    } catch (e) {
      print('Error fetching NTP time: $e');
    }
  }

  Future<void> _loadAttendanceState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAttendanceMarked = prefs.getBool('isAttendanceMarked') ?? false;

    try {
      DateTime currentTime = await NTP.now(); // Get time from NTP
      String todayDate = DateFormat('yyyy-MM-dd').format(currentTime);
      String? attendanceDate = prefs.getString('attendance_marked_date');

      if (attendanceDate != null && attendanceDate == todayDate) {
        _isAttendanceMarked = true;
      } else {
        _isAttendanceMarked = false;
        prefs.remove('attendance_marked_date');
        prefs.remove('disabled_time_slots');
      }
    } catch (e) {
      print('Error fetching NTP time: $e');
      _isAttendanceMarked = false;
    }

    notifyListeners();
  }

  void markAttendance() {
    if (!_isAttendanceMarked) {
      _isAttendanceMarked = true;
      _saveAttendanceMarkedDate(); // Save attendance with NTP time
      notifyListeners();
    }
  }

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
          break;
        }
      }
    }
    return locationName ?? 'Out of station';
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
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: const Text(
              'You are far away from the location!!',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
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

  Future<void> updateTimestamp() async {
    try {
      DateTime currentTime = await NTP.now(); // Use NTP time
      String formattedDateTime =
          DateFormat('yyyy-MM-dd hh:mm a').format(currentTime);
      _timestamp =
          Timestamp.fromDate(currentTime); // Store as Firebase Timestamp
      timedateController.text = formattedDateTime; // Update text controller
    } catch (e) {
      print('Error fetching NTP time: $e');
    }
  }

  final List<Map<String, dynamic>> predefinedLocations = [
    {
      'name': 'PNTK',
      'latitude': 8.538520,
      'longitude': 77.023149,
      'radius': 0.25
    },
    {
      'name': 'PNTM',
      'latitude': 8.51913,
      'longitude': 76.94493,
      'radius': 0.25
    },
    {
      'name': 'PNTS',
      'latitude': 8.534636,
      'longitude': 76.942233,
      'radius': 0.25
    },
    {
      'name': 'PNTT',
      'latitude': 8.498862,
      'longitude': 76.943550,
      'radius': 0.25
    },
    {
      'name': 'PNTU',
      'latitude': 8.533248,
      'longitude': 76.962852,
      'radius': 0.25
    },
    {
      'name': 'PNTV',
      'latitude': 8.525702,
      'longitude': 76.991817,
      'radius': 0.25
    },
    {
      'name': 'PNK1',
      'latitude': 10.001869,
      'longitude': 76.279236,
      'radius': 0.25
    },
    {
      'name': 'PNKA',
      'latitude': 10.112935,
      'longitude': 76.354550,
      'radius': 0.25
    },
    {
      'name': 'PNKE',
      'latitude': 10.03485,
      'longitude': 76.33369,
      'radius': 0.25
    },
    {
      'name': 'PNKP',
      'latitude': 9.963107,
      'longitude': 76.295558,
      'radius': 0.25
    },
    {
      'name': 'PNKV',
      'latitude': 9.99489,
      'longitude': 76.32606,
      'radius': 0.25
    },
    {
      'name': 'PNKQ',
      'latitude': 11.29278,
      'longitude': 75.81770,
      'radius': 0.25
    },
    {
      'name': 'PNTN',
      'latitude': 9.385180,
      'longitude': 76.587229,
      'radius': 0.25
    },
    {
      'name': 'PNKG',
      'latitude': 9.584526,
      'longitude': 76.547472,
      'radius': 0.25
    },
    {
      'name': 'PNKO',
      'latitude': 8.879023,
      'longitude': 76.609582,
      'radius': 0.25
    },
    {
      'name': 'ALWD',
      'latitude': 10.13449,
      'longitude': 76.35766,
      'radius': 0.1
    },
    {
      'name': 'COKD',
      'latitude': 10.00755,
      'longitude': 76.35964,
      'radius': 0.1
    },
    {
      'name': 'TVCY',
      'latitude': 8.489644,
      'longitude': 76.930294,
      'radius': 0.1
    },
    {'name': 'TRVM', 'latitude': 9.32715, 'longitude': 76.72961, 'radius': 0.1},
    {'name': 'TRVY', 'latitude': 9.40751, 'longitude': 76.79594, 'radius': 0.1},
    {
      'name': 'KALA1',
      'latitude': 10.081877,
      'longitude': 76.283371,
      'radius': 0.25
    },
    {
      'name': 'KALA',
      'latitude': 10.064555,
      'longitude': 76.322242,
      'radius': 0.02
    },
  ];

  Future<bool> isUserActive(String empCode) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('USERS')
          .where('EmpCode', isEqualTo: empCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docData =
            querySnapshot.docs.first.data() as Map<String, dynamic>?;

        if (docData != null) {
          // Check if the status field exists and its value
          final status = docData['status'] as String?;
          if (status == null || status == "active") {
            return true; // User is active if there's no status field or status is 'active'
          } else if (status == "inactive") {
            return false; // User is inactive if status is 'inactive'
          }
        }
      }
      return true; // Consider user active if no document or status field is missing
    } catch (e) {
      print('Failed to check user status: $e');
      return false;
    }
  }
}
