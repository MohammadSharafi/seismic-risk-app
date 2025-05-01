import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageUploadProgressProvider extends ChangeNotifier {

  ImageUploadProgressProvider() {}
  double _uiProgress = 0.0;
  void reset() {
    _uiProgress = 0.0;
    _progress = 0.0000001;
    _totalSize = 0.0000001;
    _showProgressBar = false;
    _showDownloadBar = false;

    notifyListeners();
  }

  void start() {
    _totalSize = _progress;
  }

  double get uiProgress => _uiProgress;

  set uiProgress(double value) {
    _uiProgress = value;
    notifyListeners();
  }

  double _progress = 0.0000001;
  double _totalSize = 0.0000001;
  bool _showProgressBar = false;
  bool _showDownloadBar = false;

  bool get showDownloadBar => _showDownloadBar;

  set showDownloadBar(bool value) {
    _showDownloadBar = value;
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }

  bool get showProgressBar => _showProgressBar;

  set showProgressBar(bool value) {
    _showProgressBar = value;
    notifyListeners();
  }

  double get totalSize => _totalSize;

  set totalSize(double value) {
    _totalSize = value;
    notifyListeners();
  }

  double get progress => _progress;

  set progress(double value) {
    _showProgressBar = true;
    _progress = value;
    if (_progress < _totalSize) {
      _showProgressBar = true;
    } else if (_progress == _totalSize) {
      _showProgressBar = false;
    }

    uiProgress = _progress / _totalSize;
  }
}
//1882587.0
