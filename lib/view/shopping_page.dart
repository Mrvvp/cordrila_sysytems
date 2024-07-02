import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordrila_sysytems/controller/shopping_page_provider.dart';
import 'package:cordrila_sysytems/view/attendence_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:cordrila_sysytems/view/profilepage.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('userdata');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _shipmentController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _mfnController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    _initializeLocation();
    _initializeLastLoggedInTime();
    super.initState();
  }

  void _initializeLastLoggedInTime() async {
    final signinProvider = Provider.of<SigninpageProvider>(context, listen: false);
    await signinProvider.loadLastLoggedInTime();
  }

  void _initializeLocation() async {
    final provider = Provider.of<ShoppingPageProvider>(context, listen: false);
    await provider.initializeData();
    _locationController.text = provider.getLocationName();
  }

  void _clearShoppingFields() {
    _pickupController.clear();
    _shipmentController.clear();
    _mfnController.clear();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _shipmentController.dispose();
    _mfnController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData = Provider.of<SigninpageProvider>(context).userData;
    if (userData != null) {
      _nameController.text = userData['Employee Name'] ?? '';
      _idController.text = userData['Emp/IC Code'] ?? '';
    }
  }

  Future<void> _refreshData() async {
    Provider.of<ShoppingPageProvider>(context, listen: false).initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final appStateProvider = Provider.of<ShoppingPageProvider>(context);
    final signinpageProvider = Provider.of<SigninpageProvider>(context);
    void addDetails() async {
      try {
        final data = {
          'shift': appStateProvider.selectedTimeSlot,
          'shipment': _shipmentController.text,
          'pickup': _pickupController.text,
          'mfn': _mfnController.text,
          'ID': _idController.text,
          'Name': _nameController.text,
          'Date': appStateProvider.timestamp,
          'Location': _locationController.text,
          'Login': signinpageProvider.lastLoggedInTime ?? '',
        };
        await users.add(data);
        Fluttertoast.showToast(
            msg: "Attendence Marked",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Attendence not Marked",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isWithinWarehouse = appStateProvider.isWithinPredefinedLocation();
      bool dialogShown = appStateProvider.alertShown;

      // print('isWithinWarehouse: $isWithinWarehouse');
      // print('dialogShown: $dialogShown');

      if (!isWithinWarehouse && !dialogShown) {
        // print('Showing dialog');
        appStateProvider.showLocationAlert(context);
      } else if (isWithinWarehouse && dialogShown) {
        // print('Hiding dialog');
        // appStateProvider.resetDialogShown();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: appStateProvider.isFetchingData
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 50, right: 15, left: 15, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Welcome',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfilePage()));
                                },
                                icon: const Icon(
                                    CupertinoIcons.profile_circled,
                                    color: Colors.black,
                                    size: 40)),
                            IconButton(
                                onPressed: () {
                                  String employeeId = _idController.text;
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AttendencePage(
                                                employeeId: employeeId,
                                              )));
                                },
                                icon: const Icon(
                                  CupertinoIcons.calendar,
                                  color: Colors.black,
                                  size: 40,
                                )),
                          ],
                        ),
                        Text(
                                'Logged In: ${signinpageProvider.lastLoggedInTime ?? 'No data available'}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 10),
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Name :',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _nameController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
                                enabled: false,
                                prefixIcon: Icon(
                                  CupertinoIcons.profile_circled,
                                  color: Colors.grey.shade500,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Employee ID :',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _idController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
                                enabled: false,
                                prefixIcon: Icon(
                                  CupertinoIcons.number,
                                  color: Colors.grey.shade500,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Date :',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: appStateProvider.timedateController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
                                enabled: false,
                                prefixIcon: Icon(
                                  CupertinoIcons.calendar,
                                  color: Colors.grey.shade500,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Location :',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _locationController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
                                enabled: false,
                                prefixIcon: Icon(
                                  CupertinoIcons.location,
                                  color: Colors.grey.shade500,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Shift :',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              child: DropdownButtonFormField<String>(
                                value: appStateProvider.selectedTimeSlot,
                                decoration: InputDecoration(
                                  hintText: 'Select shift',
                                   hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: appStateProvider.timeSlots
                                    .map((String timeSlot) {
                                  bool isDisabled = appStateProvider
                                          .disabledTimeSlots
                                          .contains(timeSlot) ||
                                      appStateProvider
                                          .isTimeSlotSelectedForToday(timeSlot);
                                  return DropdownMenuItem<String>(
                                    value: timeSlot,
                                    child: Text(
                                      timeSlot,
                                      style: TextStyle(
                                        color: isDisabled
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                    enabled: !isDisabled,
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  if (newValue != null) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          title: Text("Confirm Attendance"),
                                          content: Text(
                                              "Are you sure you want to mark attendance for $newValue?"),
                                          actions: [
                                            TextButton(
                                              child: Text("Cancel"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Confirm"),
                                              onPressed: () {
                                                appStateProvider
                                                    .setSelectedTimeSlot(
                                                        newValue);
                                                appStateProvider
                                                    .markAttendance();
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                isExpanded: true,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'No.of.Shipments Delivered :',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _shipmentController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
                                prefixIcon: Icon(
                                  CupertinoIcons.cube_box,
                                  color: Colors.grey.shade500,
                                ),
                                hintText: 'Enter no.of.Shipments',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'No.of.Pickup Done :',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _pickupController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
                                prefixIcon: Icon(
                                  CupertinoIcons.cube_box,
                                  color: Colors.grey.shade500,
                                ),
                                hintText: 'Enter no.of.Pickup',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Enter No.of.MFN Picked :',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _mfnController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
                                prefixIcon: Icon(
                                  CupertinoIcons.cube_box,
                                  color: Colors.grey.shade500,
                                ),
                                hintText: 'Enter no.of.MFN',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.blue.shade700,
                                  elevation: 5,
                                ),
                                onPressed: appStateProvider
                                            .isWithinPredefinedLocation() &&
                                        appStateProvider.selectedTimeSlot !=
                                            null &&
                                        !appStateProvider
                                            .isTimeSlotSelectedForToday(
                                                appStateProvider
                                                    .selectedTimeSlot!)
                                    ? () {
                                        if (_shipmentController.text.isEmpty ||
                                            _pickupController.text.isEmpty ||
                                            _mfnController.text.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Please fill in all fields'),
                                            ),
                                          );
                                        } else {
                                          // Show confirmation dialog
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    'Confirm Attendance Marking'),
                                                content: Text(
                                                    'Are you sure you want to mark attendance?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Confirm'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Close dialog

                                                      // Proceed with marking attendance and adding data
                                                      addDetails();
                                                      _clearShoppingFields();
                                                      appStateProvider
                                                          .disableSelectedTimeSlot();

                                                      String employeeId =
                                                          _idController.text;
                                                      Navigator.of(context)
                                                          .push(
                                                        CupertinoPageRoute(
                                                          builder: (context) =>
                                                              AttendencePage(
                                                            employeeId:
                                                                employeeId,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      }
                                    : null,
                                child: const Text(
                                  'Mark Attendance',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}