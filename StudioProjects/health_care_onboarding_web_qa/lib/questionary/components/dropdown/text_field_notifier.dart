import 'package:flutter/material.dart';

class TextFieldNotifier with ChangeNotifier {
  bool _visible = false;

  void makeVisible() {
    _visible = true;
    notifyListeners();
  }

  void changeVisibility() {
    _visible = !_visible;
    notifyListeners();
  }

  void makeInVisible() {
    _visible = false;
    notifyListeners();
  }

  bool get visibility => _visible;
}
