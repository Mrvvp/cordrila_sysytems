import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordrila_sysytems/controller/profile_update_provider.dart';
import 'package:cordrila_sysytems/controller/utr_provider.dart';
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

class UtrPage extends StatefulWidget {
  const UtrPage({super.key, required this.userId});
  final String userId;

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
  final TextEditingController _stationController = TextEditingController();

  @override
  void initState() {
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
    final timeProvider = Provider.of<UtrPageProvider>(context, listen: false);
    await timeProvider.updateTimestamp();
  }

  void _initializeLocation() async {
    final provider = Provider.of<UtrPageProvider>(context, listen: false);
    await provider.initializeData(widget.userId);
    String locationName = await provider.getLocationName();
    _locationController.text = locationName;
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
    Provider.of<UtrPageProvider>(context, listen: false)
        .initializeData(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final utrStateProvider = Provider.of<UtrPageProvider>(context);
    final signinpageProvider = Provider.of<SigninpageProvider>(context);
    final profileUpdateProvider = Provider.of<ProfileUpdateProvider>(context);
    Future<bool> addDetails() async {
      try {
        final data = {
          'ID': _idController.text,
          'Name': _nameController.text,
          'Date': utrStateProvider.timestamp,
          'Location': _locationController.text,
          'Utr': _utrController.text,
          'Station': _stationController.text,
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
      } else if (isWithinWarehouse && dialogShown) {}
    });

    return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Consumer<UtrPageProvider>(
              builder: (context, utrStateProvider, child) {
            if (utrStateProvider.isFetchingData) {
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
                                final unreadDocs =
                                    snapshot.data!.docs.where((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
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
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Name :',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
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
                              controller: _nameController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
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
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
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
                              controller: utrStateProvider.timedateController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
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
                              'Station Code :',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              readOnly: true,
                              keyboardType: TextInputType.number,
                              controller: _stationController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
                                prefixIcon: Icon(
                                  Icons.store_outlined,
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
                              keyboardType: TextInputType.number,
                              controller: _locationController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                constraints:
                                    const BoxConstraints(maxHeight: 70),
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
                                onPressed: utrStateProvider
                                            .isAttendanceMarked ||
                                        !utrStateProvider
                                            .isWithinPredefinedLocation()
                                    ? null
                                    : () async {
                                        final empCode = _idController.text;
                                        final isActive = await utrStateProvider
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
                                          return;
                                        } else if (_locationController.text ==
                                                'Out of station' ||
                                            _locationController.text.isEmpty) {
                                          // Handle location error
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Location error! Please restart your app.'),
                                            ),
                                          );
                                        } else if (utrStateProvider
                                            .timedateController.text.isEmpty) {
                                          // Handle location error
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Error loading data'),
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
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                title:
                                                    Text("Confirm Attendance"),
                                                content: Text(
                                                    "Are you sure you want to mark attendance?"),
                                                actions: [
                                                  TextButton(
                                                    child: Text("Cancel"),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
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
                                                      Navigator.of(context)
                                                          .push(
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
                                        }
                                      },
                                child: Text(
                                  'Mark Attendance',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
        ));
  }
}
