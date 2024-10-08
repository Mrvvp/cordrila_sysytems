import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';

class ShoppingPageProvider with ChangeNotifier {
  Timestamp _timestamp = Timestamp.now();
  Position? _alternativeLocation;
  bool _isHomeLocationSet = false;

  Timestamp get timestamp => _timestamp;
  final TextEditingController timedateController = TextEditingController();

  Position? get alternativeLocation => _alternativeLocation;
  bool get isHomeLocationSet => _isHomeLocationSet;

  String? _selectedYesNoOption;
  final List<String> _yesNoOptions = ['Yes', 'No'];

  String? get selectedYesNoOption => _selectedYesNoOption;
  List<String> get yesNoOptions => _yesNoOptions;

  String? _selectedDoneNoOption;
  final List<String> _doneNoOptions = ['Yes', 'No', 'Not Applicable'];

  String? get selectedDoneNoOption => _selectedDoneNoOption;
  List<String> get doneNoOptions => _doneNoOptions;

  String? _selectedTrueFalseOption;
  final List<String> _trueFalseOptions = ['Yes', 'No'];

  String? get selectedTrueFalseOption => _selectedTrueFalseOption;
  List<String> get trueFalseOptions => _trueFalseOptions;

  ShoppingPageProvider();

  Future<void> initializeData(String empCode) async {
    try {
      await getLocationName();
      await _getCurrentUserLocation();
      await loadHomeLocationFromFirestore(empCode);
      bool atWarehouse =
          isWithinPredefinedLocation() || isWithinAlternativeLocation();
      if (atWarehouse) {}

      updateTimestamp();
    } catch (e) {
      print('Error in fetchData: $e');
    } finally {
      _isFetchingData = false;
      notifyListeners();
    }
  }

  void setSelectedYesNoOption(String? value) {
    _selectedYesNoOption = value;
    notifyListeners();
  }

  void setSelectedDoneNoOption(String? value) {
    _selectedDoneNoOption = value;
    notifyListeners();
  }

  void setSelectedTrueFalseOption(String? value) {
    _selectedTrueFalseOption = value;
    notifyListeners();
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
      'radius': 0.25
    },
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
          print('Within predefined location: ${location['name']}');
          return true;
        }
      }
    }
    return false;
  }

  Future<void> saveHomeLocationToFirestore(
      Position position, String empCode) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('location').add({
        'home_latitude': position.latitude,
        'home_longitude': position.longitude,
        'isHomeLocationSet': true,
        'EmpCode': empCode,
      });
    } catch (e) {
      print('Error saving home location to Firestore: $e');
    }
  }

  Future<void> loadHomeLocationFromFirestore(String empCode) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('location')
          .where('EmpCode', isEqualTo: empCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming you want to get the first document found
        DocumentSnapshot doc = querySnapshot.docs.first;
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          double? latitude = data['home_latitude'];
          double? longitude = data['home_longitude'];
          _isHomeLocationSet = data['isHomeLocationSet'] ?? false;

          if (latitude != null && longitude != null) {
            _alternativeLocation = Position(
              latitude: latitude,
              longitude: longitude,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
            );
          }
        }
      }
    } catch (e) {
      print('Error loading home location from Firestore: $e');
    }
    notifyListeners();
  }

  Future<void> setHomeLocation(BuildContext context, String empCode) async {
    if (_currentUserPosition != null && !_isHomeLocationSet) {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text('Confirm Home Location'),
            content: Text('Do you want to set this as your home location?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Confirm'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      // If user confirms, set the home location
      if (confirm) {
        _alternativeLocation = _currentUserPosition;
        _isHomeLocationSet = true;

        await saveHomeLocationToFirestore(_currentUserPosition!, empCode);
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Home location saved successfully.'),
          ),
        );
      }
    }
  }

  bool isWithinAlternativeLocation() {
    if (_alternativeLocation != null && _currentUserPosition != null) {
      double distance = _calculateDistance(
          _alternativeLocation!.latitude,
          _alternativeLocation!.longitude,
          _currentUserPosition!.latitude,
          _currentUserPosition!.longitude);
      if (distance <= 0.1) {
        print('Within alternative location (home)');
        return true;
      }
    }
    return false;
  }

  void showLocationAlert(BuildContext context) {
    bool atPredefinedLocation = isWithinPredefinedLocation();
    bool atHomeLocation = _isHomeLocationSet && isWithinAlternativeLocation();

    print('atPredefinedLocation: $atPredefinedLocation');
    print('atHomeLocation: $atHomeLocation');
    print('currentUserPosition: $_currentUserPosition');
    print('alertShown: $_alertShown');

    if (!_alertShown &&
        !atPredefinedLocation &&
        !atHomeLocation &&
        _currentUserPosition != null) {
      _alertShown = true;
      notifyListeners();

      Fluttertoast.showToast(
        msg: "Please go to the station",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else if (!_alertShown && atHomeLocation) {
      _alertShown = true;
      notifyListeners();

      Fluttertoast.showToast(
        msg: "You are at home location",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
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
      if (locationName == null && _alternativeLocation != null) {
        double distance = _calculateDistance(
            _alternativeLocation!.latitude,
            _alternativeLocation!.longitude,
            _currentUserPosition!.latitude,
            _currentUserPosition!.longitude);
        if (distance <= 0.1) {
          // Acceptable radius for home location
          locationName = "Home";
        }
      }
    }
    return locationName ?? 'Out of station';
  }

  void resetAlertShown() {
    _alertShown = false;
    notifyListeners();
  }

  void resetDialogShown() {
    _alertShown = false;
    notifyListeners();
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
