import 'package:flutter/material.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/dropdown/src/drop_down.dart';


class SelectNoneNotifier with ChangeNotifier {

  SelectNoneNotifier(List<SelectedListItem> mainList, bool isMulti,
      String selectedValue, bool isSelectNone) {
    _selected = isSelectNone;
    _isMulti = isMulti;
    _mainList = List.from(mainList);
    _filteredList = List.from(mainList);

    if (!isMulti && selectedValue.isNotEmpty) {
      int selectedIndex = -1;
      for (final element in _mainList) {
        element.isSelected = false;
        if (element.name.contains(selectedValue)) {
          selectedIndex = _mainList.indexOf(element);
        }
      }
      if (selectedIndex >= 0) _mainList[selectedIndex].isSelected = true;
    }

    notifyListeners();
  }
  bool _selected = false;
  bool _otherSelected = false;

  bool get otherSelected => _otherSelected;

  set otherSelected(bool value) {
    _otherSelected = value;
    notifyListeners();
  }

  bool _isMulti = false;
  List<SelectedListItem> _mainList = [];
  List<SelectedListItem> _filteredList = [];
  List<String> selectedList = [];
  bool _description_open = false;

  bool get description_open => _description_open;

  set description_open(bool value) {
    _description_open = value;
    notifyListeners();
  }
  bool _inSearchMode = false;

  bool get inSearchMode => _inSearchMode;

  set inSearchMode(bool value) {
    _inSearchMode = value;
    notifyListeners();
  }

  void changeSelection(bool value) {
    _selected = value;
    if (value) {
      for (int index = 0; index < _filteredList.length; index++) {
        _filteredList[index].isSelected = false;
      }
    }
    notifyListeners();
  }

  void changeOtherSelection() {
    _otherSelected = !_otherSelected;

    notifyListeners();
  }

  bool get isSelected => _selected;

  List<SelectedListItem> get filteredList => _filteredList;

  set filteredList(List<SelectedListItem> value) {
    _filteredList = value;
  }

  List<SelectedListItem> get mainList => _mainList;

  void setlist(List<SelectedListItem> list) {
    _filteredList = list;
    if (_filteredList.length != _mainList.length) {
      _inSearchMode = true;
    } else {
      _inSearchMode = false;
    }
    notifyListeners();
  }

  void changeListItem(bool listItem, int index) {
    if (!_isMulti) {
      if (listItem) {
        for (int index = 0; index < _filteredList.length; index++) {
          _filteredList[index].isSelected = false;
        }
        _filteredList[index].isSelected = true;
      }
    } else {
      _filteredList[index].isSelected = listItem;
      if (listItem) {
        _selected = false;
      } else {
        bool selected_item_exist = false;
        for (final element in _filteredList) {
          if (element.isSelected) {
            selected_item_exist = true;
          }
        }
        if (selected_item_exist) {
          _selected = false;
        }
      }
    }
    notifyListeners();
  }
}
