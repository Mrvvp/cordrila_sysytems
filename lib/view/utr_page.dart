import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordrila_sysytems/controller/utr_provider.dart';
import 'package:cordrila_sysytems/view/attendence_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:cordrila_sysytems/view/profilepage.dart';

class UtrPage extends StatefulWidget {
  const UtrPage({super.key});

  @override
  _UtrPageState createState() => _UtrPageState();
}

class _UtrPageState extends State<UtrPage> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('userdata');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _utrController = TextEditingController();

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
    final provider = Provider.of<UtrPageProvider>(context, listen: false);
    await provider.initializeData();
    String locationName = await provider.getLocationName();
    _locationController.text = locationName;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData = Provider.of<SigninpageProvider>(context).userData;
    if (userData != null) {
      _nameController.text = userData['Employee Name'] ?? '';
      _idController.text = userData['EmpCode'] ?? '';
    }
  }

  Future<void> _refreshData() async {
    Provider.of<UtrPageProvider>(context, listen: false).initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final utrStateProvider = Provider.of<UtrPageProvider>(context);
    final signinpageProvider = Provider.of<SigninpageProvider>(context);
    Future<bool> addDetails() async {
      try {
        final data = {
          'ID': _idController.text,
          'Name': _nameController.text,
          'Date': utrStateProvider.timestamp,
          'Location': _locationController.text,
          'Utr': _utrController.text,
          'Login': signinpageProvider.lastLoggedInTime ?? '',
        };
        await users.add(data);
        Fluttertoast.showToast(
          msg: "Attendance Marked",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return true;
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Attendance not Marked",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isWithinWarehouse = utrStateProvider.isWithinPredefinedLocation();
      bool dialogShown = utrStateProvider.alertShown;

      // print('isWithinWarehouse: $isWithinWarehouse');
      // print('dialogShown: $dialogShown');

      if (!isWithinWarehouse && !dialogShown) {
        // print('Showing dialog');
        utrStateProvider.showLocationAlert(context);
      } else if (isWithinWarehouse && dialogShown) {
        // print('Hiding dialog');
        // appStateProvider.resetDialogShown();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer<UtrPageProvider>(
        builder: (context, freshStateProvider, child) {
          if (utrStateProvider.isFetchingData) {
            return Center(child: CircularProgressIndicator(color: Colors.blue));
          } else {
            return SingleChildScrollView(
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
                              controller: utrStateProvider.timedateController,
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
                            TextFormField(
                              controller: _utrController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                enabled: false,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
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
                                onPressed: utrStateProvider.isAttendanceMarked ||
                              !utrStateProvider.isWithinPredefinedLocation()
                          ? null
                                    : () {
                                       if (_locationController.text ==
                                                'Unknown' ||
                                            _locationController.text.isEmpty) {
                                          // Handle location error
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Location error! Please restart your app.'),
                                            ),
                                          );
                                        }
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog( shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(10)),
                                              title: Text("Confirm Attendance"),
                                              content: Text(
                                                  "Are you sure you want to mark attendance?"),
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
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                    utrStateProvider
                                                        .markAttendance();
                                                    addDetails();
                                                    String employeeId =
                                                        _idController.text;
                                                    Navigator.of(context).push(
                                                      CupertinoPageRoute(
                                                        builder: (context) =>
                                                            AttendencePage(
                                                                employeeId:
                                                                    employeeId),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                child: Text(
                                  'Mark Attendance',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
          }
        }
      ),
      )
    );
  }
}


