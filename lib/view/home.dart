import 'package:cordrila_sysytems/view/splash_screen.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class Home extends StatefulWidget {
  final FirebaseRemoteConfig remoteConfig;

  const Home({super.key, required this.remoteConfig});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var update = widget.remoteConfig.getBool("Updatev2");
    return Scaffold(
      backgroundColor: Colors.grey[500],
      body: update
          ? showAlertDialog(context, widget.remoteConfig)
          : const SplashScreen(),
    );
  }
}

Future<FirebaseRemoteConfig> setupRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ),
  );

  try {
    await remoteConfig.fetch();
    await remoteConfig.activate();
  } catch (e) {
    print("Error setting up remote config: $e");
  }

  return remoteConfig;
}

Future<void> launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  try {
    await launch(uri.toString());
  } catch (e) {
    print('Error launching URL: $e');
  }
}

Widget showAlertDialog(BuildContext context, FirebaseRemoteConfig remoteConfig) {
  Widget updateButton = SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () async {
        const url = "https://cordrila.com/apk";
        try {
          await launchURL(url);
        } catch (e) {
          print('Error launching URL: $e');
        }
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.blue[500],
      ),
      child: const Text(
        "Update",
        style: TextStyle(
          fontSize: 19,
          color: Colors.white,
        ),
      ),
    ),
  );

  return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: Colors.white,
    title: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/software-update.png', // Replace with your GIF asset path
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          Text(
            remoteConfig.getString("Title"),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          
        
          const SizedBox(height: 20),
          updateButton,
        ],
      ),
    ),
  );
}