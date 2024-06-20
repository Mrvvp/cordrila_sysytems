import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SigninpageProvider with ChangeNotifier {
  String? _selectedDropdownValue;
  String? get selectedDropdownValue => _selectedDropdownValue;

  bool _obscurePassword = true;
  Map<String, dynamic>? _userData;
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
  
  Future<void> fetchUserData(String userId) async {
    final url = 'https://cordrilladb.onrender.com/users/byEmpIC/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        _userData = json.decode(response.body);
        notifyListeners();
      } else {
        _handleErrorResponse(response);
      }
    } catch (error) {
      

      throw Exception('Failed to load user data');
    }
  }
  
  Future<bool> validatePassword(String userId, String password) async {
    await fetchUserData(userId);
    if (_userData != null && _userData!['Password'] == password) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> updatedData) async {
    final url = 'https://cordrilladb.onrender.com/users/byEmpIC/$userId';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        _userData = updatedData;
        notifyListeners();
      } else {
        _handleErrorResponse(response);
      }
    } catch (error) {
      
      throw Exception('Failed to update user data');
    }
  }

  Future<void> updatePassword(String userId, String newPassword) async {
    try {
      Map<String, dynamic> updatedData = {'Password': newPassword}; // Update only the password field
      await updateUserData(userId, updatedData);
    } catch (error) {
      
      throw Exception('Failed to update password');
    }
  }

  void _handleErrorResponse(http.Response response) {
    
    throw Exception(
        'Failed with status code: ${response.statusCode} - ${response.reasonPhrase}');
  }
    
    Future<void> saveUserData(String userId, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('password', password);
  }

  Future<bool> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? password = prefs.getString('password');
    if (userId != null && password != null) {
      // Validate the stored credentials
      return validatePassword(userId, password);
    }
    return false;
  }
  
 


  }
 


