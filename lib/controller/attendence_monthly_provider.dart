
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordrila_sysytems/controller/user_attendence_provider.dart';
import 'package:flutter/material.dart';

class AttendanceMonthlyProvider extends ChangeNotifier {
  List<UserDetail> _userDataList = [];
  List<UserDetail> _filteredUserDataList = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  DateTimeRange? get dateRange {
    if (_startDate != null && _endDate != null) {
      return DateTimeRange(start: _startDate!, end: _endDate!);
    }
    return null;
  }

  List<UserDetail> get userDataList =>
      _filteredUserDataList.isEmpty ? _userDataList : _filteredUserDataList;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData(
    BuildContext context, {
    required String employeeId,
    DateTime? startDate,
    DateTime? endDate, required DateTime date,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      Query query = FirebaseFirestore.instance
          .collection('userdata')
          .where('ID', isEqualTo: employeeId);

      if (startDate != null && endDate != null) {
        DateTime endOfDay =
            DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

        query = query
            .where('Date', isGreaterThanOrEqualTo: startDate)
            .where('Date', isLessThanOrEqualTo: endOfDay);
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

      // Update filtered list and notify listeners after fetching
      filterUserDataByDateRange();
      if (_filteredUserDataList.isEmpty) {
       
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    filterUserDataByDateRange();
    notifyListeners();
  }

  void filterUserDataByDateRange() {
    if (_startDate == null || _endDate == null) {
      _filteredUserDataList = [];
    } else {
      _filteredUserDataList = _userDataList.where((user) {
        final userDate = DateTime(user.date.year, user.date.month, user.date.day);
        return userDate.isAfter(_startDate!.subtract(Duration(days: 1))) &&
            userDate.isBefore(_endDate!.add(Duration(days: 1)));
      }).toList();
    }
    notifyListeners();
  }

  void clearFilter() {
    _filteredUserDataList = [];
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }
   
   }
