import 'package:cordrila_sysytems/controller/download_proivder.dart';
import 'package:cordrila_sysytems/controller/fresh_page_provider.dart';
import 'package:cordrila_sysytems/controller/notification_provider.dart';
import 'package:cordrila_sysytems/controller/profile_provider.dart';
import 'package:cordrila_sysytems/controller/shift_Controller.dart';
import 'package:cordrila_sysytems/controller/shift_shop_provider.dart';
import 'package:cordrila_sysytems/controller/shopping_page_provider.dart';
import 'package:cordrila_sysytems/controller/utr_provider.dart';
import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:cordrila_sysytems/controller/user_attendence_provider.dart';
import 'package:cordrila_sysytems/view/home.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SigninpageProvider> (
          create: (context) => SigninpageProvider(),
        ),
        ChangeNotifierProvider<FreshPageProvider> (
          create: (context) => FreshPageProvider(),
        ),
        ChangeNotifierProvider<ShiftProvider>(
          create: (context) => ShiftProvider([
            '1.  7 AM - 10 AM',
            '2.  10 AM - 1 PM',
            '3.  1 PM - 4 PM',
            '4.  4 PM - 7 PM',
            '5.  7 PM - 10 PM',
          ]),
        ),
        ChangeNotifierProvider<ShopProvider>(
          create: (context) => ShopProvider(
              ['Morning (before 12 PM)',
               'Evening (after 12 PM )']),
        ),
        ChangeNotifierProvider<ShoppingPageProvider>(
          create: (context) => ShoppingPageProvider(),
        ),
        ChangeNotifierProvider<UtrPageProvider>(
          create: (context) => UtrPageProvider(),
        ),
        ChangeNotifierProvider<DownloadProvider>(
          create: (context) => DownloadProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (context) => NotificationProvider(),
        ),
        ChangeNotifierProvider<AteendenceProvider>(
          create: (context) => AteendenceProvider(),
        ),
        ChangeNotifierProvider<ProfilepageProvider>(
          create: (context) => ProfilepageProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}



class MyApp extends StatefulWidget {
  MyApp({
    Key? key,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  Future<void> _initializeData() async {
    final signinpageprovider =
        Provider.of<SigninpageProvider>(context, listen: false);
    bool isLoggedIn = await signinpageprovider.loadUserData();
    if (isLoggedIn) {
      final empCode = signinpageprovider.userData?['EmpCode'] ?? '';
      await Future.wait([
        Provider.of<ShoppingPageProvider>(context, listen: false)
            .initializeData(empCode),
        Provider.of<FreshPageProvider>(context, listen: false)
            .initializeData(empCode),
        Provider.of<UtrPageProvider>(context, listen: false)
            .initializeData(empCode),
      ]);
    }
  }

  void _refreshData() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
