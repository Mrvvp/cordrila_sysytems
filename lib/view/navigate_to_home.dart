import 'package:cordrila_sysytems/controller/signinpage_provider.dart';
import 'package:cordrila_sysytems/view/fresh_page.dart';
import 'package:cordrila_sysytems/view/shopping_page.dart';
import 'package:cordrila_sysytems/view/utr_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void navigateToHomePage(
    BuildContext context, SigninpageProvider appStateProvider, String userId) {
  final userType = appStateProvider.userData?['Location'] ?? '';
//

  if (userType == 'SHOPPING') {
    Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => ShoppingPage(userId: userId)));
  } else if (userType == 'UTR') {
    Navigator.of(context).pushReplacement(CupertinoPageRoute(
        builder: (context) => UtrPage(
              userId: userId,
            )));
  } else if (userType == 'FRESH') {
    Navigator.of(context).pushReplacement(CupertinoPageRoute(
        builder: (context) => FreshPage(
              userId: userId,
            )));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unknown user type')),
    );
  }
}
