import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProvider with ChangeNotifier {
  int _notificationCount = 0;

  int get notificationCount => _notificationCount;

  // Method to check for new replies
  void checkForNewReplies(String userId) {
    FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .where('reply', isNotEqualTo: null)
        .where('reply', isNotEqualTo: '')
        .where('read', isNotEqualTo: true) // Assuming you have a 'read' field
        .snapshots()
        .listen((snapshot) {
      _notificationCount = snapshot.docs.length;
      notifyListeners();
    });
  }

  // Method to reset notification count
  void resetNotificationCount() {
    _notificationCount = 0;
    notifyListeners();
  }
}
