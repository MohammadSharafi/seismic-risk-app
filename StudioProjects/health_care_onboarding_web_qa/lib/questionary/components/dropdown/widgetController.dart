import 'package:flutter/material.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/dropdown/src/drop_down.dart';

class WidgetNotifier with ChangeNotifier {
  dynamic _widgetValue;
  WeightUnit _weightUnit = WeightUnit.kg;
  HeightUnit _heightUnit = HeightUnit.cm;

  void setValue(dynamic value) {
    _widgetValue = value;
    notifyListeners();
  }

  dynamic get widgetValue => _widgetValue;

  set widgetValue(dynamic value) {
    _widgetValue = value;
    notifyListeners();
  }

  dynamic get value => _widgetValue;

  String get weightUnit => _weightUnit == WeightUnit.kg ? 'Kg' : 'Lbs';
  String get heightUnit => _heightUnit == HeightUnit.cm ? 'Cm' : 'Ft';
  WeightUnit get weightUnitByEnum => _weightUnit;
  HeightUnit get heightUnitByEnum => _heightUnit;
  void setWeightUnit(WeightUnit weightUnit) {
    _weightUnit = weightUnit;
    notifyListeners();
  }

  void setHeightUnit(HeightUnit heightUnit) {
    _heightUnit = heightUnit;
    notifyListeners();
  }
}
