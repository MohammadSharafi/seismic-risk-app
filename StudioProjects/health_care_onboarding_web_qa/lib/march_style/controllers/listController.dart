import 'package:flutter/material.dart';

import '../../questionary/components/dropdown/src/drop_down.dart';


class ListController with ChangeNotifier {

  ListController({this.optionalList}) {
    if (optionalList != null) {}
  }
  List<dynamic> _list = [];
  List<SelectedListItem>? optionalList;
  bool _selectNone = false;
  bool _selectOther = false;

  bool get selectOther => _selectOther;

  void changeValue(int index, bool value) {
    optionalList![index].isSelected = value;
    notifyListeners();
  }

  List<SelectedListItem> getSelectedList() {
    List<SelectedListItem> list = [];
    optionalList!.forEach((element) {
      if (element.isSelected) {
        list.add(element);
      }
    });

    return list;
  }

  void refresh() {
    // Add your code here to refresh the list
    notifyListeners();
  }

  set selectOther(bool value) {
    _selectOther = value;
    if (_selectOther) {
      _selectNone = false;
    }
    notifyListeners();
  }

  bool get selectNone => _selectNone;

  set selectNone(bool value) {
    _selectNone = value;
    if (_selectNone) {
      _selectOther = false;
    }
    notifyListeners();
  }

  void setListValue(List<dynamic> list) {
    _list = list;
    if (optionalList != null) {
      list.forEach((element) {
        //if((element as SelectedListItem).isSelected)
        //{
        optionalList!.forEach((elementOp) {
          if (elementOp.enumValue
              .toString()
              .contains(element.enumValue.toString().split('.').last)) {
            int index = optionalList!.indexOf(elementOp);
            optionalList![index] = element;
            optionalList![index].isSelected = true;
          }
        });
        //}
      });
    }

    notifyListeners();
  }

  void updateListValue() {
    if (optionalList != null) {
      list.forEach((element) {
        //if((element as SelectedListItem).isSelected)
        //{
        optionalList!.forEach((elementOp) {
          if (elementOp.enumValue
              .toString()
              .contains(element.enumValue.toString().split('.').last)) {
            int index = optionalList!.indexOf(elementOp);
            optionalList![index] = element;
            optionalList![index].isSelected = true;
          }
        });
        //}
      });
    }

    notifyListeners();
  }

  List<dynamic> get list => _list;
}




