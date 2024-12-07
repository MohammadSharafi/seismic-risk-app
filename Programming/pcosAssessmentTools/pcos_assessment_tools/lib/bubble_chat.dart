import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pcos_assessment_tools/march_style/hexColor.dart';
import 'package:pcos_assessment_tools/march_style/march_icons.dart';
import 'package:pcos_assessment_tools/march_style/march_size.dart';

const double BUBBLE_RADIUS = 16;

class BubbleChat extends StatelessWidget {
  final double bubbleRadius;
  final bool isSender;
  final bool? showEdit;
  final bool topSender;
  final List<Color> colors;
  final Widget widget;
  final Widget answer;
  final bool tail;
  final BoxConstraints? constraints;
  final Widget? trailing;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  BubbleChat({
    Key? key,
    required this.widget,
    required this.answer,
    this.constraints,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    this.bubbleRadius = BUBBLE_RADIUS,
    this.isSender = true,
    this.topSender = false,
    this.colors = const [Colors.white70],
    this.tail = true,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.trailing,
    this.showEdit,
  }) : super(key: key);

  ///chat bubble builder method
  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;

    return Container(
      margin: EdgeInsets.symmetric(vertical: MarchSize.littleGap * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              !isSender
                  ? Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipOval(
                          child: Image.asset(
                            MarchIcons.pcos_icon_supporter,
                            fit: BoxFit.cover, // Ensures the image fits well within the circle
                          ),
                        ),
                      ))
                  : Container(),
              Container(
                color: Colors.transparent,
                constraints: constraints ?? BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
                margin: margin,
                padding: padding,
                child: GestureDetector(
                  onTap: onTap,
                  onDoubleTap: onDoubleTap,
                  onLongPress: onLongPress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular((topSender && !isSender) ? 3 : bubbleRadius),
                        topRight: Radius.circular(bubbleRadius),
                        bottomLeft: Radius.circular(tail
                            ? isSender
                                ? (bubbleRadius)
                                : (topSender ? bubbleRadius : 0)
                            : BUBBLE_RADIUS),
                        bottomRight: Radius.circular(tail
                            ? isSender
                                ? 0
                                : bubbleRadius
                            : BUBBLE_RADIUS),
                      ),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: stateTick ? EdgeInsets.fromLTRB(12, 6, 28, 6) : EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                          child: widget,
                          // child: SelectableText(

                          //         text,
                          //         style: textStyle,
                          //         textAlign: TextAlign.left,
                          //       ),
                        ),
                        stateIcon != null && stateTick
                            ? Positioned(
                                bottom: 4,
                                right: 6,
                                child: stateIcon,
                              )
                            : SizedBox(
                                width: 1,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isSender && trailing != null) SizedBox.shrink(),
              isSender
                  ? Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipOval(
                          child: Image.asset(
                            MarchIcons.default_prof,
                            fit: BoxFit.cover, // Ensures the image fits well within the circle
                          ),
                        ),
                      ))
                  : Container(),
            ],
          ),
          Container(margin: EdgeInsets.only(left: MarchSize.littleGap * 14), child: answer),
          if ((showEdit ?? true) && isSender)
            Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: onTap,
                  child: SvgPicture.asset(
                    MarchIcons.pcos_icon_edit,
                    width: 16,
                    color: HexColor.fromHex('#D37B91'),
                  ),
                ),
                SizedBox(
                  width: MarchSize.littleGap * 14,
                )
              ],
            ),
        ],
      ),
    );
  }
}
