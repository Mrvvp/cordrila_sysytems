import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilepageProvider extends ChangeNotifier {
  Map<String, dynamic>? userData;

  // Method to set user data
  void setUserData(Map<String, dynamic> data) {
    userData = data;
    notifyListeners();
  }

  // Method to send update request to Firebase
  Future<void> sendUpdateRequest(String userId, String updateRequest, String name) async {
    await FirebaseFirestore.instance.collection('requests').add({
      'userId': userId,
      'request': updateRequest,
      'timestamp': FieldValue.serverTimestamp(),
      'name': name,
    });
  }
}
