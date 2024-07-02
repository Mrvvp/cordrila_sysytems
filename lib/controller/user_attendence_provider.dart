import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetail {
  final String employeeId;
  final String name;
  final DateTime date;
  final String? orders;
  final String? bags;
  final String? mop;
  final String? shipments;
  final String? pickups;
  final String? mfn;
  final String? time;
  final String? shift;
  final String? location;

  UserDetail({
    required this.employeeId,
    required this.name,
    required this.date,
    this.orders,
    this.bags,
    this.mop,
    this.shipments,
    this.pickups,
    this.mfn,
    this.time,
    this.shift,
    this.location,
  });
}

class AteendenceProvider extends ChangeNotifier {
  List<UserDetail> _userDataList = [];
  List<UserDetail> _filteredUserDataList = [];
  DateTime? _selectedDate;
  bool _isLoading = false;

  DateTime? get selectedDate => _selectedDate;
  List<UserDetail> get userDataList => _selectedDate == null ? _userDataList : _filteredUserDataList;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData(BuildContext context, {required String employeeId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      Query query = FirebaseFirestore.instance.collection('userdata').where('ID', isEqualTo: employeeId);
      query = query.orderBy('Date', descending: true);
      QuerySnapshot querySnapshot = await query.get();

      _userDataList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserDetail(
          employeeId: data['ID'].toString(),
          name: data['Name'].toString(),
          date: (data['Date'] as Timestamp).toDate(),
          orders: data['orders']?.toString(),
          bags: data['bags']?.toString(),
          mop: data['cash']?.toString(),
          shipments: data['shipment']?.toString(),
          pickups: data['pickup']?.toString(),
          mfn: data['mfn']?.toString(),
          time: data['Time']?.toString(),
          shift: data['shift']?.toString(),
          location: data['Location']?.toString(),
        );
      }).toList();

      if (_userDataList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No data available')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching user data: $e')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterUserDataByDate(DateTime filterDate) {
    _selectedDate = filterDate;
    DateTime startDate = DateTime(filterDate.year, filterDate.month, filterDate.day);
    DateTime endDate = DateTime(filterDate.year, filterDate.month, filterDate.day, 23, 59, 59);

    _filteredUserDataList = _userDataList.where((user) {
      return user.date.isAfter(startDate) && user.date.isBefore(endDate);
    }).toList();

    notifyListeners();
  }

  void clearFilter() {
    _selectedDate = null;
    _filteredUserDataList.clear();
    notifyListeners();
  }
}