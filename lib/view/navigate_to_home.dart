import 'package:cordrila_sysytems/view/utr_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cordrila_sysytems/view/admin_landing_page.dart';
import 'package:cordrila_sysytems/view/fresh_page.dart';
import 'package:cordrila_sysytems/view/shopping_page.dart';
import 'package:cordrila_sysytems/controller/signinpage_provider.dart';

void navigateToHomePage(
    BuildContext context, SigninpageProvider appStateProvider) {
  final userType = appStateProvider.userData?['Location'];

  if (userType == 'Shopping') {
    Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const ShoppingPage()));
  } else if (userType == 'UTR') {
    Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const UtrPage()));
  } else if (userType == 'Fresh') {
    Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const FreshPage()));
  } else if (userType == 'Admin') {
    Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const AdminLandingpage()));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unknown user type')),
    );
  }
}
