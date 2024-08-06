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
  final String? gsf;
  final String? helmet;
  final String? lm;
  final String? cash;

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
    this.gsf,
    this.helmet,
    this.lm,
    this.cash,
  });
}

class AteendenceProvider extends ChangeNotifier {
  List<UserDetail> _userDataList = [];
  List<UserDetail> _filteredUserDataList = [];
  DateTime? _selectedDate;
  bool _isLoading = false;

  DateTime? get selectedDate => _selectedDate;
  List<UserDetail> get userDataList => _filteredUserDataList.isEmpty ? _userDataList : _filteredUserDataList;
  bool get isLoading => _isLoading;

 Future<void> fetchUserData(BuildContext context, {required String employeeId, DateTime? date}) async {
  _isLoading = true;
  notifyListeners();

  try {
    Query query = FirebaseFirestore.instance.collection('userdata').where('ID', isEqualTo: employeeId);

    if (date != null) {
      // Filter data by the provided date
      DateTime startDate = DateTime(date.year, date.month, date.day);
      DateTime endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
      query = query.where('Date', isGreaterThanOrEqualTo: startDate).where('Date', isLessThanOrEqualTo: endDate);
    }

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
        gsf: data['GSF']?.toString(),
        helmet: data['Helmet Adherence']?.toString(),
        lm: data['LM Read']?.toString(),
        cash: data['Cash Submitted']?.toString(),
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


  void filterUserDataByDateRange(DateTime startDate, DateTime endDate) {
    _filteredUserDataList = _userDataList.where((user) {
      final userDate = DateTime(user.date.year, user.date.month, user.date.day);
      return userDate.isAfter(startDate) && userDate.isBefore(endDate);
    }).toList();
    notifyListeners();
  }

  void clearFilter() {
    _filteredUserDataList = [];
    notifyListeners();
  }
}
