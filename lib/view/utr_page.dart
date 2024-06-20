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
    super.initState();
  }

  void _initializeLocation() async {
    final provider = Provider.of<UtrpageProvider>(context, listen: false);
    await provider.loadData();
    _locationController.text = provider.getLocationName();
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
    Provider.of<UtrpageProvider>(context, listen: false).loadData();
  }

  @override
  Widget build(BuildContext context) {
    final utrStateProvider = Provider.of<UtrpageProvider>(context);
    Future<bool> addDetails() async {
      try {
        final data = {
          'ID': _idController.text,
          'Name': _nameController.text,
          'Date': utrStateProvider.timestamp,
          'Location': _locationController.text,
          'Utr': _utrController.text,
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
      bool isWithinWarehouse = utrStateProvider.isAtAnyStation();
      bool dialogShown = utrStateProvider.dialogShown;

      // print('isWithinWarehouse: $isWithinWarehouse');
      // print('dialogShown: $dialogShown');

      if (!isWithinWarehouse && !dialogShown) {
        // print('Showing dialog');
        utrStateProvider.showLocationDialog(context);
      } else if (isWithinWarehouse && dialogShown) {
        // print('Hiding dialog');
        // appStateProvider.resetDialogShown();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: utrStateProvider.isLoading
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
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Row(
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
                                  backgroundColor:
                                      utrStateProvider.isAttendanceMarked
                                          ? Colors.grey
                                          : Colors.blue,
                                  elevation: 5,
                                ),
                                onPressed: utrStateProvider.isAttendanceMarked
  ? null
  : () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Attendance"),
            content: Text("Are you sure you want to mark attendance?"),
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
                  Navigator.of(context).pop(); // Close the dialog
                  utrStateProvider.markAttendance();
                  addDetails();
                  String employeeId = _idController.text;
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => AttendencePage(employeeId: employeeId),
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
              ),
      ),
    );
  }
}
