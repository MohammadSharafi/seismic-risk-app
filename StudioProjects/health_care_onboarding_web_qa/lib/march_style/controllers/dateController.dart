import 'package:flutter/material.dart';
import './age_calculator.dart';

class DateController with ChangeNotifier {

  DateController(
    this._controller,
  ) {
    if (_controller == null) {
      _controller = TextEditingController();
    } else {
      _controller = _controller;
    }
    if (_controller!.text.isNotEmpty) {
      _value = _controller!.text;
      notifyListeners();
    }
    _controller!.addListener(() {
      if (_value != _controller!.text.split('T').first) {
        hasChanges = true;
      }
      _value = _controller!.text.split('T').first;
      notifyListeners();
    });
  }
  TextEditingController? _controller;
  String _value = '';
  bool hasChanges = false;

  TextEditingController? get controller => _controller;

  void setDateValue(
    DateTime? value,
  ) {
    String age = AgeCalculator.age(value!).years.toString();
    _value = age;
    _controller!.text = age;
    notifyListeners();
  }

  String get value => _value;
}
