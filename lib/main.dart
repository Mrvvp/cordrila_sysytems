import 'package:cordrila_sysytems/controller/admin_request_provider.dart';
import 'package:cordrila_sysytems/controller/fresh_page_provider.dart';
import 'package:cordrila_sysytems/controller/profile_provider.dart';
import 'package:cordrila_sysytems/controller/shift_Controller.dart';
import 'package:cordrila_sysytems/controller/shift_shop_provider.dart';
import 'package:cordrila_sysytems/controller/shopping_page_provider.dart';
import 'package:cordrila_sysytems/controller/utr_provider.dart';
import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:cordrila_sysytems/controller/user_attendence_provider.dart';
import 'package:cordrila_sysytems/view/admin_fresh.dart';
import 'package:cordrila_sysytems/view/admin_utr.dart';
import 'package:cordrila_sysytems/view/admin_shopping.dart';
import 'package:cordrila_sysytems/view/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true);
  FirebaseRemoteConfig remoteConfig = await setupRemoteConfig();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SigninpageProvider>(
          create: (context) => SigninpageProvider(),
        ),
        ChangeNotifierProvider<FreshPageProvider>(
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

Future<FirebaseRemoteConfig> setupRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  try {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
  } catch (e) {
    print('Error fetching remote config: $e');
  }
  return remoteConfig;
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
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final signinpageprovider =
            Provider.of<SigninpageProvider>(context, listen: false);
        final empCode = signinpageprovider.userData?['EmpCode'] ?? '';
        Provider.of<ShoppingPageProvider>(context, listen: false)
            .initializeData(empCode);
        Provider.of<FreshPageProvider>(context, listen: false).initializeData();
        Provider.of<UtrPageProvider>(context, listen: false).initializeData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(remoteConfig: widget.remoteConfig,),
    );
  }
}
