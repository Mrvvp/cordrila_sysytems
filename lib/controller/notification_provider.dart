import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RepliesProvider with ChangeNotifier {
  int _replyCount = 0;

  int get replyCount => _replyCount;

  Future<void> fetchReplies(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('userId', isEqualTo: userId)
          .where('reply', isNotEqualTo: null)
          .get();

      _replyCount = querySnapshot.docs.length;
      notifyListeners();
    } catch (e) {
      print('Error fetching replies: $e');
      // Handle error as needed
    }
  }
}
