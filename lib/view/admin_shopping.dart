import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ShoppingFilterProvider extends ChangeNotifier {
  int selectedIndex = 0;
  DateTime? selectedDate;
  DateTime? selectedMonth;

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void setDate(DateTime? date) {
    selectedDate = date;
    notifyListeners();
  }

  void setMonth(DateTime? month) {
    selectedMonth = month;
    notifyListeners();
  }
}

class AdminShoppingPage extends StatefulWidget {
  const AdminShoppingPage({super.key});

  @override
  _AdminShoppingPageState createState() => _AdminShoppingPageState();
}

class _AdminShoppingPageState extends State<AdminShoppingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<ShoppingFilterProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Shopping',
          style: TextStyle(fontSize: 20, fontFamily: "Poppins"),
        ),
        toolbarHeight: 55,
        backgroundColor: Colors.grey.shade200,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton(context, 0, 'All'),
              _buildTabButton(context, 1, 'Daily'),
              _buildTabButton(context, 2, 'Monthly'),
            ],
          ),
        ),
      ),
      floatingActionButton: filterProvider.selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await _downloadAllData(context);
              },
              backgroundColor: Colors.blue,
              child: const Icon(
                Icons.download,
                color: Colors.white,
              ),
            )
          : null,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildTabContent(context),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: filterProvider.selectedIndex == 1
                ? _buildDateButton(context)
                : filterProvider.selectedIndex == 2
                    ? _buildMonthPickerButton(context)
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, int index, String text) {
    final filterProvider =
        Provider.of<ShoppingFilterProvider>(context, listen: false);
    return TextButton(
      onPressed: () {
        // Set the selected index
        filterProvider.setIndex(index);

        // Reset selected date when switching tabs
        filterProvider.setDate(null);

        // Reset selected month when switching to the Daily tab
        if (index == 1) {
          filterProvider.setMonth(null);
        }
      },
      child: Text(
        text,
        style: TextStyle(
          color: filterProvider.selectedIndex == index
              ? Colors.black
              : Colors.grey,
          fontWeight: filterProvider.selectedIndex == index
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    final filterProvider = Provider.of<ShoppingFilterProvider>(context);
    switch (filterProvider.selectedIndex) {
      case 0:
        return _buildAllDataTab(context);
      case 1:
        return filterProvider.selectedDate == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(
                          "assets/images/photo_2024-06-10_13-36-27.jpg"),
                      radius: 50,
                      // Customize as needed
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Select a date!', // Customize text as needed
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : _buildDailyDataTab(context);

      case 2:
        return filterProvider.selectedDate == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(
                          "assets/images/photo_2024-06-10_13-36-27.jpg"),
                      radius: 50,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Select a date!', // Customize text as needed
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : _buildMonthlyDataTab(context);

      default:
        return const Center(child: Text('Monthly Data'));
    }
  }

  Widget _buildAllDataTab(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('userdata')
          .where('mfn', isNotEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final documents = snapshot.data!.docs;
        return ListView.separated(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final employeedata =
                documents[index].data() as Map<String, dynamic>;
            return _buildListItem(employeedata);
          },
          separatorBuilder: (BuildContext context, int index) => Divider(),
        );
      },
    );
  }

  Widget _buildListItem(Map<String, dynamic> employeedata) {
    List<Widget> _buildEmployeeDetails(Map<String, dynamic> data) {
      List<Widget> details = [
        Text(
          '${data['ID']}',
          style: const TextStyle(
              fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
        ),
       
        Text(
          '${data['Name']}',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ),
        Text(
          'Location:${data['Location']}',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ),
         Text(
          'Date: ${_extractDate(data['Date'])}',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ),
      ];

      if (data['shift'] != null && data['shift'].toString().isNotEmpty) {
        details.add(Text(
          'Shift: ${data['shift']}',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ));
      }
      if (data['pickup'] != null && data['pickup'].toString().isNotEmpty) {
        details.add(Text(
          'Pickup: ${data['pickup']}',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ));
      }
      if (data['shipment'] != null && data['shipment'].toString().isNotEmpty) {
        details.add(Text(
          'Shipment: ${data['shipment']}',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ));
      }
      if (data['mfn'] != null && data['mfn'].toString().isNotEmpty) {
        details.add(Text(
          'mfn: ${data['mfn']}',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ));
      }

      return details;
    }

    return ListTile(
      title: Padding(
        padding: EdgeInsets.only(left: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildEmployeeDetails(employeedata),
        ),
      ),
    );
  }

  Widget _buildDailyDataTab(BuildContext context) {
    final filterProvider = Provider.of<ShoppingFilterProvider>(context);
    final DateTime? selectedDate = filterProvider.selectedDate;
    if (selectedDate == null) {
      return const SizedBox.shrink();
    }

    final DateTime startOfDay = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
    final DateTime endOfDay = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('userdata')
                .where('Date', isGreaterThanOrEqualTo: startOfDay)
                .where('Date', isLessThanOrEqualTo: endOfDay)
                .where('mfn', isNotEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              final documents = snapshot.data!.docs;
              if (documents.isEmpty) {
                return const Center(
                  child: Text('No data found for the selected date.'),
                );
              }
              return ListView.separated(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final employeedata =
                      documents[index].data() as Map<String, dynamic>;
                  return _buildListItem(employeedata);
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 250, bottom: 10),
          child: TextButton(
            onPressed: () async {
              _downloadDailyData(context);
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download, color: Colors.blue), // Download icon
                SizedBox(
                    width: 8), // Add some space between the icon and the text
                Text(
                  'Download',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton(BuildContext context) {
    final filterProvider = Provider.of<ShoppingFilterProvider>(context);
    final dateFormat = DateFormat('dd-MM-yyyy');
    final formattedDate = filterProvider.selectedDate == null
        ? 'Select Date'
        : dateFormat.format(filterProvider.selectedDate!);

    return TextButton.icon(
      onPressed: () => _pickDate(context),
      icon: const Icon(
        Icons.calendar_today,
        color: Colors.black,
      ),
      label: Text(
        formattedDate,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildMonthPickerButton(BuildContext context) {
    final filterProvider = Provider.of<ShoppingFilterProvider>(context);
    final dateFormat = DateFormat('MMMM yyyy');
    final formattedDate = filterProvider.selectedDate == null
        ? 'Select Month'
        : dateFormat.format(filterProvider.selectedDate!);

    return TextButton.icon(
      onPressed: () => _pickMonth(context),
      icon: const Icon(
        Icons.calendar_today,
        color: Colors.black,
      ),
      label: Text(
        formattedDate,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final filterProvider =
        Provider.of<ShoppingFilterProvider>(context, listen: false);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: filterProvider.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Theme(
            data: Theme.of(context).copyWith(
              appBarTheme: const AppBarTheme(foregroundColor: Colors.yellow),
              colorScheme: const ColorScheme.dark(
                brightness: Brightness.light,
                surface: Colors.white,
                primary: Colors.black, // header background color
                onPrimary: Colors.white, // header text color
                onSurface: Colors.black, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(
                      bottom: 5, left: 5, right: 5, top: 5),
                  foregroundColor: Colors.black,
                  // OK button background color// button text color
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (pickedDate != null && pickedDate != filterProvider.selectedDate) {
      filterProvider.setDate(pickedDate);
    }
  }

  Future<void> _pickMonth(BuildContext context) async {
    final filterProvider =
        Provider.of<ShoppingFilterProvider>(context, listen: false);

    final DateTime? pickedDate = await showMonthPicker(
      context: context,
      initialDate: filterProvider.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != filterProvider.selectedDate) {
      // Reset selected date to null
      filterProvider.setDate(null);
      filterProvider.setDate(pickedDate);
    }
  }

  String _extractDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }

  Future<void> _downloadDailyData(BuildContext context) async {
    try {
      final filterProvider =
          Provider.of<ShoppingFilterProvider>(context, listen: false);
      final List<List<dynamic>> rows = [];

      final DateTime? selectedDate = filterProvider.selectedDate;
      if (selectedDate == null) {
        return;
      }

      final DateTime startOfDay = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
      final DateTime endOfDay = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

      final snapshot = await FirebaseFirestore.instance
          .collection('userdata')
          .where('Date', isGreaterThanOrEqualTo: startOfDay)
          .where('Date', isLessThanOrEqualTo: endOfDay)
          .get();

      if (snapshot.docs.isEmpty) {
        _showAlertDialog(
            context, 'No Data Found', 'No data found for selected date.');
        return;
      }

      for (final doc in snapshot.docs) {
        final employeedata = doc.data();
        final row = [
          employeedata['ID'],
          employeedata['Name'],
          employeedata['Location'],
          _extractDate(employeedata['Date']),
          employeedata['shift'],
          employeedata['pickup'],
          employeedata['shipment'],
          employeedata['mfn'],
        ];
        rows.add(row);
      }

      await _downloadCSV(context, rows, 'shopping_daily_data');
    } catch (e) {
      print('Error downloading data: $e');
    }
  }

  Future<void> _downloadCSV(
      BuildContext context, List<List<dynamic>> rows, String fileName) async {
    try {
      test();

      // Define CSV headings
      List<dynamic> headings = [
        'ID',
        'Name',
        'Location',
        'Date',
        'shift',
        'shipment',
        'pickup',
        'mfn'
      ];

      // Add headings as the first row in the CSV
      rows.insert(0, headings);

      final String csv = const ListToCsvConverter().convert(rows);

      // Define the download directory
      const String downloadDirectory = '/storage/emulated/0/Download';
      // Define the file path
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String uniqueFileName = '$fileName $timestamp.csv';
      final String filePath = '$downloadDirectory/$uniqueFileName';

      // Write the CSV file
      final File file = File(filePath);
      await file.writeAsString(csv);

      _showAlertDialog(
        context,
        'Success',
        'CSV file downloaded successfully',
        success: true,
      );
    } catch (e) {
      print('Error downloading CSV: $e');
      _showAlertDialog(context, 'Error', 'Error downloading CSV');
    }
  }

  Future<void> _downloadAllData(BuildContext context) async {
    try {
      final List<List<dynamic>> rows = [];

      final snapshot = await FirebaseFirestore.instance
          .collection('userdata')
          .where('mfn', isNotEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) {
        _showAlertDialog(
            context, 'No Data Found', 'No data found in the database.');
        return;
      }

      for (final doc in snapshot.docs) {
        final employeedata = doc.data();
        final row = [
          employeedata['ID'],
          employeedata['Name'],
          employeedata['Location'],
          _extractDate(employeedata['Date']),
          employeedata['shift'],
          employeedata['pickup'],
          employeedata['shipment'],
          employeedata['mfn'],
        ];
        rows.add(row);
      }

      await _downloadCSV(context, rows, 'shopping_all_data');
    } catch (e) {
      print('Error downloading all data: $e');
    }
  }

  Widget _buildMonthlyDataTab(BuildContext context) {
    final filterProvider = Provider.of<ShoppingFilterProvider>(context);
    final DateTime? selectedDate = filterProvider.selectedDate;
    if (selectedDate == null) {
      return const SizedBox.shrink();
    }

    final DateTime startOfMonth =
        DateTime(selectedDate.year, selectedDate.month);
    final DateTime endOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('userdata')
                .where('Date', isGreaterThanOrEqualTo: startOfMonth)
                .where('Date', isLessThanOrEqualTo: endOfMonth)
                .where('mfn', isNotEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              final documents = snapshot.data!.docs;
              if (documents.isEmpty) {
                return const Center(
                  child: Text('No data found for the selected month.'),
                );
              }
              return ListView.separated(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final employeedata =
                      documents[index].data() as Map<String, dynamic>;
                  return _buildListItem(employeedata);
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 250, bottom: 10),
          child: TextButton(
            onPressed: () async {
              _downloadMonthlyData(context, startOfMonth);
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download, color: Colors.blue), // Download icon
                SizedBox(
                    width: 8), // Add some space between the icon and the text
                Text(
                  'Download',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadMonthlyData(
      BuildContext context, DateTime month) async {
    try {
      Provider.of<ShoppingFilterProvider>(context, listen: false);
      final List<List<dynamic>> rows = [];

      final DateTime startOfMonth = DateTime(month.year, month.month, 1);
      final DateTime endOfMonth = DateTime(month.year, month.month + 1, 0);

      final snapshot = await FirebaseFirestore.instance
          .collection('userdata')
          .where('Date', isGreaterThanOrEqualTo: startOfMonth)
          .where('Date', isLessThanOrEqualTo: endOfMonth)
          .get();

      if (snapshot.docs.isEmpty) {
        _showAlertDialog(
            context, 'No Data Found', 'No data found for the selected month.');
        return;
      }

      for (final doc in snapshot.docs) {
        final employeedata = doc.data();
        final row = [
          employeedata['ID'],
          employeedata['Name'],
          employeedata['Location'],
          _extractDate(employeedata['Date']),
          employeedata['shift'],
          employeedata['pickup'],
          employeedata['shipment'],
          employeedata['mfn'],
        ];
        rows.add(row);
      }

      final formattedMonth = DateFormat('yyyy_MM').format(month);
      await _downloadCSV(context, rows, 'monthly_data_$formattedMonth');
    } catch (e) {
      print('Error downloading monthly data: $e');
    }
  }

  void _showAlertDialog(BuildContext context, String title, String message,
      {bool success = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (success)
                CircleAvatar(
                    radius: 30,
                    child: Image.asset(
                      'assets/images/checked.png',
                    )),
              SizedBox(
                height: 20,
              ),
              Text(message),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void test() async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    final storageStatus = android.version.sdkInt < 34
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (storageStatus == PermissionStatus.granted) {
      print("granted");
    }
    if (storageStatus == PermissionStatus.denied) {
      print("denied");
    }
    if (storageStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }
}
