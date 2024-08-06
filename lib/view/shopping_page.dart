import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordrila_sysytems/controller/shift_shop_provider.dart';
import 'package:cordrila_sysytems/controller/shopping_page_provider.dart';
import 'package:cordrila_sysytems/view/attendence_page.dart';
import 'package:cordrila_sysytems/view/replies.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:cordrila_sysytems/view/profilepage.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key, required this.userId});
  final String userId;

  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final List<String> shifts = [
    'Morning (before 12 PM)',
    'Evening (after 12 PM )'
  ];
  final CollectionReference users =
      FirebaseFirestore.instance.collection('userdata');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _shipmentController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _mfnController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _stationController = TextEditingController();

  @override
  void initState() {
    _initializeLocation();
    _initializeLastLoggedInTime();
    _initialize();

    super.initState();
  }

  void _initializeLastLoggedInTime() async {
    final signinProvider =
        Provider.of<SigninpageProvider>(context, listen: false);
    await signinProvider.loadLastLoggedInTime();
  }

  void _initializeLocation() async {
    final provider = Provider.of<ShoppingPageProvider>(context, listen: false);
    await provider.initializeData(widget.userId);
    String locationName = await provider.getLocationName();
    _locationController.text = locationName;
  }

  void _initialize() async {
    final provider = Provider.of<ShopProvider>(context, listen: false);
    provider.initialize();
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
      _idController.text = userData['EmpCode'] ?? '';
      _stationController.text = userData['StationCode'] ?? '';
    }
  }

  Future<void> _refreshData() async {
    await Provider.of<ShoppingPageProvider>(context, listen: false)
        .initializeData(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final appStateProvider = Provider.of<ShoppingPageProvider>(context);
    final signinpageProvider = Provider.of<SigninpageProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);

    void addDetails() async {
      try {
        final data = {
          'shift': shopProvider.selectedShift,
          'shipment': _shipmentController.text,
          'pickup': _pickupController.text,
          'mfn': _mfnController.text,
          'ID': _idController.text,
          'Name': _nameController.text,
          'Date': appStateProvider.timestamp,
          'Location': _locationController.text,
          'Login': signinpageProvider.lastLoggedInTime ?? '',
          'LM Read': appStateProvider.selectedYesNoOption,
          'Helmet Adherence': appStateProvider.selectedYesNoOption,
          'Cash Submitted': appStateProvider.selectedTrueFalseOption,
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
        color: Colors.black,
        onRefresh: _refreshData,
        child: Consumer<ShoppingPageProvider>(
            builder: (context, freshStateProvider, child) {
          if (freshStateProvider.isFetchingData) {
            return Center(child: Lottie.asset('assets/animations/Animation - 1722594040196.json',
                                  fit: BoxFit.contain,));
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
                            icon: Icon(Icons.location_on_outlined,
                                size: 35, color: Colors.black),
                            onPressed: () {
                              if (!appStateProvider.isHomeLocationSet) {
                                final signinpageprovider =
                                    Provider.of<SigninpageProvider>(context,
                                        listen: false);
                                final appStateProvider =
                                    Provider.of<ShoppingPageProvider>(context,
                                        listen: false);
                                final empCode =
                                    signinpageprovider.userData?['EmpCode'];
                                // Ensure you pass the context and userId parameters
                                appStateProvider.setHomeLocation(
                                    context, empCode);
                                appStateProvider
                                    .loadHomeLocationFromFirestore(empCode);
                              } else {
                                // Handle action when already at home
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Already saved your home location'),
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const ProfilePage()));
                              },
                              icon: const Icon(CupertinoIcons.profile_circled,
                                  color: Colors.black, size: 35)),
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
                                size: 35,
                              )),
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) =>
                                        RepliesPage(userId: widget.userId)));
                              },
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.black,
                                size: 35,
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Name :',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Text(
                                'LOGIN: ${signinpageProvider.lastLoggedInTime ?? 'No data available'}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8),
                              ),
                            ],
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
                            controller: appStateProvider.timedateController,
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
                            'Station Code :',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _stationController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              enabled: false,
                              prefixIcon: Icon(
                                Icons.store_outlined,
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
                            keyboardType: TextInputType.number,
                            controller: _locationController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              enabled: false,
                              prefixIcon: Icon(
                              Icons.location_on_outlined,
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
                            'Shift :',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade200,
                            ),
                            child: Column(
                              children: shifts.map((shift) {
                                final isEnabled =
                                    shopProvider.isShiftEnabled(shift);
                                final isHidden = shopProvider
                                    .isShiftHidden(shift); // Use isShiftHidden
                                final isChecked =
                                    shopProvider.tempSelectedShift ==
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
                                            shopProvider
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
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'LM Read :',
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
                            value: appStateProvider.selectedYesNoOption,
                            onChanged: appStateProvider.setSelectedYesNoOption,
                            items: appStateProvider.yesNoOptions
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
                            'Helmet Adherence :',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500),
                              labelText: 'Select an option',
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            value: appStateProvider.selectedDoneNoOption,
                            onChanged: appStateProvider.setSelectedDoneNoOption,
                            items: appStateProvider.doneNoOptions
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
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.cube_box,
                                color: Colors.grey.shade500,
                              ),
                              hintText: 'Enter no.of.Shipments',
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
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.cube_box,
                                color: Colors.grey.shade500,
                              ),
                              hintText: 'Enter no.of.Pickup',
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
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.cube_box,
                                color: Colors.grey.shade500,
                              ),
                              hintText: 'Enter no.of.MFN',
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
                            'Cash Submitted :',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500),
                              labelText: 'Select an option',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            value: appStateProvider.selectedTrueFalseOption,
                            onChanged:
                                appStateProvider.setSelectedTrueFalseOption,
                            items: appStateProvider.trueFalseOptions
                                .map((String option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
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
                              onPressed: (freshStateProvider
                                          .isWithinPredefinedLocation() ||
                                      freshStateProvider
                                              .isWithinAlternativeLocation()) &&
                                          shopProvider.isNewShiftSelected()
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
                                      } else if (appStateProvider
                                                  .selectedYesNoOption ==
                                              null ||
                                          appStateProvider
                                                  .selectedDoneNoOption ==
                                              null ||
                                          appStateProvider
                                                  .selectedTrueFalseOption ==
                                              null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please fill in all fields.'),
                                          ),
                                        );
                                      } else if (_locationController.text ==
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
                                      } else if (appStateProvider
                                          .timedateController.text.isEmpty) {
                                        // Handle location error
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Error loading data'),
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
                                                    shopProvider
                                                        .markAttendance();
                                                    addDetails();
                                                    _clearShoppingFields(); // Mark attendance and update shift visibility
                                                    Navigator.of(context).pop();
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
