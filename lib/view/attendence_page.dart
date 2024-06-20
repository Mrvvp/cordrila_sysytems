import 'package:cordrila_sysytems/controller/user_attendence_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AttendencePage extends StatefulWidget {
  final String employeeId;

  const AttendencePage({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<AttendencePage> createState() => _AttendencePageState();
}

class _AttendencePageState extends State<AttendencePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AteendenceProvider>().fetchUserData(context, employeeId: widget.employeeId);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: context.read<AteendenceProvider>().selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      context.read<AteendenceProvider>().filterUserDataByDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AteendenceProvider>(
        builder: (context, attendanceProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              attendanceProvider.clearFilter();
              await attendanceProvider.fetchUserData(context, employeeId: widget.employeeId);
            },
            child: attendanceProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blue,),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              IconButton(
                                  iconSize: 35,
                                  color: Colors.black,
                                  icon: Icon(Icons.arrow_back),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                              SizedBox(
                                width: 10,
                              ),
                              const Text(
                                'Attendance',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              IconButton(
                                iconSize: 35,
                                color: Colors.black,
                                icon: const Icon(CupertinoIcons.calendar),
                                onPressed: () => _selectDate(context),
                              ),
                            ],
                          ),
                          if (attendanceProvider.userDataList.isEmpty)
                            Center(child: const Text('No data available')),
                          if (attendanceProvider.userDataList.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: attendanceProvider
                                            .userDataList.length,
                                        itemBuilder: (context, index) {
                                          final user = attendanceProvider
                                              .userDataList[index];
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Name: ${user.name}',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .black)),
                                                Text(
                                                    'Date: ${DateFormat('yyyy-MM-dd hh:mm a').format(user.date)}',
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                                        Text(
                                                    'Location: ${user.location}',
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                                if (user.shipments != null ||
                                                    user.pickups != null ||
                                                    user.mfn != null) ...[
                                                  Text(
                                                      'Shipments: ${user.shipments}',
                                                      style: const TextStyle(
                                                          color: Colors.black)),
                                                  Text(
                                                      'Pickup: ${user.pickups}',
                                                      style: const TextStyle(
                                                          color: Colors.black)),
                                                  Text('MFN: ${user.mfn}',
                                                      style: const TextStyle(
                                                          color: Colors.black)),
                                                  Text('Shift: ${user.shift}',
                                                      style: const TextStyle(
                                                          color: Colors.black)),
                                                ] else if (user.orders !=
                                                        null ||
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
                                                  Text('Time: ${user.time}',
                                                      style: const TextStyle(
                                                          color: Colors.black)),
                                                         
                                                ],
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
