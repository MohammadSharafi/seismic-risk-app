import 'package:flutter/material.dart';

class UploadProgressProvider extends ChangeNotifier {
  double? _progress;
  double? _totalSize;

  double? get progress => _progress;

  set progress(double? value) {
    _progress = value;
    notifyListeners();
  }

  double? get totalSize => _totalSize;

  set totalSize(double? value) {
    _totalSize = value;
    notifyListeners();
  }
}
