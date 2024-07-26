import 'package:cordrila_sysytems/controller/profile_provider.dart';
import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:cordrila_sysytems/view/forget_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _updateRequestController =
      TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData = Provider.of<SigninpageProvider>(context).userData;
    if (userData != null) {
      _nameController.text = userData['Employee Name'] ?? '';
      _idController.text = userData['EmpCode'] ?? '';
      _titleController.text = userData['Business Title'] ?? '';
      _emailController.text = userData['Mail ID'] ?? '';
      _dobController.text = userData['DOB'] ?? '';
      _panController.text = userData['PAN CARD'] ?? '';
      _mobileController.text = userData['Mobile Number'].toString();
      _categoryController.text = userData['Category'] ?? '';
      _typeController.text = userData['Location'] ?? '';
      _stationController.text = userData['StationCode'] ?? '';
    }
  }

  Future<void> _sendUpdateRequest(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade200,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            'Request',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            maxLines: 3,
            controller: _updateRequestController,
            decoration: InputDecoration(
              hintText: 'Eg: New mail id - "abcd@gmail.com"',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: Colors.white30,
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blue.shade700),
              ),
              onPressed: () async {
                if (_updateRequestController.text.isNotEmpty) {
                  final updateRequest = _updateRequestController.text;
                  final userId = _idController.text;

                  try {
                    await Provider.of<ProfilepageProvider>(context,
                            listen: false)
                        .sendUpdateRequest(userId, updateRequest);

                    Fluttertoast.showToast(
                        msg: "Request sent successfully",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0);

                    Navigator.of(context).pop();
                    _updateRequestController.clear();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('request not send')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<SigninpageProvider>(context).userData;

    return Scaffold(
      backgroundColor: Colors.white,
      body: userData != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.profile_circled,
                              color: Colors.black,
                              size: 40,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              'Profile',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) =>
                                        ForgotPasswordPage()));
                              },
                              child: Text(
                                'Update password?',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                'Name :',
                                style: TextStyle(fontSize: 15),
                              ),
                              TextField(
                                cursorColor: Colors.black,
                                enabled: false,
                                controller: _nameController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  constraints:
                                      const BoxConstraints(maxHeight: 50),
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
                              const SizedBox(height: 5),
                              const Text(
                                'ID :',
                                style: TextStyle(fontSize: 15),
                              ),
                              TextField(
                                cursorColor: Colors.black,
                                enabled: false,
                                controller: _idController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  constraints:
                                      const BoxConstraints(maxHeight: 50),
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
                              const SizedBox(height: 5),
                              const Text(
                                'Category :',
                                style: TextStyle(fontSize: 15),
                              ),
                              TextField(
                                cursorColor: Colors.black,
                                enabled: false,
                                controller: _categoryController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  constraints:
                                      const BoxConstraints(maxHeight: 50),
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
                              const SizedBox(height: 5),
                              const Text(
                                'Type :',
                                style: TextStyle(fontSize: 15),
                              ),
                              TextField(
                                cursorColor: Colors.black,
                                enabled: false,
                                controller: _typeController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  constraints:
                                      const BoxConstraints(maxHeight: 50),
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
                              const SizedBox(height: 5),
                              const Text(
                                'Station Code :',
                                style: TextStyle(fontSize: 15),
                              ),
                              TextField(
                                cursorColor: Colors.black,
                                enabled: false,
                                controller: _stationController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  constraints:
                                      const BoxConstraints(maxHeight: 50),
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
                              const SizedBox(height: 5),
                              const Text(
                                'Email :',
                                style: TextStyle(fontSize: 15),
                              ),
                              TextFormField(
                                enabled: false,
                                cursorColor: Colors.black,
                                controller: _emailController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  constraints:
                                      const BoxConstraints(maxHeight: 50),
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
                              const SizedBox(height: 5),
                              const Text(
                                'DOB :',
                                style: TextStyle(fontSize: 15),
                              ),
                              TextField(
                                cursorColor: Colors.black,
                                enabled: false,
                                controller: _dobController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  constraints:
                                      const BoxConstraints(maxHeight: 50),
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
                              const SizedBox(height: 5),
                              const Text(
                                'PAN Card :',
                                style: TextStyle(fontSize: 15),
                              ),
                              TextField(
                                cursorColor: Colors.black,
                                enabled: false,
                                controller: _panController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  constraints:
                                      const BoxConstraints(maxHeight: 50),
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
                              const SizedBox(height: 5),
                              const Text(
                                'Mobile Number :',
                                style: TextStyle(fontSize: 15),
                              ),
                              TextFormField(
                                enabled: false,
                                cursorColor: Colors.black,
                                controller: _mobileController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  constraints:
                                      const BoxConstraints(maxHeight: 50),
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
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Need to update?',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.40,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _sendUpdateRequest(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        backgroundColor: Colors.blue.shade700,
                                        elevation: 5,
                                      ),
                                      child: const Text(
                                        'Send request',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
