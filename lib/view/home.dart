// import 'dart:io';
// import 'package:cordrila_sysytems/controller/download_proivder.dart';
// import 'package:cordrila_sysytems/view/splash_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:open_file/open_file.dart';
// import 'package:permission_handler/permission_handler.dart';

// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   String downloadedFilePath = '';

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     bool permissionsGranted = await _requestPermissions();
//     if (permissionsGranted) {
//       await _checkUpdateRequired();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(
//                 'Permissions are required to download and install the update.')),
//       );
//     }
//   }

//   Future<bool> _requestPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.storage,
//       if (Platform.isAndroid) Permission.requestInstallPackages,
//     ].request();

//     return statuses[Permission.storage]!.isGranted &&
//         (Platform.isIOS ||
//             statuses[Permission.requestInstallPackages]!.isGranted);
//   }

//   Future<void> _checkUpdateRequired() async {
//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('appupdate')
//           .doc('27o1NoiNpHQXUF5OvTVL')
//           .get();

//       if (snapshot.exists) {
//         bool updateRequired = snapshot.get('update');
//         if (updateRequired) {
//           _showUpdateAlert(
//               'https://firebasestorage.googleapis.com/v0/b/cordrila.appspot.com/o/Cordrila(H).apk?alt=media&token=430513c9-9d5c-475b-9efb-37fa10ef5636');
//         } else {
//           _navigateToSplashScreen();
//         }
//       } else {
//         print('Document does not exist');
//         _navigateToSplashScreen();
//       }
//     } catch (e) {
//       print('Error checking update: $e');
//       _navigateToSplashScreen();
//     }
//   }

//   Future<void> _showUpdateAlert(String url) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           title: Text('Good News', style: TextStyle(fontSize: 20)),
//           content: Consumer<DownloadProvider>(
//             builder: (context, downloadProvider, child) {
//               if (downloadProvider.isDownloading) {
//                 return Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     LinearProgressIndicator(value: downloadProvider.progress),
//                     SizedBox(height: 20),
//                     Text(
//                         '${(downloadProvider.progress * 100).toStringAsFixed(2)}%'),
//                   ],
//                 );
//               } else if (downloadProvider.isDownloaded) {
//                 return Text(
//                     "Download completed. The installer will open automatically.");
//               } else {
//                 return const Text("Version 1.2.7. Available");
//               }
//             },
//           ),
//           actions: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 shape: ContinuousRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(15))),
//                 backgroundColor: Colors.blue,
//               ),
//               onPressed: () async {
//                 final downloadProvider =
//                     Provider.of<DownloadProvider>(context, listen: false);
//                 if (!downloadProvider.isDownloading) {
//                   Navigator.of(context).pop(); // Close the dialog
//                   await _downloadFile(url);
//                 }
//               },
//               child: Consumer<DownloadProvider>(
//                 builder: (context, downloadProvider, child) {
//                   return Text(
//                     downloadProvider.isDownloading
//                         ? 'Downloading...'
//                         : 'Update',
//                     style: TextStyle(color: Colors.white),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//  Future<void> _downloadFile(String url) async {
//   final dio = Dio();
//   final downloadProvider = Provider.of<DownloadProvider>(context, listen: false);

//   final downloadDirectory = await getExternalStorageDirectory();
//   final filePath = '${downloadDirectory!.path}/Cordrila.apk';

//   try {
//     downloadProvider.setDownloading(true);

//     await dio.download(
//       url,
//       filePath,
//       onReceiveProgress: (received, total) {
//         if (total != -1) {
//           double progress = received / total;
//           downloadProvider.setProgress(progress);
//         }
//       },
//     );

//     downloadProvider.setDownloading(false);
//     downloadProvider.setDownloaded(true);
//     setState(() {
//       downloadedFilePath = filePath;
//     });

//     // Open the APK file using open_file package
//     final result = await OpenFile.open(filePath);
//     if (result.type != ResultType.done) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to open file: ${result.message}')),
//       );
//     }
//   } catch (e) {
//     print('Download failed: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Download failed: $e')),
//     );
//     downloadProvider.setDownloading(false);
//   }
// }

//   void _navigateToSplashScreen() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => SplashScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Consumer<DownloadProvider>(
//         builder: (context, downloadProvider, child) {
//           if (downloadProvider.isDownloading) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   LinearProgressIndicator(value: downloadProvider.progress),
//                   SizedBox(height: 20),
//                   Text(
//                       '${(downloadProvider.progress * 100).toStringAsFixed(2)}%'),
//                 ],
//               ),
//             );
//           } else if (downloadProvider.isDownloaded) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('Download completed:'),
//                   SizedBox(height: 10),
//                   GestureDetector(
//                     onTap: () async {
//                       await OpenFile.open(downloadedFilePath);
//                     },
//                     child: Text(
//                       downloadedFilePath,
//                       style: TextStyle(
//                           color: Colors.blue,
//                           decoration: TextDecoration.underline),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           } else {
//             return Center(
//                 child: Lottie.asset(
//               'assets/animations/Animation - 1722594040196.json',
//               fit: BoxFit.contain,
//             ));
//           }
//         },
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:cordrila_sysytems/controller/download_proivder.dart';
import 'package:cordrila_sysytems/view/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String downloadedFilePath = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    bool permissionsGranted = await _requestPermissions();
    if (permissionsGranted) {
      await _checkUpdateRequired();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Permissions are required to download and install the update.'),
        ),
      );
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      if (Platform.isAndroid) Permission.requestInstallPackages,
    ].request();

    return statuses[Permission.storage]!.isGranted &&
        (Platform.isIOS ||
            statuses[Permission.requestInstallPackages]!.isGranted);
  }

  Future<void> _checkUpdateRequired() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('appupdate')
          .doc('27o1NoiNpHQXUF5OvTVL')
          .get();

      if (snapshot.exists) {
        bool updateRequired = snapshot.get('update');
        if (updateRequired) {
          // Directly download the update without showing a dialog
          await _downloadFile(
              'https://firebasestorage.googleapis.com/v0/b/cordrila.appspot.com/o/Cordrila(H).apk?alt=media&token=430513c9-9d5c-475b-9efb-37fa10ef5636');
        } else {
          _navigateToSplashScreen();
        }
      } else {
        print('Document does not exist');
        _navigateToSplashScreen();
      }
    } catch (e) {
      print('Error checking update: $e');
      _navigateToSplashScreen();
    }
  }

  Future<void> _downloadFile(String url) async {
    final dio = Dio();
    final downloadProvider =
        Provider.of<DownloadProvider>(context, listen: false);

    final downloadDirectory = await getExternalStorageDirectory();
    final filePath = '${downloadDirectory!.path}/Cordrila.apk';

    try {
      downloadProvider.setDownloading(true);

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = received / total;
            downloadProvider.setProgress(progress);
          }
        },
      );

      downloadProvider.setDownloading(false);
      downloadProvider.setDownloaded(true);
      setState(() {
        downloadedFilePath = filePath;
      });

      // Open the APK file using open_file package
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open file: ${result.message}')),
        );
      }
    } catch (e) {
      print('Download failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
      downloadProvider.setDownloading(false);
    }
  }

  void _navigateToSplashScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<DownloadProvider>(
        builder: (context, downloadProvider, child) {
          if (downloadProvider.isDownloading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('New Version Available', style: TextStyle(fontSize: 15, fontFamily: 'Poppins'),),
                    SizedBox(height: 10,),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.02,
                        child: LinearProgressIndicator(
                            color: Colors.green,
                            value: downloadProvider.progress)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(downloadProvider.progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 20, fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (downloadProvider.isDownloaded) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  Lottie.asset(
                    'assets/animations/Animation - 1721214756608.json',
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Lottie.asset(
                'assets/animations/Animation - 1722594040196.json',
                fit: BoxFit.contain,
              ),
            );
          }
        },
      ),
    );
  }
}
