import 'package:flutter/material.dart';

class DownloadProvider with ChangeNotifier {
  double _progress = 0.0;
  bool _isDownloading = false;
  bool _isDownloaded = false;

  double get progress => _progress;
  bool get isDownloading => _isDownloading;
  bool get isDownloaded => _isDownloaded;

  void setProgress(double value) {
    _progress = value;
    notifyListeners();
  }

  void setDownloading(bool value) {
    _isDownloading = value;
    notifyListeners();
  }

  void setDownloaded(bool value) {
    _isDownloaded = value;
    notifyListeners();
  }
}
