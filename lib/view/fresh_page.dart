import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordrila_sysytems/controller/fresh_page_provider.dart';
import 'package:cordrila_sysytems/controller/shift_Controller.dart';
import 'package:cordrila_sysytems/view/attendence_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:cordrila_sysytems/view/profilepage.dart';

class FreshPage extends StatefulWidget {
  const FreshPage({super.key});

  @override
  _FreshPageState createState() => _FreshPageState();
}

class _FreshPageState extends State<FreshPage> {
  final List<String> slots = [
    '1.  7 AM - 10 AM',
    '2.  10 AM - 1 PM',
    '3.  1 PM - 4 PM',
    '4.  4 PM - 7 PM',
    '5.  7 PM - 10 PM',
  ];
  final CollectionReference users =
      FirebaseFirestore.instance.collection('userdata');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _corabagsController = TextEditingController();
  final TextEditingController _coraordersController = TextEditingController();
  final TextEditingController _mopcoraController = TextEditingController();
  final TextEditingController _namecoraController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _coralocationController = TextEditingController();

  @override
  void initState() {
    _initializeLocation();
    _initializeLastLoggedInTime();
    super.initState();
  }

  void _initializeLastLoggedInTime() async {
    final signinProvider =
        Provider.of<SigninpageProvider>(context, listen: false);
    await signinProvider.loadLastLoggedInTime();
  }

  void _initializeLocation() async {
    final provider = Provider.of<FreshPageProvider>(context, listen: false);
    provider.initializeData();
    String locationName = await provider.getLocationName();
    _coralocationController.text = locationName;
  }

  void _clearShoppingFields() {
    _corabagsController.clear();
    _coraordersController.clear();
    _mopcoraController.clear();
  }

  @override
  void dispose() {
    _corabagsController.dispose();
    _coraordersController.dispose();
    _mopcoraController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData = Provider.of<SigninpageProvider>(context).userData;
    if (userData != null) {
      _namecoraController.text = userData['Employee Name'] ?? '';
      _idController.text = userData['EmpCode'] ?? '';
    }
  }

  Future<void> _refreshData() async {
    Provider.of<FreshPageProvider>(context, listen: false).initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final freshStateProvider = Provider.of<FreshPageProvider>(context);
    final signinpageProvider = Provider.of<SigninpageProvider>(context);
    final shiftProvider = Provider.of<ShiftProvider>(context);

    void addDetails() async {
      try {
        final data = {
          'Time': shiftProvider.selectedShift,
          'bags': _corabagsController.text,
          'orders': _coraordersController.text,
          'cash': _mopcoraController.text,
          'ID': _idController.text,
          'Name': _namecoraController.text,
          'Date': freshStateProvider.timestamp,
          'Location': _coralocationController.text,
          'Login': signinpageProvider.lastLoggedInTime ?? '',
          'GSF': freshStateProvider.selectedYesNoOption ?? '',
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
      bool isWithinWarehouse = freshStateProvider.isWithinPredefinedLocation();
      bool dialogShown = freshStateProvider.alertShown;

      // print('isWithinWarehouse: $isWithinWarehouse');
      // print('dialogShown: $dialogShown');

      if (!isWithinWarehouse && !dialogShown) {
        // print('Showing dialog');
        freshStateProvider.showLocationAlert(context);
      } else if (isWithinWarehouse && dialogShown) {
        // print('Hiding dialog');
        // appStateProvider.resetDialogShown();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer<FreshPageProvider>(
            builder: (context, freshStateProvider, child) {
          if (freshStateProvider.isFetchingData) {
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
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const ProfilePage()));
                              },
                              icon: const Icon(CupertinoIcons.profile_circled,
                                  color: Colors.black, size: 40)),
                          IconButton(
                              onPressed: () {
                                String employeeId = _idController.text;
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AttendencePage(
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
                            controller: _namecoraController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              enabled: false,
                              prefixIcon: Icon(
                                CupertinoIcons.profile_circled,
                                color: Colors.grey.shade500,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
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
                              constraints: const BoxConstraints(maxHeight: 70),
                              enabled: false,
                              prefixIcon: Icon(
                                CupertinoIcons.number,
                                color: Colors.grey.shade500,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
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
                            controller: freshStateProvider.timedateController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              enabled: false,
                              prefixIcon: Icon(
                                CupertinoIcons.calendar,
                                color: Colors.grey.shade500,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
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
                            controller: _coralocationController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              enabled: false,
                              prefixIcon: Icon(
                                CupertinoIcons.location,
                                color: Colors.grey.shade500,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
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
                            'Slots :',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 280,
                            child: Column(
                              children: slots.map((shift) {
                                final isEnabled =
                                    shiftProvider.isShiftEnabled(shift);
                                final isHidden = shiftProvider
                                    .isShiftHidden(shift); // Use isShiftHidden
                                final isChecked =
                                    shiftProvider.tempSelectedShift ==
                                        shift; // Use tempSelectedShift

                                return ListTile(
                                  title: Text(
                                    shift,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isHidden
                                          ? Colors.grey
                                          : null, // Change color if hidden
                                    ),
                                  ),
                                  trailing: isChecked || isHidden
                                      ? Icon(Icons.check_box,
                                          color: Colors.green)
                                      : null, // Show tick mark if checked
                                  onTap: isEnabled && !isHidden
                                      ? () {
                                          if (!isChecked) {
                                            shiftProvider
                                                .setSelectedShift(shift);
                                          }
                                        }
                                      : null, // Disable tap if the shift is not enabled or hidden
                                  tileColor: isChecked
                                      ? Colors.grey[200]
                                      : null, // Optional: change tile color if checked
                                  // Optional: show a subtitle if the shift is hidden
                                );
                              }).toList(),
                            ),
                          ),
                          const Text(
                            'GSF :',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonFormField<String>(
                            itemHeight: 60,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              labelStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500),
                              labelText: 'Select an option',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            value: freshStateProvider.selectedYesNoOption,
                            onChanged:
                                freshStateProvider.setSelectedYesNoOption,
                            items: freshStateProvider.yesNoOptions
                                .map((String option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'No.of.Orders :',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _coraordersController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.cube_box,
                                color: Colors.grey.shade500,
                              ),
                              hintText: 'Enter no.of.Orders',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
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
                            'No.of.Bags :',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _corabagsController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.cube_box,
                                color: Colors.grey.shade500,
                              ),
                              hintText: 'Enter no.of.Bags',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
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
                            'Cash Collected :',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _mopcoraController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.money_dollar,
                                color: Colors.grey.shade500,
                              ),
                              hintText: 'Enter the amount',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
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
                              onPressed: freshStateProvider
                                          .isWithinPredefinedLocation() &&
                                      shiftProvider.isNewShiftSelected()
                                  ? () {
                                      if (_coraordersController.text.isEmpty ||
                                          _corabagsController.text.isEmpty ||
                                          _mopcoraController.text.isEmpty ||
                                          freshStateProvider
                                                  .selectedYesNoOption ==
                                              null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please fill in all fields'),
                                          ),
                                        );
                                      }
                                      // else if (_locationController.text ==
                                      //         'Unknown' ||
                                      //     _locationController.text.isEmpty) {
                                      //   // Handle location error
                                      //   ScaffoldMessenger.of(context)
                                      //       .showSnackBar(
                                      //     const SnackBar(
                                      //       content: Text(
                                      //           'Location error! Refresh your app.'),
                                      //     ),
                                      //   );
                                      // }
                                      else if (freshStateProvider
                                          .timedateController.text.isEmpty) {
                                        // Handle location error
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Error loading data! Refresh your app'),
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Confirm Attendance'),
                                              content: Text(
                                                  'Are you sure you want to mark attendance?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    shiftProvider
                                                        .markAttendance(); // Mark attendance and update shift visibility
                                                    Navigator.of(context).pop();
                                                    _clearShoppingFields();
                                                    addDetails();
                                                    String employeeId =
                                                        _idController.text;
                                                    Navigator.of(context).push(
                                                      CupertinoPageRoute(
                                                        builder: (context) =>
                                                            AttendencePage(
                                                          employeeId:
                                                              employeeId,
                                                        ),
                                                      ),
                                                    ); // Close the dialog
                                                  },
                                                  child: Text('Mark'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }
                                  : null,
                              child: Text(
                                'Mark Attendance',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
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
        }),
      ),
    );
  }
}
