import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    // Dispose other controllers
    super.dispose();
  }

  void _populateFields(Map<String, dynamic> userData) {
    _nameController.text = userData['Employee Name'] ?? '';
    _idController.text = userData['Emp/IC Code'] ?? '';
    _titleController.text = userData['Business Title'] ?? '';
    _emailController.text = userData['Mail ID'] ?? '';
    _dobController.text = userData['DOB'] ?? '';
    _panController.text = userData['PAN CARD'] ?? '';
    _mobileController.text = userData['Mobile Number'].toString();
    _categoryController.text = userData['Category'] ?? '';
    _typeController.text = userData['Location'] ?? '';
    _stationController.text = userData['Station Code'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final signinProvider = Provider.of<SigninpageProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          size: 35,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        constraints: BoxConstraints(
                            maxHeight: 40,
                            maxWidth: MediaQuery.of(context).size.width * 0.63),
                        contentPadding: EdgeInsets.all(8),
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          color: Colors.grey.shade500,
                        ),
                        hintText: 'Enter ID',
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
                    SizedBox(width: 10),
                    SizedBox(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          String userId = _searchController.text;
                          signinProvider.fetchUserData(userId).then((_) {
                            if (signinProvider.userData != null) {
                              _populateFields(signinProvider.userData!);
                            }
                          });
                        },
                        child: Text(
                          'Search',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                if (signinProvider.isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                if (signinProvider.userData != null &&
                    !signinProvider.isLoading)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxHeight: 50),
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: _idController,
                        decoration: InputDecoration(
                          labelText: 'ID',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxHeight: 50),
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxHeight: 50),
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxHeight: 50),
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: _mobileController,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxHeight: 50),
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: _panController,
                        decoration: InputDecoration(
                          labelText: 'PAN card',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxHeight: 50),
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: _dobController,
                        decoration: InputDecoration(
                          labelText: 'DOB',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxHeight: 50),
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: _stationController,
                        decoration: InputDecoration(
                          labelText: 'Station Code',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxHeight: 50),
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: _typeController,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxHeight: 50),
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxHeight: 50),
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
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            // Gather the updated data from the controllers
                            Map<String, dynamic> updatedData = {
                              'Employee Name': _nameController.text,
                              'Emp/IC Code': _idController.text,
                              'Business Title': _titleController.text,
                              'Mail ID': _emailController.text,
                              'DOB': _dobController.text,
                              'PAN CARD': _panController.text,
                              'Mobile Number': _mobileController.text,
                              'Category': _categoryController.text,
                              'Location': _typeController.text,
                              'Station Code': _stationController.text,
                            };

                            // Call the provider method to update the data
                            String userId = _idController
                                .text; // Assuming the ID is used as the identifier
                            signinProvider.setLoading(true);
                            try {
                              await signinProvider.updateUserData(
                                  userId, updatedData);
                              // Show a success message or navigate to another screen if needed
                              Fluttertoast.showToast(
                                  msg: "Profile updated successfully",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } catch (error) {
                              // Show an error message if the update fails
                              Fluttertoast.showToast(
                                  msg: "Failed to update profile",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } finally {
                              signinProvider.setLoading(false);
                            }
                          },
                          child: Text(
                            'Update',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
