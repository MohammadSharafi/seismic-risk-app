library focused_menu;

import 'dart:ui';

import 'package:flutter/material.dart';
import '../march_style/march_icons.dart';
import '../march_style/march_theme.dart';
import 'modals.dart';

class FocusedMenuHolder extends StatefulWidget {

  const FocusedMenuHolder(
      {Key? key,
      required this.child,
      required this.onPressed,
      required this.onLongPressed,
      required this.menuItem,
      this.duration,
      this.showGuide,
      this.menuBoxDecoration,
      this.menuItemExtent,
      this.animateMenuItems,
      this.blurSize,
      this.blurBackgroundColor,
      this.menuWidth,
      this.bottomOffsetHeight,
      this.menuOffset,
      this.openWithTap = false})
      : super(key: key);
  final Widget child;
  final double? menuItemExtent;
  final double? menuWidth;
  final FocusedMenuItem menuItem;
  final bool? animateMenuItems;
  final bool? showGuide;
  final BoxDecoration? menuBoxDecoration;
  final Function onPressed;
  final VoidCallback onLongPressed;
  final Duration? duration;
  final double? blurSize;
  final Color? blurBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;

  /// Open with tap instead of long press.
  final bool openWithTap;

  @override
  _FocusedMenuHolderState createState() => _FocusedMenuHolderState();
}

class _FocusedMenuHolderState extends State<FocusedMenuHolder> {
  GlobalKey containerKey = GlobalKey();
  Offset childOffset = const Offset(0, 0);
  Size? childSize;

  getOffset() {
    RenderBox renderBox =
        containerKey.currentContext!.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    setState(() {
      this.childOffset = Offset(offset.dx, offset.dy);
      childSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: containerKey,
        onTap: () async {
          widget.onPressed();
          if (widget.openWithTap) {
            await openMenu(context);
          }
        },
        onLongPress: () async {
          //if(widget.menuItem.onTwoX() != null && widget.menuItem.onThreeX() != null)
          if (!widget.openWithTap) {
            widget.onLongPressed.call();

            await Future.delayed(const Duration(milliseconds: 100));
            await openMenu(context);
          }
        },
        child: widget.child);
  }

  Future openMenu(BuildContext context) async {
    getOffset();
    await Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: widget.duration ?? const Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondaryAnimation) {
              animation = Tween(begin: 0.0, end: 1.0).animate(animation);
              return FadeTransition(
                  opacity: animation,
                  child: FocusedMenuDetails(
                    showGuide: widget.showGuide,
                    itemExtent: widget.menuItemExtent,
                    menuBoxDecoration: widget.menuBoxDecoration,
                    child: widget.child,
                    childOffset: childOffset,
                    childSize: childSize,
                    menuItems: widget.menuItem,
                    blurSize: widget.blurSize,
                    menuWidth: widget.menuWidth,
                    blurBackgroundColor: widget.blurBackgroundColor,
                    animateMenu: widget.animateMenuItems ?? true,
                    bottomOffsetHeight: widget.bottomOffsetHeight ?? 0,
                    menuOffset: widget.menuOffset ?? 0,
                  ));
            },
            fullscreenDialog: true,
            opaque: false));
  }
}

class FocusedMenuDetails extends StatelessWidget {

  const FocusedMenuDetails(
      {Key? key,
      required this.menuItems,
      required this.child,
      required this.childOffset,
      required this.childSize,
      required this.menuBoxDecoration,
      required this.itemExtent,
      required this.animateMenu,
      required this.blurSize,
      required this.blurBackgroundColor,
      required this.menuWidth,
      this.bottomOffsetHeight,
      this.menuOffset,
      this.showGuide})
      : super(key: key);
  final FocusedMenuItem menuItems;
  final BoxDecoration? menuBoxDecoration;
  final Offset childOffset;
  final double? itemExtent;
  final Size? childSize;
  final Widget child;
  final bool animateMenu;
  final bool? showGuide;
  final double? blurSize;
  final double? menuWidth;
  final Color? blurBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final maxMenuHeight = size.height * 0.45;
    final listHeight = (itemExtent ?? 50.0);

    final maxMenuWidth = menuWidth ?? (size.width * 0.25);
    final menuHeight = listHeight < maxMenuHeight ? listHeight : maxMenuHeight;
    final leftOffset = (childOffset.dx + maxMenuWidth) < size.width
        ? childOffset.dx
        : (childOffset.dx - maxMenuWidth + childSize!.width);
    final topOffset = (childOffset.dy - menuHeight - menuOffset!) > 0
        ? childOffset.dy - menuHeight - menuOffset!
        : childOffset.dy + childSize!.height + menuOffset!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: blurSize ?? 4, sigmaY: blurSize ?? 4),
                child: Container(
                  color:
                      (blurBackgroundColor ?? Colors.black).withOpacity(0.7),
                ),
              )),
          Positioned(
            top: topOffset,
            left: leftOffset,
            child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 200),
                    builder:
                        (BuildContext context, dynamic value, Widget? child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    tween: Tween(begin: 0.0, end: 1.0),
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(MarchIcons.speechBg),
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: maxMenuWidth,
                        height: menuHeight,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(360.0)),
                          child: (animateMenu)
                              ? TweenAnimationBuilder(
                                  builder: (context, dynamic value, child) {
                                    return Transform(
                                      transform:
                                          Matrix4.rotationX(1.5708 * value),
                                      alignment: Alignment.bottomCenter,
                                      child: child,
                                    );
                                  },
                                  tween: Tween(begin: 1.0, end: 0.0),
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        bottom: menuHeight / 4),
                                    child: Container(
                                        alignment: Alignment.topCenter,
                                        // color: item.backgroundColor ?? Colors.white,
                                        height:
                                            itemExtent ?? maxMenuWidth * 0.27,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                menuItems.onTwoX();
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                height: maxMenuWidth * 0.27,
                                                width: maxMenuWidth * 0.27,
                                                decoration: BoxDecoration(
                                                    color: marchColorData[
                                                        MarchColor.mainBg],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                360))),
                                                child: Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'x',
                                                        style: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                color: marchColorData[
                                                                    MarchColor
                                                                        .purpleExtraDark],
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                        textAlign:
                                                            TextAlign.end,
                                                      ),
                                                      Text(
                                                        '2',
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  color: marchColorData[
                                                                      MarchColor
                                                                          .purpleExtraDark],
                                                                  fontSize:
                                                                      13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                ),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ],
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: marchColorData[
                                                          MarchColor
                                                              .purpleLighter],
                                                      shape: BoxShape.circle),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                menuItems.onThreeX();
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                height: maxMenuWidth * 0.27,
                                                width: maxMenuWidth * 0.27,
                                                decoration: BoxDecoration(
                                                    color: marchColorData[
                                                        MarchColor.mainBg],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                360))),
                                                child: Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'x',
                                                        style: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                color: marchColorData[
                                                                    MarchColor
                                                                        .purpleExtraDark],
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                        textAlign:
                                                            TextAlign.end,
                                                      ),
                                                      Text(
                                                        '3',
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  color: marchColorData[
                                                                      MarchColor
                                                                          .purpleExtraDark],
                                                                  fontSize:
                                                                      13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                ),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ],
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: marchColorData[
                                                          MarchColor
                                                              .purpleLighter],
                                                      shape: BoxShape.circle),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ))
                              : Container(
                                  padding:
                                      EdgeInsets.only(bottom: menuHeight / 4),
                                  child: Container(
                                      alignment: Alignment.topCenter,
                                      // color: item.backgroundColor ?? Colors.white,
                                      height:
                                          itemExtent ?? maxMenuWidth * 0.27,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              menuItems.onTwoX();
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              height: maxMenuWidth * 0.27,
                                              width: maxMenuWidth * 0.27,
                                              decoration: BoxDecoration(
                                                  color: marchColorData[
                                                      MarchColor.mainBg],
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              360))),
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'x',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: marchColorData[
                                                                  MarchColor
                                                                      .purpleExtraDark],
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                      textAlign:
                                                          TextAlign.end,
                                                    ),
                                                    Text(
                                                      '2',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                            color: marchColorData[
                                                                MarchColor
                                                                    .purpleExtraDark],
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900,
                                                          ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                    color: marchColorData[
                                                        MarchColor
                                                            .purpleLighter],
                                                    shape: BoxShape.circle),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              menuItems.onThreeX();
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              height: maxMenuWidth * 0.27,
                                              width: maxMenuWidth * 0.27,
                                              decoration: BoxDecoration(
                                                  color: marchColorData[
                                                      MarchColor.mainBg],
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              360))),
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'x',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: marchColorData[
                                                                  MarchColor
                                                                      .purpleExtraDark],
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                      textAlign:
                                                          TextAlign.end,
                                                    ),
                                                    Text(
                                                      '3',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                            color: marchColorData[
                                                                MarchColor
                                                                    .purpleExtraDark],
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900,
                                                          ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                    color: marchColorData[
                                                        MarchColor
                                                            .purpleLighter],
                                                    shape: BoxShape.circle),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                        ),
                      ),
                    ),
                  ),
          ),
          Positioned(
              top: childOffset.dy,
              left: childOffset.dx,
              child: AbsorbPointer(
                  child: Container(
                      width: childSize!.width,
                      height: childSize!.height,
                      child: child))),
        ],
      ),
    );
  }
}
