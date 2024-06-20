

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AdminFreshProvider with ChangeNotifier {
  int _currentPage = 1;
  final int _itemsPerPage = 300;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  List<DocumentSnapshot> getPaginatedDocuments(List<DocumentSnapshot> documents) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage).clamp(0, documents.length);
    return documents.sublist(startIndex, endIndex);
  }
}