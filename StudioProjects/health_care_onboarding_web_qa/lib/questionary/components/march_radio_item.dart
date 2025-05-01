import 'package:custom_check_box/custom_check_box.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../march_style/march_size.dart';
import '../../march_style/march_theme.dart';
import 'march_check_box.dart';

enum RadioSize { small, large }

class MarchRadioItem extends StatelessWidget {
  MarchRadioItem({
    Key? key,
    required this.label,
    required this.groupValue,
    required this.value,
    required this.onChanged,
    this.radioSize = RadioSize.small,
    this.toggleable = false,
  }) : super(key: key);

  final String label;
  final bool groupValue;
  final bool value;
  final ValueChanged<bool> onChanged;
  final RadioSize? radioSize;
  final bool? toggleable;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //  if (value != groupValue) {
        onChanged(value);
        // }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: MarchSize.littleGap * 3),
        child: Row(
          children: <Widget>[
            Transform.scale(
              scale: radioSize == RadioSize.small ? 0.7 : 1,
              child: Radio<bool>(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                toggleable: toggleable!,
                visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity,
                ),
                activeColor: marchColorData[MarchColor.purpleExtraDark],
                fillColor: WidgetStateColor.resolveWith(
                    (states) => marchColorData[MarchColor.purpleExtraDark]!),
                groupValue: groupValue,
                value: value,
                onChanged: (bool? newValue) {
                  onChanged(newValue ?? false);
                },
              ),
            ),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: radioSize == RadioSize.small ? 11 : 12,
                fontWeight: radioSize == RadioSize.small
                    ? FontWeight.w500
                    : FontWeight.w300,
                color: marchColorData[MarchColor.extraBlack],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarchRadioItemV2 extends StatelessWidget {
  MarchRadioItemV2(
      {Key? key,
      required this.label,
      required this.value,
      required this.onChanged,
      this.fontSize,
      this.width,
      this.havePadding = true})
      : super(key: key);

  final String label;
  final double? fontSize;
  final double? width;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool havePadding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        havePadding
            ? CustomCheckBox(
                value: value,
                splashRadius: 1,
                borderColor: marchColorData[MarchColor.purpleExtraDark],
                checkedIconColor: marchColorData[MarchColor.white]!,
                uncheckedFillColor: Colors.transparent,
                checkedFillColor: marchColorData[MarchColor.purpleExtraDark]!,
                uncheckedIconColor: Colors.transparent,
                borderRadius: 360,
                splashColor: Colors.transparent,
                uncheckedIcon:
                    const IconData(0xebf8, fontFamily: 'MaterialIcons'),
                checkedIcon:
                    const IconData(0xf2e6, fontFamily: 'MaterialIcons'),
                borderWidth: 1,
                checkBoxSize: 20,
                onChanged: onChanged,
              )
            : MarchCheckBox(
                value: value,
                splashRadius: 1,
                borderColor: marchColorData[MarchColor.purpleExtraDark],
                checkedIconColor: marchColorData[MarchColor.white]!,
                uncheckedFillColor: Colors.transparent,
                checkedFillColor: marchColorData[MarchColor.purpleExtraDark]!,
                uncheckedIconColor: Colors.transparent,
                borderRadius: 360,
                splashColor: Colors.transparent,
                uncheckedIcon:
                    const IconData(0xebf8, fontFamily: 'MaterialIcons'),
                checkedIcon:
                    const IconData(0xf2e6, fontFamily: 'MaterialIcons'),
                borderWidth: 1,
                checkBoxSize: 20,
                onChanged: onChanged,
              ),
        GestureDetector(
          onTap: () {
            onChanged(!value);
          },
          child: Container(
            constraints: BoxConstraints(
                minWidth: 50,
                maxWidth: MediaQuery.of(context).size.width * 0.8),
            child: Text(
              label,
              overflow: TextOverflow.clip,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: fontSize ?? 14,
                  fontWeight: value ? FontWeight.w700 : FontWeight.w300,
                  color: marchColorData[MarchColor.mainBlack]),
            ),
          ),
        ),
      ],
    );
  }
}
