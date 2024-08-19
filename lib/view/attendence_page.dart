import 'package:cordrila_sysytems/controller/attendence_monthly_provider.dart';
import 'package:cordrila_sysytems/controller/user_attendence_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class AttendencePage extends StatefulWidget {
  final String employeeId;

  const AttendencePage({Key? key, required this.employeeId}) : super(key: key);

  @override
  _AttendencePageState createState() => _AttendencePageState();
}

class _AttendencePageState extends State<AttendencePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AteendenceProvider _attendanceProvider;
  DateTime _selectedDate = DateTime.now(); // Initialize directly here

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this); // Initialize TabController with 2 tabs

    _attendanceProvider = context.read<AteendenceProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attendanceProvider.fetchUserData(context,
          employeeId: widget.employeeId, date: _selectedDate);
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose of the TabController
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Ensure provider is initialized before calling methods
      await _attendanceProvider.fetchUserData(context,
          employeeId: widget.employeeId, date: _selectedDate);
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final AttendanceMonthlyProvider provider =
        Provider.of<AttendanceMonthlyProvider>(context, listen: false);

    final DateTimeRange? selectedRange = await showDateRangePicker(
      context: context,
      initialDateRange: provider.dateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(Duration(days: 1)),
            end: DateTime.now(),
          ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedRange != null) {
      // Set the date range in the provider
      provider.setDateRange(selectedRange.start, selectedRange.end);

      // Fetch data for the selected date range
      await provider.fetchUserData(
        context,
        employeeId: widget.employeeId,
        startDate: selectedRange.start,
        endDate: selectedRange.end,
        date: DateTime.now(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Attendance',style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),),
        bottom: TabBar(
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          controller: _tabController,
          tabs: [
            Tab(text: 'Daily'),
            Tab( text: 'Custom',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Daily view
          Consumer<AteendenceProvider>(
            builder: (context, attendanceProvider, child) {
              return RefreshIndicator(
                onRefresh: () async {
                  attendanceProvider.clearFilter();
                  await attendanceProvider.fetchUserData(context,
                      employeeId: widget.employeeId, date: _selectedDate);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () => _selectDate(context),
                          icon: Image.asset('assets/images/calendar.png',
                              width: 40),
                        ),
                      Expanded(
                        child: attendanceProvider.isLoading
                            ? Center(
                                child: Lottie.asset(
                                    'assets/animations/Animation - 1722594040196.json',
                                    fit: BoxFit.contain))
                            : attendanceProvider.userDataList.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('No attendance data available!',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        Lottie.asset(
                                            'assets/animations/Animation - 1722593381652.json',
                                            width: 200,
                                            fit: BoxFit.contain),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount:
                                        attendanceProvider.userDataList.length,
                                    itemBuilder: (context, index) {
                                      final user = attendanceProvider
                                          .userDataList[index];
                                      return Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black45),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              blurRadius: 3,
                                              offset: const Offset(3, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('${user.name}',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                            Row(
                                              children: [
                                                Text(
                                                    'Date: ${DateFormat('yyyy-MM-dd hh:mm a').format(user.date)}',
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                              ],
                                            ),
                                            Text('Location: ${user.location}',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            if (user.shipments != null ||
                                                user.pickups != null ||
                                                user.mfn != null) ...[
                                              Text(
                                                  'Shipments: ${user.shipments}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              Text('Pickup: ${user.pickups}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              Text('MFN: ${user.mfn}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              Text('Shift: ${user.shift}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              Text('LM Read: ${user.lm}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              Text('Helmet: ${user.helmet}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              Text('Cash: ${user.cash}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                            ] else if (user.orders != null ||
                                                user.bags != null ||
                                                user.mop != null) ...[
                                              Text('Orders: ${user.orders}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              Text('Bags: ${user.bags}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              Text('Cash: ${user.mop}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              Text('Slot: ${user.time}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                              Text('GSF: ${user.gsf}',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                            ]
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Consumer<AttendanceMonthlyProvider>(
            builder: (context, _attendanceMonthlyProvider, child) {
              return RefreshIndicator(
                  onRefresh: () async {
                    _attendanceMonthlyProvider.clearFilter();
                    await _attendanceMonthlyProvider.fetchUserData(
                      context,
                      employeeId: widget.employeeId,
                      date: DateTime.now(),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => _selectDateRange(context),
                          icon: Image.asset('assets/images/calendar.png',
                              width: 40),
                        ),
                        Expanded(
                          child: _attendanceMonthlyProvider.isLoading
                              ? Center(
                                  child: Lottie.asset(
                                      'assets/animations/Animation - 1722594040196.json',
                                      fit: BoxFit.contain))
                              : _attendanceMonthlyProvider.userDataList.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('No attendance data available!',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins')),
                                          Lottie.asset(
                                              'assets/animations/Animation - 1722593381652.json',
                                              width: 200,
                                              fit: BoxFit.contain),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _attendanceMonthlyProvider
                                          .userDataList.length,
                                      itemBuilder: (context, index) {
                                        final user = _attendanceMonthlyProvider
                                            .userDataList[index];
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black45),
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                blurRadius: 3,
                                                spreadRadius: 3,
                                                offset: const Offset(3, 3),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${user.name}',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Date: ${DateFormat('yyyy-MM-dd hh:mm a').format(user.date)}',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                'Location: ${user.location}',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              if (user.shipments != null ||
                                                  user.pickups != null ||
                                                  user.mfn != null) ...[
                                                Text(
                                                  'Shipments: ${user.shipments}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Pickup: ${user.pickups}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'MFN: ${user.mfn}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Shift: ${user.shift}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'LM Read: ${user.lm}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Helmet: ${user.helmet}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Cash: ${user.cash}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ] else if (user.orders != null ||
                                                  user.bags != null ||
                                                  user.mop != null) ...[
                                                Text(
                                                  'Orders: ${user.orders}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Bags: ${user.bags}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Cash: ${user.mop}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Slot: ${user.time}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'GSF: ${user.gsf}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ));
            },
          ),
        ],
      ),
    );
  }
}
