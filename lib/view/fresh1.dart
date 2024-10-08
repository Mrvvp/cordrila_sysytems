import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordrila_sysytems/controller/fresh1_controller.dart';
import 'package:cordrila_sysytems/controller/fresh1_shift.dart';
import 'package:cordrila_sysytems/controller/profile_update_provider.dart';
import 'package:cordrila_sysytems/view/attendence_page.dart';
import 'package:cordrila_sysytems/view/loading.dart';
import 'package:cordrila_sysytems/view/replies.dart';
import 'package:cordrila_sysytems/view/uppercase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:cordrila_sysytems/view/profilepage.dart';

class Fresh1Page extends StatefulWidget {
  const Fresh1Page({Key? key, required this.userId, this.notificationCount = 0})
      : super(key: key);
  final String userId;
  final int notificationCount;

  @override
  _FreshPageState createState() => _FreshPageState();
}

class _FreshPageState extends State<Fresh1Page> {
  final List<String> slots = [
    '1.  9 AM - 12 PM',
    '2.  12 PM - 3 PM',
    '3.  3 PM - 6 PM',
    '4.  6 PM - 9 PM',
  ];
  final CollectionReference users =
      FirebaseFirestore.instance.collection('userdata');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _namecoraController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _coralocationController = TextEditingController();
  final TextEditingController _bagscoraController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _ordersController = TextEditingController();

  @override
  void initState() {
    _initialize();
    _initializeLocation();
    _initializeLastLoggedInTime();
    _timestamp();
    super.initState();
  }

  void _initializeLastLoggedInTime() async {
    final signinProvider =
        Provider.of<SigninpageProvider>(context, listen: false);
    await signinProvider.loadLastLoggedInTime();
  }

  void _timestamp() async {
    final timeProvider =
        Provider.of<Fresh1PageProvider>(context, listen: false);
    await timeProvider.updateTimestamp();
  }

  void _initialize() async {
    final provider = Provider.of<Fresh1ShiftProvider>(context, listen: false);
    provider.initialize();
  }

  void _clearShoppingFields() {
    _ordersController.clear();
    _bagscoraController.clear();
    _cashController.clear();
  }

  @override
  void dispose() {
    _ordersController.dispose();
    _bagscoraController.dispose();
    _cashController.dispose();
    super.dispose();
  }

  void _initializeLocation() async {
    final provider = Provider.of<Fresh1PageProvider>(context, listen: false);
    try {
      // Initialize data
      await provider.initializeData(widget.userId);

      // Fetch the location name
      String locationName = await provider.getLocationName();

      // Log the location name for debugging
      print('Fetched Location Name: $locationName');

      // Update the controller with the location name or coordinates
      _coralocationController.text =
          locationName != 'Out of station' ? locationName : 'Out of station';
    } catch (e) {
      // Handle any errors in fetching location
      print('Error fetching location: $e');
      _coralocationController.text = 'Error fetching location';
    }
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
    Provider.of<Fresh1PageProvider>(context, listen: false)
        .initializeData(widget.userId);
  }

  void _navigateToRepliesPage(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RepliesPage(userId: widget.userId),
      ),
    );
  }

  void _markNotificationsAsRead(List<QueryDocumentSnapshot> unreadDocs) async {
    for (var doc in unreadDocs) {
      await doc.reference.update({'read': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final fresh1StateProvider = Provider.of<Fresh1PageProvider>(context);
    final signinpageProvider = Provider.of<SigninpageProvider>(context);
    final shift1Provider = Provider.of<Fresh1ShiftProvider>(context);
    final profileUpdateProvider = Provider.of<ProfileUpdateProvider>(context);

    void addDetails() async {
      // Save form fields regardless of validation
      _formKey.currentState!.save();

      try {
        // Extract text values from the TextEditingController instances
        final data = {
          'Time':
              shift1Provider.selectedShift, // Use default empty string if null
          'bags': _bagscoraController.text, // Provide default value if empty
          'orders': _ordersController.text,
          'cash': _cashController.text,

          'ID': _idController.text, // Provide default value if empty
          'Name': _namecoraController.text, // Provide default value if empty
          'Date': fresh1StateProvider.timestamp, // Provide default value if null
          'Location':
              _coralocationController.text, // Provide default value if empty
          'Login': signinpageProvider.lastLoggedInTime ??
              '', // Provide default value if null
          'GSF': fresh1StateProvider.selectedYesNoOption ??
              '', // Provide default value if null
        };

        // Log the data for debugging
        print('Adding details to Firestore: $data');

        // Add data to Firestore
        await users.add(data);

        // Show success message
        Fluttertoast.showToast(
          msg: "Attendance Marked",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (e) {
        // Log error and show failure message
        print('Error adding details to Firestore: $e');
        Fluttertoast.showToast(
          msg: "Attendance not Marked",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isWithinWarehouse = fresh1StateProvider.isWithinPredefinedLocation1();
      bool dialogShown = fresh1StateProvider.alertShown;

      if (!isWithinWarehouse && !dialogShown) {
        print('Showing dialog');
        fresh1StateProvider.showLocationAlert(context);
      } else if (isWithinWarehouse && dialogShown) {}
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer<Fresh1PageProvider>(
            builder: (context, freshStateProvider, child) {
          if (freshStateProvider.isFetchingData) {
            return Center(
                child: Lottie.asset(
              'assets/animations/Animation - 1722594040196.json',
              fit: BoxFit.contain,
            ));
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
                      Row(children: [
                        const Text(
                          'Welcome',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                       FutureBuilder<String?>(
                              future: profileUpdateProvider.getProfileImageUrl(
                                signinpageProvider.userData?['EmpCode'] ?? '',
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return IconButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfilePage(),
                                      ));
                                    },
                                    icon: ClipOval(
                                      child: Lottie.asset(
                                        'assets/animations/Animation - 1722594040196.json',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }

                                if (snapshot.hasError || !snapshot.hasData) {
                                  return IconButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfilePage(),
                                      ));
                                    },
                                    icon: ClipOval(
                                      child: Image.asset(
                                        'assets/images/user (1).png',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }

                                final imageUrl = snapshot.data;
                                return IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => const ProfilePage(),
                                    ));
                                  },
                                  icon: ClipOval(
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/images/user (1).png',
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                );
                              },
                            ),
                        IconButton(
                          onPressed: () {
                            String employeeId = _idController.text;
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AttendencePage(
                                      employeeId: employeeId,
                                    )));
                          },
                          icon: Image.asset(
                            'assets/images/calendar.png',
                            width: 40,
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('requests')
                              .where('userId', isEqualTo: widget.userId)
                              .where('read',
                                  isEqualTo:
                                      false) // Only fetch unread notifications
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return IconButtonWithBadge(
                                image: AssetImage('assets/images/bell.png'),
                                badgeCount: 0,
                                onPressed: () {
                                  _navigateToRepliesPage(context);
                                },
                              );
                            }

                            // Filter documents to count only those with a non-empty 'reply' field
                            final unreadDocs = snapshot.data!.docs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final reply = data['reply'];
                              return reply != null &&
                                  reply.toString().trim().isNotEmpty;
                            }).toList();

                            // Get the number of unread notifications
                            int unreadCount = unreadDocs.length;

                            return IconButtonWithBadge(
                              image: AssetImage('assets/images/bell.png'),
                              badgeCount: unreadCount,
                              onPressed: () {
                                _navigateToRepliesPage(context);
                                _markNotificationsAsRead(unreadDocs);
                              },
                            );
                          },
                        ),
                      ]),
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
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            controller: _namecoraController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.profile_circled,
                                color: Colors.grey.shade500,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
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
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            controller: _idController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.number,
                                color: Colors.grey.shade500,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
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
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            controller: freshStateProvider.timedateController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.calendar,
                                color: Colors.grey.shade500,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
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
                            readOnly: true,
                            controller: _coralocationController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: Colors.grey.shade500,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
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
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black45)),
                            child: Column(
                              children: slots.map((shift) {
                                final isEnabled =
                                    shift1Provider.isShiftEnabled(shift);
                                final isHidden = shift1Provider
                                    .isShiftHidden(shift); // Use isShiftHidden
                                final isChecked =
                                    shift1Provider.tempSelectedShift ==
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
                                            shift1Provider
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
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              labelStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500),
                              labelText: 'Select an option',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.black),
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
                            'Orders :',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _ordersController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500),
                              labelText: 'Enter no.of.orders',
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.cube_box,
                                color: Colors.grey.shade500,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the No of orders';
                              }
                              return null;
                            },
                            
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Bags :',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _bagscoraController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500),
                              labelText: 'Enter no.of.bags',
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.cube,
                                color: Colors.grey.shade500,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter No of bags';
                              }
                              return null;
                            },
                            
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
                            controller: _cashController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500),
                              labelText: 'Enter Amount',
                              contentPadding: const EdgeInsets.all(10),
                              constraints: const BoxConstraints(maxHeight: 70),
                              prefixIcon: Icon(
                                CupertinoIcons.money_dollar,
                                color: Colors.grey.shade500,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the amount';
                              }
                              return null;
                            },
                           
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
                                          .isWithinPredefinedLocation1() &&
                                      shift1Provider.isNewShiftSelected()
                                  ? () async {
                                      final empCode = _idController
                                          .text; // Replace with your employee code logic
                                      final isActive = await freshStateProvider
                                          .isUserActive(empCode);

                                      if (!isActive) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('User is inactive'),
                                          ),
                                        );
                                        return;
                                      }
                                      if (_formKey.currentState!.validate()) {
                                        if (_coralocationController.text ==
                                                'Out of station' ||
                                            _coralocationController
                                                .text.isEmpty ||
                                            _coralocationController.text ==
                                                'Location not found') {
                                          // Handle location error
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Location error! Refresh your app.'),
                                            ),
                                          );
                                        } else if (freshStateProvider
                                            .timedateController.text.isEmpty) {
                                          // Handle location error
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Error loading data! Refresh your app'),
                                            ),
                                          );
                                          return;
                                        }
                                        final profileUpdateProvider =
                                            Provider.of<ProfileUpdateProvider>(
                                                context,
                                                listen: false);

                                        if (!await profileUpdateProvider
                                            .isProfileComplete(context)) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                title: Text('Update Profile'),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Consumer<
                                                          ProfileUpdateProvider>(
                                                        builder: (context,
                                                            profileUpdateProvider,
                                                            child) {
                                                          return GestureDetector(
                                                            onTap: () async {
                                                              await profileUpdateProvider
                                                                  .setProfileImage(
                                                                      context);
                                                            },
                                                            child: CircleAvatar(
                                                              backgroundImage: profileUpdateProvider
                                                                          .profileImage ==
                                                                      null
                                                                  ? AssetImage(
                                                                          'assets/images/man.png')
                                                                      as ImageProvider
                                                                  : FileImage(
                                                                      profileUpdateProvider
                                                                          .profileImage!),
                                                              radius: 50.0,
                                                              child: profileUpdateProvider
                                                                          .profileImage ==
                                                                      null
                                                                  ? Icon(
                                                                      Icons
                                                                          .camera_alt,
                                                                      color: Colors
                                                                          .white)
                                                                  : null,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      SizedBox(height: 16),
                                                      TextField(
                                                        controller:
                                                            profileUpdateProvider
                                                                .bloodGroupController,
                                                        inputFormatters: [
                                                          UpperCaseTextFormatter(),
                                                        ],
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxHeight:
                                                                      70),
                                                          prefixIcon: Icon(
                                                              Icons.bloodtype,
                                                              color:
                                                                  Colors.red),
                                                          labelText:
                                                              'Enter blood group',
                                                          labelStyle: TextStyle(
                                                              color: Colors
                                                                  .black45),
                                                          hintText: 'eg: A +ve',
                                                          hintStyle: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black45),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          errorText:
                                                              profileUpdateProvider
                                                                      .bloodGroupController
                                                                      .text
                                                                      .isEmpty
                                                                  ? 'Required *'
                                                                  : null,
                                                        ),
                                                      ),
                                                      SizedBox(height: 16),
                                                      TextField(
                                                        controller:
                                                            profileUpdateProvider
                                                                .emergencyPersonController,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxHeight:
                                                                      70),
                                                          prefixIcon:
                                                              Icon(Icons.man),
                                                          labelText:
                                                              'Emergency Person',
                                                          labelStyle: TextStyle(
                                                              color: Colors
                                                                  .black45),
                                                          hintText:
                                                              'eg: Full name',
                                                          hintStyle: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black45),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          errorText:
                                                              profileUpdateProvider
                                                                      .emergencyPersonController
                                                                      .text
                                                                      .isEmpty
                                                                  ? 'Required *'
                                                                  : null,
                                                        ),
                                                      ),
                                                      SizedBox(height: 16),
                                                      TextField(
                                                        controller:
                                                            profileUpdateProvider
                                                                .emergencyContactController,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxHeight:
                                                                      70),
                                                          prefixIcon:
                                                              Icon(Icons.phone),
                                                          labelText:
                                                              'Emergency Number',
                                                          labelStyle: TextStyle(
                                                              color: Colors
                                                                  .black45),
                                                          hintText:
                                                              'eg: +91 xxxxxxxxxx',
                                                          hintStyle: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black45),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          errorText:
                                                              profileUpdateProvider
                                                                      .emergencyContactController
                                                                      .text
                                                                      .isEmpty
                                                                  ? 'Required *'
                                                                  : null,
                                                        ),
                                                        keyboardType:
                                                            TextInputType.phone,
                                                      ),
                                                      SizedBox(height: 20),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: TextButton(
                                                          onPressed: () async {
                                                            // Validate inputs
                                                            if (profileUpdateProvider.bloodGroupController.text.isEmpty ||
                                                                profileUpdateProvider
                                                                    .emergencyPersonController
                                                                    .text
                                                                    .isEmpty ||
                                                                profileUpdateProvider
                                                                    .emergencyContactController
                                                                    .text
                                                                    .isEmpty ||
                                                                profileUpdateProvider
                                                                        .profileImage ==
                                                                    null) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      'Please fill in all fields'),
                                                                ),
                                                              );
                                                              return;
                                                            }
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return const LoadingDialog();
                                                              },
                                                            );
                                                            await profileUpdateProvider
                                                                .saveProfile(
                                                                    context);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();

                                                            Navigator.pop(
                                                                context);
                                                            await profileUpdateProvider
                                                                .saveProfile(
                                                                    context);
                                                            profileUpdateProvider
                                                                .clearProfile();
                                                          },
                                                          child: Text('Submit'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                title:
                                                    Text('Confirm Attendance'),
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
                                                      shift1Provider
                                                          .markAttendance(); // Mark attendance and update shift visibility

                                                      addDetails();
                                                      _clearShoppingFields();
                                                      Navigator.of(context)
                                                          .pop();
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
