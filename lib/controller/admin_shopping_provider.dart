import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum FilterType { daily, weekly, monthly }

class AdminShoppingProvider with ChangeNotifier {
  int _currentPage = 1;
  final int _itemsPerPage = 300;
  FilterType _filterType = FilterType.daily;
  List<DocumentSnapshot> _filteredDocuments = [];

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  FilterType get filterType => _filterType;
  List<DocumentSnapshot> get filteredDocuments => _filteredDocuments;

  void setCurrentPage(int page) {
    if (page != _currentPage) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void setFilterType(FilterType type) {
    if (type != _filterType) {
      _filterType = type;
      notifyListeners();
    }
  }

  void setFilteredDocuments(List<DocumentSnapshot> documents) {
    if (documents != _filteredDocuments) {
      _filteredDocuments = documents;
      notifyListeners();
    }
  }

  List<DocumentSnapshot> getPaginatedDocuments() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage).clamp(0, _filteredDocuments.length);
    return _filteredDocuments.sublist(startIndex, endIndex);
  }
}
