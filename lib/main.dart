import 'package:cordrila_sysytems/controller/admin_request_provider.dart';
import 'package:cordrila_sysytems/controller/fresh_page_provider.dart';
import 'package:cordrila_sysytems/controller/profile_provider.dart';
import 'package:cordrila_sysytems/controller/shopping_page_provider.dart';
import 'package:cordrila_sysytems/controller/utr_provider.dart';
import 'package:cordrila_sysytems/view/admin_fresh.dart';
import 'package:cordrila_sysytems/view/admin_utr.dart';
import 'package:cordrila_sysytems/view/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controller/signinpage_provider.dart';
import 'controller/user_attendence_provider.dart';
import 'view/admin_shopping.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true);
  await clearOldAppData();
  FirebaseRemoteConfig remoteConfig = await setupRemoteConfig();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SigninpageProvider>(
          create: (context) => SigninpageProvider(),
        ),
        ChangeNotifierProvider<ShoppingPageProvider>(
          create: (context) => ShoppingPageProvider(),
        ),
        ChangeNotifierProvider<UtrpageProvider>(
          create: (context) => UtrpageProvider(),
        ),
        ChangeNotifierProvider<FreshPageProvider>(
          create: (context) => FreshPageProvider(),
        ),
        ChangeNotifierProvider<AteendenceProvider>(
          create: (context) => AteendenceProvider(),
        ),
        ChangeNotifierProvider<ProfilepageProvider>(
          create: (context) => ProfilepageProvider(),
        ),
        ChangeNotifierProvider<AdminRequestProvider>(
          create: (context) => AdminRequestProvider(),
        ),
        ChangeNotifierProvider<ShoppingFilterProvider>(
          create: (_) => ShoppingFilterProvider(),
        ),
        ChangeNotifierProvider<FreshFilterProvider>(
          create: (_) => FreshFilterProvider(),
        ),
        ChangeNotifierProvider<UtrFilterProvider>(
          create: (_) => UtrFilterProvider(),
        ),
      ],
      child: MyApp(remoteConfig: remoteConfig),
    ),
  );
}

Future<void> clearOldAppData() async {
  final prefs = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();

  String currentVersion = packageInfo.version;
  String savedVersion = prefs.getString('app_version') ?? '';

  if (currentVersion != savedVersion) {
    // App has been updated, clear the old data
    await prefs.clear(); // Clears all shared preferences
    // Optionally clear other cached data here

    // Save the new version
    await prefs.setString('app_version', currentVersion);
  }
}

class MyApp extends StatefulWidget {
  final FirebaseRemoteConfig remoteConfig;

  MyApp({Key? key, required this.remoteConfig}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Handle app lifecycle state changes (e.g., paused, resumed)
    if (state == AppLifecycleState.resumed) {
      // App resumed from background
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ShoppingPageProvider>(context, listen: false).updateTimestamp();
        Provider.of<FreshPageProvider>(context, listen: false).updateTimestamp();
        Provider.of<UtrpageProvider>(context, listen: false).updateTimestamp();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(remoteConfig: widget.remoteConfig),
    );
  }
}
