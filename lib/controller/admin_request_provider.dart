import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRequestProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get requests => _requests;
  List<Map<String, dynamic>> get filteredRequests => _filteredRequests;
  bool get isLoading => _isLoading;

  // Method to fetch requests
  Future<void> fetchRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('requests')
          .orderBy('timestamp', descending: true)
          .get();

      _requests = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Store document ID for deletion
        return data;
      }).toList();

      _filteredRequests = _requests;
    } catch (e) {
      print("Error fetching requests: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to filter requests
  void filterRequests(String query) {
    if (query.isEmpty) {
      _filteredRequests = _requests;
    } else {
      _filteredRequests = _requests
          .where((request) => request['userId'].toString().contains(query))
          .toList();
    }
    notifyListeners();
  }

    Future<void> sendReply(String requestId, String reply) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({'reply': reply});
      fetchRequests(); // Refresh data
    } catch (e) {
      print('Error sending reply: $e');
    }
  }

  // Method to delete a request
  Future<void> deleteRequest(String id) async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(id).delete();
      _requests.removeWhere((request) => request['id'] == id);
      _filteredRequests.removeWhere((request) => request['id'] == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting request: $e");
    }
  }

  // Method to get the count of requests
  int get requestCount => _requests.length;
}
