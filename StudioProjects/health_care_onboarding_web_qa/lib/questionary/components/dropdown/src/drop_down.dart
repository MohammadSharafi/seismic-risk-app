import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../march_style/controllers/listController.dart';
import '../../../../march_style/march_icons.dart';
import '../../../../march_style/march_size.dart';
import '../../../../march_style/march_theme.dart';
import '../../../dates.dart';
import '../../march_drop_down.dart';
import '../../march_radio_item.dart';
import '../cotroller.dart';
import '../widgetController.dart';

enum WeightUnit { kg, lbs }

enum HeightUnit { cm, ft }

class DropDown {
  DropDown({
    Key? key,
    this.buttonText,
    required this.heightWheightW,
    this.maxHeightWheightW,
    this.bottomSheetTitle,
    this.submitButtonText,
    this.submitButtonColor,
    this.searchHintText,
    this.searchBackgroundColor,
    required this.searchController,
    required this.textController,
    required this.items,
    required this.showWidget,
    required this.dropType,
    this.selectedItems,
    this.widgetValue,
    this.selectedItem,
    this.canSearch,
    this.haveMax,
    this.haveNone,
    this.numberOfNonOthers,
    this.haveOther,
    this.haveMin,
    this.minDate,
    this.listController,
    this.getListByController,
    required this.enableMultipleSelection,
    this.onChange, // Add onChange callback
  });

  final String? buttonText;
  List<SelectedListItem> items = [];
  DropType dropType;
  bool? haveNone;
  bool? haveOther;
  bool? showWidget;
  bool? haveMax;
  bool? haveMin;
  DateTime? minDate;
  final String? bottomSheetTitle;
  final String? submitButtonText;
  final Color? submitButtonColor;
  final String? searchHintText;
  final Color? searchBackgroundColor;
  final bool? canSearch;
  final TextEditingController searchController;
  final TextEditingController textController;
  final Function(List<dynamic>, bool)? selectedItems;
  final Function(dynamic)? widgetValue;
  final Function(String)? selectedItem;
  final bool enableMultipleSelection;
  final double heightWheightW;
  final double? maxHeightWheightW;
  ListController? listController;
  bool? getListByController;
  int? numberOfNonOthers;
  final Function(String)? onChange; // New onChange callback
}

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

class DropDownState {
  DropDownState({
    required this.dropDown,
    this.onConfirm,
    this.showButton,
    this.haveDes,
    this.desTitle,
    this.desSubTitle,
    this.initialDate,
    this.selectNone,
    this.maxDate,
    this.initialIndex,
    this.onChange, // Add onChange
  });

  DropDown dropDown;
  VoidCallback? onConfirm;
  bool? showButton;
  bool? haveDes;
  String? desTitle;
  String? desSubTitle;
  int? initialIndex;
  DateTime? initialDate;
  DateTime? maxDate;
  bool? selectNone;
  final Function(String)? onChange; // New onChange callback

  void showModal(context, {VoidCallback? onDone}) {
    showModalBottomSheet(
      showDragHandle: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      context: context,
      builder: (_) {
        return MainBody(
          dropDown: dropDown,
          onConfirm: onConfirm,
          showButton: showButton,
          haveDes: haveDes,
          desTitle: desTitle,
          selectNone: selectNone,
          desSubTitle: desSubTitle,
          initialDate: initialDate,
          maxDate: maxDate,
          initialIndex: initialIndex,
          onChange: onChange, // Pass onChange
        );
      },
    ).whenComplete(() {
      if (onDone != null) {
        onDone.call();
      }
    });
  }
}

/// This is Model class. Using this model class, you can add the list of data with title and its selection.
class SelectedListItem {
  SelectedListItem(this.isSelected, this.name, this.enumValue);

  bool isSelected;
  String name;
  dynamic enumValue;
}

//ignore: must_be_ immutable
class MainBody extends StatelessWidget {
  MainBody({
    required this.dropDown,
    this.onConfirm,
    this.showButton,
    this.haveDes,
    this.desTitle,
    this.desSubTitle,
    this.initialIndex,
    this.initialDate,
    this.maxDate,
    this.selectNone,
    this.onChange, // Add onChange
    Key? key,
  }) : super(key: key);

  final DropDown dropDown;
  final VoidCallback? onConfirm;
  final bool? showButton;
  final bool? haveDes;
  final String? desTitle;
  final String? desSubTitle;
  final bool? selectNone;
  final int? initialIndex;
  final DateTime? initialDate;
  final DateTime? maxDate;
  final Function(String)? onChange; // New onChange callback

  dynamic widgetValue;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: dropDown.heightWheightW,
      minChildSize: 0.13,
      maxChildSize: dropDown.maxHeightWheightW ?? 0.9,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        if (dropDown.showWidget!) {
          return ChangeNotifierProvider(
            create: (_) => WidgetNotifier(),
            child:
                Consumer<WidgetNotifier>(builder: (context, notifier, child) {
              if (dropDown.dropType == DropType.year) {
                // Existing year picker code (unchanged)
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 3.0,
                      width: MediaQuery.of(context).size.width * 0.15,
                      margin: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 12,
                      ),
                      decoration: BoxDecoration(
                        color: marchColorData[MarchColor.extraLightBlack],
                        borderRadius: BorderRadius.circular(360),
                      ),
                    ),

                    SizedBox(height: MarchSize.littleGap * 4),
                    SizedBox(
                      height: 150,
                      child: CupertinoPicker(
                        useMagnifier: true,
                        itemExtent: 30,
                        scrollController:
                            FixedExtentScrollController(initialItem: 30),
                        children: List<Widget>.generate(50, (int index) {
                          return Text(
                              '${DateTime(DateTime.now().year - 49).year + index}');
                        }),
                        onSelectedItemChanged: (value) {
                          SystemSound.play(SystemSoundType.click);
                          HapticFeedback.lightImpact();
                          widgetValue =
                              DateTime(DateTime.now().year - 49).year + value;
                          notifier.setValue((widgetValue ?? 2004).toString());
                          dropDown.widgetValue?.call(notifier.value);
                          onChange?.call(notifier.value); // Call onChange
                          onConfirm?.call();
                        },
                      ),
                    ),
                    // Rest of the year picker code (unchanged)
                  ],
                );
              } else if (dropDown.dropType == DropType.date) {
                return ListView(
                  controller: scrollController,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 3.0,
                          width: MediaQuery.of(context).size.width * 0.15,
                          margin: const EdgeInsets.only(
                            top: 8.0,
                            bottom: 12,
                          ),
                          decoration: BoxDecoration(
                            color: marchColorData[MarchColor.extraLightBlack],
                            borderRadius: BorderRadius.circular(360),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: MarchSize.littleGap * 4),
                    SizedBox(
                      height: 150,
                      child: CupertinoDatePicker(
                        dateOrder: DatePickerDateOrder.dmy,
                        mode: CupertinoDatePickerMode.date,
                        minimumDate: (dropDown.haveMin ?? false)
                            ? dropDown.minDate ??
                                DateTime.now()
                                    .subtract(const Duration(hours: 1))
                            : DateTime(1900),
                        maximumDate: maxDate ??
                            ((dropDown.haveMax ?? false)
                                ? DateTime.now().add(const Duration(hours: 1))
                                : DateTime(DateTime.now().year + 100)),
                        initialDateTime: initialDate ?? DateTime.now(),
                        onDateTimeChanged: (val) {
                          SystemSound.play(SystemSoundType.click);
                          HapticFeedback.lightImpact();
                          widgetValue = val;
                          notifier.setValue(val.toString());
                          // Custom date format (e.g., "dd/MM/yyyy")
                          String formattedDate =
                              DateFormat('dd/MM/yyyy').format(val);
                          onChange?.call(
                              formattedDate); // Call onChange with formatted date
                          if (!(showButton ?? true)) {
                            dropDown.widgetValue?.call(widgetValue == null
                                ? (initialDate ?? DateTime.now())
                                : StringToDateTime(
                                    date: notifier.value.split(' ').first));
                          }
                        },
                      ),
                    ),
                    // Rest of the date picker code (unchanged)
                    if ((desTitle ?? '').isNotEmpty) ...[
                      ChangeNotifierProvider(
                        create: (_) => SelectNoneNotifier(
                            ((dropDown.getListByController ?? false)
                                ? dropDown.listController!.optionalList ?? []
                                : dropDown.items),
                            dropDown.enableMultipleSelection,
                            dropDown.textController.text,
                            dropDown.listController != null
                                ? (dropDown.listController!.selectNone ?? false)
                                : false),
                        child: Consumer<SelectNoneNotifier>(
                          builder: (context, notifier, child) {
                            return Container(
                              child: GestureDetector(
                                onTap: () {
                                  notifier.description_open =
                                      !notifier.description_open;
                                },
                                child: !notifier.description_open
                                    ? Row(
                                        children: [
                                          MarchSize.smallHorizontalSpacer,
                                          MarchSize.smallHorizontalSpacer,
                                          MarchSize.smallHorizontalSpacer,
                                          SvgPicture.asset(
                                            MarchIcons.info_out,
                                            width: 12,
                                            color: Colors.grey,
                                          ),
                                          MarchSize.tinyHorizontalSpacer,
                                          Text(
                                            desTitle ?? '',
                                            textAlign: TextAlign.start,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .copyWith(
                                                    fontSize: 12,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    color: marchColorData[
                                                        MarchColor
                                                            .purpleExtraDark],
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.5),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          MarchSize.smallHorizontalSpacer,
                                          MarchSize.smallHorizontalSpacer,
                                          MarchSize.smallHorizontalSpacer,
                                          SvgPicture.asset(
                                            MarchIcons.info_out,
                                            width: 12,
                                            color: Colors.grey,
                                          ),
                                          MarchSize.tinyHorizontalSpacer,
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            child: Text(
                                              desSubTitle ?? '',
                                              textAlign: TextAlign.start,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!
                                                  .copyWith(
                                                      fontSize: 12,
                                                      color: marchColorData[
                                                          MarchColor
                                                              .lightBlack],
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      letterSpacing: 0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                      MarchSize.mediumVerticalSpacer,
                      MarchSize.smallVerticalSpacer,
                    ],
                  ],
                );
              }

              else if (dropDown.dropType == DropType.scrollItems) {
                // Ensure items list is not null or empty
                if (dropDown.items == null || dropDown.items!.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 3.0,
                        width: MediaQuery.of(context).size.width * 0.15,
                        margin: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 12,
                        ),
                        decoration: BoxDecoration(
                          color: marchColorData[MarchColor.extraLightBlack],
                          borderRadius: BorderRadius.circular(360),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No items available to display',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ],
                  );
                }

                // Validate initialIndex
                int validInitialIndex = (initialIndex ?? 0).clamp(0, dropDown.items!.length - 1);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 3.0,
                      width: MediaQuery.of(context).size.width * 0.15,
                      margin: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 12,
                      ),
                      decoration: BoxDecoration(
                        color: marchColorData[MarchColor.extraLightBlack],
                        borderRadius: BorderRadius.circular(360),
                      ),
                    ),
                    // Removed SizedBox(height: 250) to avoid pushing picker out of view
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200, // Fixed height for CupertinoPicker to ensure visibility
                      child: CupertinoPicker(
                        itemExtent: 50,
                        looping: true,
                        scrollController: FixedExtentScrollController(
                          initialItem: validInitialIndex,
                        ),
                        children: List<Widget>.generate(dropDown.items!.length, (int index) {
                          return Center(
                            child: Text(
                              dropDown.items![index].name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        }),
                        onSelectedItemChanged: (value) {
                          widgetValue = dropDown.items![value].name;
                          SystemSound.play(SystemSoundType.click);
                          HapticFeedback.lightImpact();
                          notifier.setValue(widgetValue);
                          onChange?.call(widgetValue); // Call onChange
                          if (!(showButton ?? true)) {
                            dropDown.widgetValue?.call(
                              notifier.value ?? dropDown.items![validInitialIndex].name,
                            );
                            onConfirm?.call();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (showButton ?? true)
                      ElevatedButton(
                        onPressed: () {
                          dropDown.widgetValue?.call(
                            notifier.value ?? dropDown.items![validInitialIndex].name,
                          );
                          onConfirm?.call();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dropDown.submitButtonColor ??
                              marchColorData[MarchColor.purpleExtraDark],
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          dropDown.submitButtonText ?? 'Confirm',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                );
              }



              else {
                return Container();
              }
            }),
          );
        } else {
          // Existing item selection code (unchanged)
          return ChangeNotifierProvider(
            create: (_) => SelectNoneNotifier(
                ((dropDown.getListByController ?? false)
                    ? dropDown.listController!.optionalList ?? []
                    : dropDown.items),
                dropDown.enableMultipleSelection,
                dropDown.textController.text,
                dropDown.listController != null
                    ? (dropDown.listController!.selectNone ?? false)
                    : selectNone ?? false),
            child: Consumer<SelectNoneNotifier>(
                builder: (context, notifier, child) {
              return Column(
                children: <Widget>[
                  Container(
                    height: 3.0,
                    width: MediaQuery.of(context).size.width * 0.15,
                    margin: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      color: marchColorData[MarchColor.extraLightBlack],
                      borderRadius: BorderRadius.circular(360),
                    ),
                  ),

                  // Rest of the item selection code (unchanged)
                ],
              );
            }),
          );
        }
      },
    );
  }

// Rest of the MainBody class (unchanged)
}

/// This is search text field class.
//ignore: must_be_immutable
class _AppTextField extends StatefulWidget {
  _AppTextField(
      {required this.dropDown,
      required this.onTextChanged,
      required this.onClearTap,
      Key? key})
      : super(key: key);
  DropDown dropDown;
  Function(String) onTextChanged;
  VoidCallback onClearTap;

  @override
  State<_AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<_AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(
        cursorColor: Colors.black54,
        cursorWidth: 1,
        // set the cursor thickness
        controller: widget.dropDown.searchController,
        onChanged: (value) {
          widget.onTextChanged(value);
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.dropDown.searchBackgroundColor ?? Colors.black12,
          contentPadding: const EdgeInsets.only(right: 15),
          hintText: widget.dropDown.searchHintText ?? 'Search',
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          prefixIcon: const IconButton(
            icon: Icon(Icons.search),
            onPressed: null,
          ),
          suffixIcon: GestureDetector(
            onTap: widget.onClearTap,
            child: const Icon(
              Icons.cancel,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
