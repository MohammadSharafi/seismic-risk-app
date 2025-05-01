import 'package:flutter/foundation.dart';

enum TypeTextFormInput { userId, userName,phone }

class CustomTextFormFieldProvider extends ChangeNotifier {

  CustomTextFormFieldProvider(this.typeTextFormInput);
  String text = "";
  bool _isSubmitFormField = false;
  bool _isFocused = false;

  final TypeTextFormInput typeTextFormInput;

  void refresh() {
    notifyListeners();
  }

  void setText(String value) {
    text = value;
    notifyListeners();
  }



  bool get isSubmitted => _isSubmitFormField;
  bool get isFocused => _isFocused;
  void setIsFocused(bool value) {
    _isFocused = value;
    notifyListeners();
  }
}

class CustomMultiLineTextFormFieldProvider with ChangeNotifier {

  CustomMultiLineTextFormFieldProvider(this._lengthOfInputValue);
  int _lengthOfInputValue;

  int get lengthOfInputValue => _lengthOfInputValue;

  set lengthOfInputValue(int value) {
    _lengthOfInputValue = value;
    notifyListeners();
  }

  void changeState(String input) {
    lengthOfInputValue = input.length;

    notifyListeners();
  }
}
