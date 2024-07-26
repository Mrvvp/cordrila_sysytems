import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:cordrila_sysytems/view/sign_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey<FormState>();
    final appStateProvider =
        Provider.of<SigninpageProvider>(context, listen: false);
    final TextEditingController _idController = TextEditingController();
    final TextEditingController _newPasswordController =
        TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();

    void _clearForgotPasswordFields() {
      _idController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
    

    final userData = Provider.of<SigninpageProvider>(context).userData;
    if (userData != null) {
      _idController.text = userData['EmpCode'] ?? '';
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _forgotPasswordFormKey,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Update Password',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _idController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      enabled: false,
                      prefixIcon: Icon(
                        CupertinoIcons.number,
                        color: Colors.grey.shade500,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
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
                  const SizedBox(height: 10),
                  TextFormField(
                    obscureText: true,
                    controller: _newPasswordController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        CupertinoIcons.lock,
                        color: Colors.grey.shade500,
                      ),
                      hintText: 'Enter new password',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    obscureText: true,
                    controller: _confirmPasswordController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        CupertinoIcons.lock,
                        color: Colors.grey.shade500,
                      ),
                      hintText: 'Confirm password',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.blue.shade700),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.blue.shade700),
                          onPressed: () async {
                            if (_forgotPasswordFormKey.currentState!
                                .validate()) {
                              await appStateProvider.updatePassword(
                                  _idController.text,
                                  _newPasswordController.text);
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                  msg: "Password updated successfully",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              _clearForgotPasswordFields();
                       
                              Navigator.of(context).push(CupertinoPageRoute(builder: (context)=>SigninPage()));
                              
                              
                                
                            }
                          },
                          child: appStateProvider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.black)
                              : const Text('Done',
                                  style: TextStyle(color: Colors.white)),
                        ),
                        
                      ],
                    ),
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
