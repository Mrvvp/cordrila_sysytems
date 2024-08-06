import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:cordrila_sysytems/view/navigate_to_home.dart';
import 'package:cordrila_sysytems/view/sign_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const platform = MethodChannel('com.example.yourapp/time');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutomaticTimeSetting();
    });
  }

  Future<void> _checkAutomaticTimeSetting() async {
    bool isAutomaticTimeEnabled;
    try {
      final bool result = await platform.invokeMethod('isAutomaticTimeEnabled');
      isAutomaticTimeEnabled = result;
    } on PlatformException catch (e) {
      isAutomaticTimeEnabled = true; // Assume it's enabled if there's an error
      print("Failed to get automatic time setting: '${e.message}'.");
    }

    if (!isAutomaticTimeEnabled) {
      _showAlertDialog();
    } else {
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    // Delay for splash screen duration
    await Future.delayed(const Duration(milliseconds: 3000));

    final appStateProvider =
        Provider.of<SigninpageProvider>(context, listen: false);
    bool isLoggedIn = await appStateProvider.loadUserData();

    if (isLoggedIn) {
      String userId = appStateProvider.userData?['EmpCode']; // Extract userId from userData
      navigateToHomePage(context, appStateProvider, userId);
    } else {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const SigninPage()),
      );
    }
  }

  void _showAlertDialog() {
    showDialog(
      barrierColor: Colors.grey.shade400,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text(
            'Automatic Time Setting Disabled!',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Please enable automatic time setting in your device.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                'assets/images/photo_2024-05-14_10-22-21.jpg',
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Cordrila',
            style: TextStyle(
                color: Colors.black, fontSize: 25, fontFamily: 'Poppins'),
          ),
          Text(
            'Infrastructure Private Limited',
            style: TextStyle(
                color: Colors.black, fontSize: 6, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
}
