import 'package:cordrila_sysytems/controller/attendence_monthly_provider.dart';
import 'package:cordrila_sysytems/controller/download_proivder.dart';
import 'package:cordrila_sysytems/controller/fresh1_controller.dart';
import 'package:cordrila_sysytems/controller/fresh1_shift.dart';
import 'package:cordrila_sysytems/controller/fresh_page_provider.dart';
import 'package:cordrila_sysytems/controller/notification_provider.dart';
import 'package:cordrila_sysytems/controller/profile_provider.dart';
import 'package:cordrila_sysytems/controller/profile_update_provider.dart';
import 'package:cordrila_sysytems/controller/shift_Controller.dart';
import 'package:cordrila_sysytems/controller/shift_shop_provider.dart';
import 'package:cordrila_sysytems/controller/shopping_page_provider.dart';
import 'package:cordrila_sysytems/controller/user_attendence_provider.dart';
import 'package:cordrila_sysytems/controller/utr_provider.dart';
import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
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
        ChangeNotifierProvider<SigninpageProvider>(
          create: (context) => SigninpageProvider(),
        ),
        ChangeNotifierProvider<FreshPageProvider>(
          create: (context) => FreshPageProvider(),
        ),
        ChangeNotifierProvider<Fresh1PageProvider>(
          create: (context) => Fresh1PageProvider(),
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
        ChangeNotifierProvider<Fresh1ShiftProvider>(
            create: (context) => Fresh1ShiftProvider([
                  '1.  9 AM - 12 PM',
                  '2.  12 PM - 3 PM',
                  '3.  3 PM - 6 PM',
                  '4.  6 PM - 9 PM',
                ])),
        ChangeNotifierProvider<ShopProvider>(
          create: (context) => ShopProvider(
              ['Morning (before 12 PM)', 'Evening (after 12 PM )']),
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
        ChangeNotifierProvider<AttendanceMonthlyProvider>(
          create: (context) => AttendanceMonthlyProvider(),
        ),
        ChangeNotifierProvider<ProfilepageProvider>(
          create: (context) => ProfilepageProvider(),
        ),
        ChangeNotifierProvider<ProfileUpdateProvider>(
          create: (context) => ProfileUpdateProvider(),
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

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
