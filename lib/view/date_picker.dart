// import 'package:flutter/material.dart';
// import 'package:cordrila_sysytems/controller/user_attendence_provider.dart';
// import 'package:intl/intl.dart'; // Make sure to include this if needed for formatting

// class DateRangeSelector extends StatelessWidget {
//   final AteendenceProvider provider;

//   DateRangeSelector({required this.provider});

//   Future<void> _selectDateRange(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//       initialDateRange: DateTimeRange(
//         start: provider.selectedStartDate ?? DateTime.now(),
//         end: provider.selectedEndDate ?? DateTime.now(),
//       ),
//     );

//     if (picked != null) {
//       await provider.fetchUserDataByDateRange(
//         context,
//         employeeId: provider.employeeId,
//         startDate: picked.start,
//         endDate: picked.end,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select Date Range'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: () => _selectDateRange(context),
//               child: Text('Select Date Range'),
//             ),
//             // Your other UI components here
//           ],
//         ),
//       ),
//     );
//   }
// }
