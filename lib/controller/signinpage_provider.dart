import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigninpageProvider with ChangeNotifier {
  String? _selectedDropdownValue;
  String? get selectedDropdownValue => _selectedDropdownValue;

  bool _obscurePassword = true;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _cachedUserData;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  Map<String, dynamic>? get userData => _userData;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchUserData(String empCode) async {
    if (_cachedUserData != null) {
      _userData = _cachedUserData;
      notifyListeners();
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('USERS')
          .where('EmpCode', isEqualTo: empCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        _cachedUserData = _userData; // Cache the fetched user data
        notifyListeners();
      } else {
        throw Exception('User not found');
      }
    } catch (error) {
      print('Failed to load user data: $error');
      throw Exception('Failed to load user data: $error');
    }
  }

  Future<bool> validatePassword(String empCode, String password) async {
    try {
      if (_cachedUserData != null &&
          _cachedUserData!['EmpCode'] == empCode &&
          _cachedUserData!['Password'] == password) {
        _userData = _cachedUserData;
        return true;
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('USERS')
          .where('EmpCode', isEqualTo: empCode)
          .where('Password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User with matching empCode and password found
        _userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        _cachedUserData = _userData; // Cache the fetched user data
        return true;
      } else {
        // User not found or password doesn't match
        return false;
      }
    } catch (error) {
      print('Failed to validate password: $error');
      throw Exception('Failed to validate password: $error');
    }
  }

  Future<void> updateUserData(
      String empCode, Map<String, dynamic> updatedData) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('USERS')
          .where('EmpCode', isEqualTo: empCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('USERS')
            .doc(docId)
            .update(updatedData);
        _userData = updatedData;
        _cachedUserData = updatedData; // Update the cached user data
        notifyListeners();
      } else {
        throw Exception('User not found');
      }
    } catch (error) {
      print('Failed to update user data: $error');
      throw Exception('Failed to update user data: $error');
    }
  }

  Future<void> updatePassword(String empCode, String newPassword) async {
    try {
      Map<String, dynamic> updatedData = {'Password': newPassword};
      await updateUserData(empCode, updatedData);
    } catch (error) {
      print('Failed to update password: $error');
      throw Exception('Failed to update password: $error');
    }
  }

  Future<void> saveUserData(String empCode, String password) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('EmpCode', empCode);
      await prefs.setString('Password', password);
    } catch (error) {
      print('Failed to save user data: $error');
      throw Exception('Failed to save user data: $error');
    }
  }

  Future<bool> loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? empCode = prefs.getString('EmpCodee');
      String? password = prefs.getString('Password');
      if (empCode != null && password != null) {
        return validatePassword(empCode, password);
      }
      return false;
    } catch (error) {
      print('Failed to load user data: $error');
      throw Exception('Failed to load user data: $error');
    }
  }

  dynamic _lastLoggedInTime;
  dynamic get lastLoggedInTime => _lastLoggedInTime;

  Future<void> saveLastLoggedInTime() async {
    try {
      DateTime ntpTime = await NTP.now(); // Fetch NTP time
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String formattedDateTime =
          DateFormat('yyyy-MM-dd hh:mm a').format(ntpTime);
      await prefs.setString('last_logged_in_time', formattedDateTime);
      _lastLoggedInTime = formattedDateTime;
      notifyListeners();
    } catch (error) {
      print('Failed to save last logged-in time: $error');
      throw Exception('Failed to save last logged-in time: $error');
    }
  }

  Future<void> loadLastLoggedInTime() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _lastLoggedInTime = prefs.getString('last_logged_in_time');
      notifyListeners();
    } catch (error) {
      print('Failed to load last logged-in time: $error');
      throw Exception('Failed to load last logged-in time: $error');
    }
  }

  Future<void> saveLastLoggedInTimeToFirebase(String empCode) async {
    try {
      DateTime ntpTime = await NTP.now(); // Fetch NTP time
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('userdata')
          .where('EmpCode', isEqualTo: empCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('userdata')
            .doc(docId)
            .update({'lastLoggedInTime': Timestamp.fromDate(ntpTime)});
        _lastLoggedInTime = ntpTime;
        notifyListeners();
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Failed to save last logged-in time: $e');
      throw Exception('Failed to save last logged-in time: $e');
    }
  }

  Future<void> fetchLastLoggedInTimeFromFirebase(String empCode) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('userdata')
          .where('EmpCode', isEqualTo: empCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docData =
            querySnapshot.docs.first.data() as Map<String, dynamic>?;
        if (docData != null && docData.containsKey('lastLoggedInTime')) {
          final timestamp = docData['lastLoggedInTime'] as Timestamp?;
          _lastLoggedInTime = timestamp?.toDate() ?? DateTime.now();
          notifyListeners();
        } else {
          _lastLoggedInTime = DateTime.now();
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Failed to fetch last logged-in time: $e');
      throw Exception('Failed to fetch last logged-in time: $e');
    }
  }
}
