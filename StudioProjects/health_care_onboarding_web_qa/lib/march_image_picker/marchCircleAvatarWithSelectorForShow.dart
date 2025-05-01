import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../march_style/march_icons.dart';
import '../march_style/march_size.dart';
import '../march_style/march_theme.dart';

class MarchCircleAvatarWithSelectorForShow extends StatefulWidget {
  const MarchCircleAvatarWithSelectorForShow(
      {Key? key,
        this.size = 54,
        this.isSelected = false,
        this.isDisable = false,
        this.numberTaped,
        this.isMultiTapped = false,
        this.avatarImage,
        this.backGroundColor,
        this.isLocalImage = false})
      : super(key: key);

  final double size;
  final bool isSelected;
  final bool? isDisable;
  final int? numberTaped;
  final bool isMultiTapped;
  final String? avatarImage;
  final Color? backGroundColor;
  final bool isLocalImage;

  @override
  State<MarchCircleAvatarWithSelectorForShow> createState() =>
      _MarchCircleAvatarWithSelectorForShowState();
}

class _MarchCircleAvatarWithSelectorForShowState
    extends State<MarchCircleAvatarWithSelectorForShow> {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (widget.isDisable == true) ? 0.5 : 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: widget.isSelected ? widget.size * 1.1 : widget.size * 1.04,
            height: widget.isSelected ? widget.size * 1.1 : widget.size * 1.04,
            child: CircleAvatar(
                backgroundColor: widget.isSelected
                    ? marchColorData[MarchColor.primary]
                    : Colors.white,
                child: Container(
                    height: widget.size,
                    width: widget.size,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: _colorBackGroundImage()),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.size),
                      child: Center(
                          child: Container(
                            child: widget.isLocalImage
                                ? Image.asset(
                              widget.avatarImage ?? '',
                              //color: _colorImage(),
                              colorBlendMode: BlendMode.srcATop,
                              fit: BoxFit.cover,
                            )
                                :Container()
                            //     : S3Image(
                            //   route: widget.avatarImage ?? '',
                            //   colorBlendMode: (widget.isDisable ?? false)
                            //       ? BlendMode.saturation
                            //       : BlendMode.srcATop,
                            // ),
                          )),
                    ))),
          ),
          if (widget.isSelected)
            Positioned(
              right: -4,
              bottom: 1,
              child: InkWell(
                borderRadius: BorderRadius.all(
                    Radius.circular(MarchSize.smallRadius * 2)),
                child: SizedBox(
                  height: widget.size * .35,
                  width: widget.size * .35,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: SizedBox(
                      height: widget.size * .3,
                      width: widget.size * .3,
                      child: CircleAvatar(
                        backgroundColor: marchColorData[MarchColor.primary],
                        child: SvgPicture.asset(
                          _iconSmallCircleAvatar(),
                          color: Colors.white,
                          width: widget.size * .1,
                          height: widget.size * .1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }



  Color? _colorBackGroundImage() {
    // if (widget.isDisable == null) {
    //   return widget.backGroundColor;
    // } else if (widget.isDisable == true) {
    //   return Colors.grey.withOpacity(.4);
    // } else {
    return widget.backGroundColor;
    //  }
  }

  String _iconSmallCircleAvatar() {
    // if (isMultiTapped) {
    if (widget.numberTaped == 1) {
      return MarchIcons.check_1Icon;
    } else if (widget.numberTaped == 2) {
      return MarchIcons.check_2Icon;
    } else if (widget.numberTaped == 3) {
      return MarchIcons.check_3Icon;
    } else {
      return MarchIcons.checkIcon;
    }
  }
}
