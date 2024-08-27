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
import 'package:url_launcher/url_launcher.dart';

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
    bool permissionsGranted2 = await _requestPermissions2();
    if (permissionsGranted || permissionsGranted2) {
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

    bool storageGranted = statuses[Permission.storage]?.isGranted ?? false;
    bool installGranted = Platform.isAndroid
        ? (statuses[Permission.requestInstallPackages]?.isGranted ?? false)
        : true;

    if (!storageGranted) {
      print('Storage permission denied');
    }

    if (Platform.isAndroid && !installGranted) {
      print('Install packages permission denied');
    }

    return storageGranted && (Platform.isIOS || installGranted);
  }

  Future<bool> _requestPermissions2() async {
    // Request necessary permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.requestInstallPackages,
    ].request();

    bool storageGranted =
        statuses[Permission.manageExternalStorage]?.isGranted ?? false;
    bool installGranted =
        statuses[Permission.requestInstallPackages]?.isGranted ?? false;

    if (!storageGranted) {
      print('Storage permission denied');
    }

    if (!installGranted) {
      print('Install packages permission denied');
    }

    return storageGranted && installGranted;
  }

  Future<void> _checkUpdateRequired() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('appupdate')
          .doc('27o1NoiNpHQXUF5OvTVL')
          .get();

      if (snapshot.exists) {
        bool updateRequired = snapshot.get('updatev3');
        if (updateRequired) {
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

    // Get the app-specific storage directory
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

      if (Platform.isAndroid) {
        final hasInstallPermission =
            await Permission.requestInstallPackages.isGranted;
        if (!hasInstallPermission) {
          openAppSettings();
        } else {
          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to open file: ${result.message}')),
            );
          }
        }
      } else {
        // Handle iOS case if needed
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('New Version Available',
                        style: TextStyle(fontSize: 15, fontFamily: 'Poppins')),
                    SizedBox(height: 10),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.02,
                      child: LinearProgressIndicator(
                        color: Colors.green,
                        value: downloadProvider.progress,
                      ),
                    ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  Lottie.asset(
                    'assets/animations/Animation - 1721214756608.json',
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 8),
                    child: Text(
                      'പുതിയ അപ്ഡേറ്റ് വരുമ്പോൾ എന്തെങ്കിലും പ്രശ്നം നേരിട്ടാൽ Cordrila വെബ് സൈറ്റിൽ കയറി Install ചെയ്യുക നന്ദി.',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 8),
                    child: Row(
                      children: [
                        Text(
                        'Click the link :',
                        style:
                            TextStyle(fontSize: 12, fontWeight: FontWeight.bold,fontFamily: 'Poppins'),
                      ),
                        TextButton(
                          onPressed: () async {
                            final Uri url = Uri.parse('https://cordrila.com/apk');
                            if (!await launchUrl(url,
                                mode: LaunchMode.externalApplication)) {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Text(
                            'https://cordrila.com/apk',
                            style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),
                  )
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
