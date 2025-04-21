import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CustomCheckbox extends StatelessWidget {
  final String selectedSvgPath;
  final Widget unselectedWidget;
  final double iconSize;
  final String item;
  final ValueChanged<Item> onTap;

  CustomCheckbox({
    required this.selectedSvgPath,
    required this.unselectedWidget,
    required this.iconSize,
    required this.onTap,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckboxModel(),
      child: Consumer<CheckboxModel>(
        builder: (context, checkboxModel, _) {
          return GestureDetector(
            onTap: () {
              checkboxModel.toggle();
              onTap.call(Item(isSelected:checkboxModel.isSelected,name: item ));
            },
            child: checkboxModel.isSelected
                ? SvgPicture.asset(
              selectedSvgPath,
              width: iconSize,
              height: iconSize,
            )
                : unselectedWidget,
          );
        },
      ),
    );
  }
}

class CheckboxModel with ChangeNotifier {
  bool isSelected;

  CheckboxModel({this.isSelected = false});

  void toggle() {
    isSelected = !isSelected;
    notifyListeners();
  }
}


class Item with ChangeNotifier {
  bool isSelected;
  String name;

  Item( {this.isSelected = false,required this.name});


}
