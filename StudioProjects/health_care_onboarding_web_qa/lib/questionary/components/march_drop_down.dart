import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../march_style/controllers/dateController.dart';
import '../../march_style/controllers/listController.dart';
import '../../march_style/march_icons.dart';
import '../../march_style/march_size.dart';
import '../../march_style/march_theme.dart';
import '../controllers/custom_text_form_field/custom_text_form_field.dart';
import 'dropdown/src/drop_down.dart';



enum DropType {
  item,
  date,
  year,
  scrollItems,
  extract,
}

enum TextFieldStyle { Style1, Style2, Style3, UnderLine,border }

//ignore: must_be_immutable
class MarchDropDown extends StatelessWidget {
  MarchDropDown({
    required this.textEditingController,
    required this.hint,
    this.lableText = '',
    this.items,
    this.validator,
    Key? key,
    this.suffixText,
    this.onChange,
    this.onConfirm,
    this.showButton,
    this.haveDes,
    this.desTitle,
    this.desSubTitle,
    this.autovalidateMode,
    this.maxHeightWheightW,
    required this.submitButtonText,
    required this.searchHintText,
    required this.bottomSheetTitle,
    required this.searchBackgroundColor,
    required this.enableMultipleSelection,
    required this.context,
    this.initialIndex,
    this.initialDate,
    this.maxDate,
    this.canSearch = true,
    this.returnDateText = true,
    this.returnList = false,
    this.heightW = 0.7,
    this.suffixIcon,
    this.suffixIconSvg,
    this.dropType = DropType.item,
    this.style = TextFieldStyle.Style1,
    this.deActive = false,
    this.dateController,
    this.onDone,
    this.listController,
    this.getListByController,
    this.returnString = true,
    this.returnObject = true,
    this.weightNum = 0,
    this.heightNum = 0,
    this.yearNum = 0,
    this.hasOtherMultipleSelection = false,
    this.onOtherTapChanged,
    this.onTapTextFormField,
    this.haveMax,
    this.haveNone,
    this.numberOfNonOthers,
    this.haveOther,
    this.minDate,
    this.haveMin, this.fillColor,
  }) : super(key: key);
  TextEditingController textEditingController = TextEditingController();
  final FormFieldValidator<String>? validator;
  final VoidCallback? onDone;

  //extra
  DateController? dateController;

  //extra
  AutovalidateMode? autovalidateMode;

  //extra
  ListController? listController;
  bool? getListByController;
  bool? haveMax;
  bool? haveNone;
  int? numberOfNonOthers;
  bool? haveOther;
  bool? haveMin;
  DateTime? minDate;

  //extra
  final String submitButtonText;
  final String searchHintText;
  final String bottomSheetTitle;
  final String lableText;
  final String hint;
  final BuildContext context;
  final Color searchBackgroundColor;
  final Color ? fillColor;
  final bool enableMultipleSelection;
  final bool? canSearch;
  final bool? returnDateText;
  final bool? returnList;
  double? verticalTextPadding;
  double? heightW;
  double? maxHeightWheightW;
  double? horizontalTextPadding;
  Icon? suffixIcon;
  String? suffixText;
  String? suffixIconSvg;
  Function(String a)? onChange;
  VoidCallback? onConfirm;
  bool? showButton;
  bool? haveDes;
  String? desTitle;
  String? desSubTitle;
  int? initialIndex;
  DateTime? initialDate;
  DateTime? maxDate;
  //extra
  bool? deActive;
  List<SelectedListItem>? items = [];
  final Function()? onTapTextFormField;

  //extra
  bool? returnString = true;
  bool? returnObject = false;

  //extra
  DropType dropType = DropType.item;
  TextFieldStyle style = TextFieldStyle.Style1;
  final bool hasOtherMultipleSelection;
  final Function(bool)? onOtherTapChanged;

  final TextEditingController _searchTextEditingController =
      TextEditingController();
  late BorderRadius borderRadius_ = BorderRadius.circular(8.0);
  int weightNum;
  int heightNum;
  int yearNum;

  /// This is on text changed method which will display on city text field on changed.
  void onTextFieldTap() {
    if (textEditingController.text.isNotEmpty && dropType == DropType.year) {
      yearNum = int.parse(textEditingController.text);
    }
    print(textEditingController.text);
    if (getListByController ?? false) {
      listController!.updateListValue();
    }

    DropDownState(
      dropDown: DropDown(
        maxHeightWheightW: maxHeightWheightW,
        haveNone: haveNone,
        numberOfNonOthers: numberOfNonOthers,
        haveOther: haveOther,
        haveMax: haveMax,
        haveMin: haveMin,
        minDate: minDate,
        items: items!,
        listController: listController,
        getListByController: getListByController,
        dropType: dropType,
        showWidget: dropType != DropType.item && dropType != DropType.extract,
        canSearch: canSearch,
        submitButtonText: submitButtonText,
        submitButtonColor: marchColorData[MarchColor.purpleExtraDark],
        searchHintText: searchHintText,
        bottomSheetTitle: bottomSheetTitle,
        searchBackgroundColor: searchBackgroundColor,
        selectedItems: (List<dynamic> selectedList, bool isNone) {
          if (dropType == DropType.extract) {
            // Handle extract type
          } else if (returnList!) {
            listController!.setListValue(selectedList);
            textEditingController.text = isNone
                ? 'None'
                : '${(selectedList.isNotEmpty) ? selectedList.length : 'No'} item${(selectedList.length > 1) ? 's' : ''} selected';
          } else if (returnString!) {
            String selectedItems =
            selectedList.map((e) => e.name).toList().join(',');
            textEditingController.text = isNone ? 'None' : selectedItems;
          } else {
            // Handle other cases
          }
        },
        widgetValue: (dynamic value) {
          // Handle widget value
        },
        selectedItem: (String selected) {
          if (selected.isNotEmpty) {
            textEditingController.text = selected;
          }
        },
        enableMultipleSelection: enableMultipleSelection,
        searchController: _searchTextEditingController,
        textController: textEditingController,
        heightWheightW: heightW!,
        onChange: onChange, // Pass onChange to DropDown
      ),
      onConfirm: onConfirm,
      showButton: showButton,
      haveDes: haveDes,
      desTitle: desTitle,
      desSubTitle: desSubTitle,
      initialDate: initialDate,
      maxDate: maxDate,
      initialIndex: initialIndex,
      onChange: onChange, // Pass onChange to DropDownState
    ).showModal(context, onDone: () {
      if (onDone != null) {
        onDone!.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (style == TextFieldStyle.Style3) ...[
          CustomTextFormField(
            labelText: hint,
            title: hint,
            hintText: hint,
            fillColor:fillColor?? Colors.white,
            onChanged: (a) {
              if (onChange != null) onChange!(a);
            },
            labelColorText: marchColorData[MarchColor.extraLightBlack],
            textColor: marchColorData[MarchColor.textLightGray],
            contentPadding:
                EdgeInsets.symmetric(horizontal: MarchSize.smallPaddingAll),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            enabledWithingTextBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(MarchSize.tinyRadius)),
                borderSide:
                    BorderSide(color: marchColorData[MarchColor.primary]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(MarchSize.tinyRadius)),
                borderSide: BorderSide(
                    color: marchColorData[textEditingController.text.isNotEmpty
                        ? MarchColor.primary
                        : MarchColor.extraLightBlack]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(MarchSize.tinyRadius)),
                borderSide:
                    BorderSide(color: marchColorData[MarchColor.primary]!)),
            onTap: () {
              FocusScope.of(context).unfocus();
              onTextFieldTap();

              if (onTapTextFormField != null) onTapTextFormField!();
            },
            readOnly: true,
            suffixText: suffixText,
            suffixIconWidget: Padding(
              padding: EdgeInsetsDirectional.only(
                  end: MarchSize.smallPaddingAll * 2),
              child: InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  onTextFieldTap();
                  if (onTapTextFormField != null) onTapTextFormField!();
                },
                child: SvgPicture.asset(
                  suffixIconSvg!,
                  color: marchColorData[MarchColor.extraLightBlack],
                  height: 20,
                  width: 20,
                ),
              ),
            ),
            suffixIconSize: MarchSize.iconSize * .715,
            controller: textEditingController,
          ),
        ]
        else if (style == TextFieldStyle.UnderLine) ...[
          CustomTextFormField(
            labelText: hint,
            suffixIconPressed: () {
              FocusScope.of(context).unfocus();
              onTextFieldTap();
              if (onTapTextFormField != null) onTapTextFormField!();
            },
            onChanged: (a) {
              if (onChange != null) onChange!(a);
            },
            onTap: () {
              FocusScope.of(context).unfocus();
              onTextFieldTap();
              if (onTapTextFormField != null) onTapTextFormField!();
            },
            readOnly: true,
            suffixIcon: MarchIcons.calendarIcon,
            suffixIconSize: MarchSize.iconSize * .715,
            controller: textEditingController,
          ),
        ]
        else if(style == TextFieldStyle.border)...[

            TextFormField(
              keyboardType: TextInputType.multiline,
              cursorColor: Colors.black54,
              cursorWidth: 1,
              validator: validator,
              controller: textEditingController,
              readOnly: true,
              autovalidateMode: autovalidateMode,
              onTap: () {
                FocusScope.of(context).unfocus();
                onTextFieldTap();
                if (onTapTextFormField != null) onTapTextFormField!();
              },
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w300,
                color: marchColorData[MarchColor.mainBlack],
                fontSize: 14,
              ),
              decoration: InputDecoration(

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Set border radius

                  borderSide: const BorderSide(

                    color:  Colors.black ,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Set border radius

                  borderSide: const BorderSide(
                    color: Colors.grey ,
                    width:1,
                  ),
                ),
              ),
            ),


          ]



        else ...[
          TextFormField(
            keyboardType: TextInputType.multiline,
            cursorColor: Colors.black54,
            cursorWidth: 1, // set the c
            validator: validator,
            controller: textEditingController..addListener((){
              if (onChange != null) onChange!(textEditingController.text??'');
            }),
            readOnly: true,
            autovalidateMode: autovalidateMode,
            onChanged: (a) {
              if (onChange != null) onChange!(a);
            },
            onTap: () {
              FocusScope.of(context).unfocus();
              onTextFieldTap();
              if (onTapTextFormField != null) onTapTextFormField!();
            },
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w300,
                color: marchColorData[MarchColor.mainBlack],
                fontSize: 14),
            decoration: _TxtStyle(style),
          ),
          style == TextFieldStyle.Style1
              ? const SizedBox(
                  height: 0.0,
                )
              : Container(),
        ]
      ],
    );
  }

  InputDecoration _TxtStyle(TextFieldStyle style) {
    if (style == TextFieldStyle.Style1) {
      return InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w300,
            color: marchColorData[MarchColor.lightBlack]!.withOpacity(0.3),
            fontSize: 13),
        suffixStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w400,
            color: marchColorData[MarchColor.lightBlack]!.withOpacity(0.3),
            fontSize: 13),
        suffixIcon: suffixIcon ??
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: marchColorData[MarchColor.lightBlack]!.withOpacity(0.3),
            ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
            vertical: verticalTextPadding ?? 10,
            horizontal: horizontalTextPadding ?? 6),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius_,
          borderSide: BorderSide(
            color: marchColorData[MarchColor.errorColor]!,
          ),
        ),
        errorStyle: const TextStyle(
          color: Colors.red, // Customize the error text color
          fontSize: 0, // Customize the error text size
          fontWeight: FontWeight.bold, // Customize the error text weight
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius_,
          borderSide: BorderSide(
              color: deActive!
                  ? Colors.transparent
                  : marchColorData[MarchColor.commentBgColor]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius_,
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius_,
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        filled: true,
        fillColor: deActive! ? Colors.black.withOpacity(0.1) : Colors.white,
      );
    }
    else {
      return InputDecoration(
          label: Text(
            lableText,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: marchColorData[MarchColor.primary],
                  fontSize: MarchSize.iconSizeTiny,
                ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: marchColorData[MarchColor.primary]!),
          ),
          fillColor: Colors.transparent,
          disabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: marchColorData[MarchColor.primary]!),
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: MarchSize.smallWidth,
            minHeight: MarchSize.smallWidth,
          ),
          suffixIcon: Padding(
            padding: EdgeInsetsDirectional.only(
                top: MarchSize.paddingMediumTop * 1.25),
            child: SvgPicture.asset(
              suffixIconSvg!,
              color: marchColorData[MarchColor.primary],
              height: MarchSize.iconSizeTiny,
              width: MarchSize.iconSizeTiny,
            ),
          ));
    }
  }
}


