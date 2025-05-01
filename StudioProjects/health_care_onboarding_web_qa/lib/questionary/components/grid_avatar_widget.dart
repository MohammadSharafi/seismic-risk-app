import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../focusedMenu/focused_menu.dart';
import '../../focusedMenu/modals.dart';
import '../../march_image_picker/marchCircleAvatarWithSelectorForShow.dart';
import '../../march_style/march_size.dart';
import '../../march_style/march_theme.dart';
import '../controllers/question_controller.dart';

class GridAvatarWidget<T extends SelectedAvatarModel>
    extends StatelessWidget {
  GridAvatarWidget({
    Key? key,
    required this.avatarList,
    this.onTap,
    required this.isMultiTapped,
    this.hasDisable,
    this.backGroundColor,
    this.overSleep,
    this.lackSleep,
    this.myIndex,
    this.isFirstApi = true,
    this.isLocalImage = false,
    this.showGuide = false,
    this.onTwoTap,
    this.onThreeTap,
    this.notMulti,
    this.currentAnswer,
    required this.surveyState,
    required this.pageIndex,
    required this.questionIndex,
  }) : super(key: key);
  final Map<String, T> avatarList;
  final void Function(Map<String, dynamic>)? onTap;
  final void Function(int index)? onTwoTap;
  final void Function(int index)? onThreeTap;

  final bool isMultiTapped;
  List<int>? notMulti = [];
  final bool? hasDisable;
  final Color? backGroundColor;
  final SurveyState surveyState;
  final int pageIndex;
  final int questionIndex;
  final bool isFirstApi;
  final  currentAnswer;
  final bool showGuide;

  final int? overSleep;
  final int? lackSleep;
  final int? myIndex;
  final bool isLocalImage;

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
      crossAxisCount: 4,
      axisDirection: AxisDirection.down,
      crossAxisSpacing: 1,
      children: [
        // First and second rows (4 items each)
        ...avatarList.entries.take(8).map((entry) {
          final currentAnswer = surveyState!.getAnswer(pageIndex, questionIndex) as Set<String>? ?? {};

          return Center(
            child: Container(
              padding: EdgeInsets.all(4),
              child: AvatarWithTitleWidget(
                key: ValueKey(entry.key),
                isLocalImage: isLocalImage,
                backGroundColor: HexColor(entry.value.background ?? ''),
                isParentGrid: true,
                avatarImage: entry.value.icon,
                numberTaped: entry.value.isSelected ? 1 : 0,
                title: entry.value.title,
                isSelected: entry.value.isSelected,
                isDisable: false,
                onTap: () {
                  if (onTap != null) {
                    entry.value.isSelected = !entry.value.isSelected;
                    onTap!({
                      'key': entry.key,
                      'currentAnswer': currentAnswer,
                      'isSelected': entry.value.isSelected
                    });
                  }
                },
                isMultiTapped: false,
              ),
            ),
          );
        }).toList(),
        // Third row (2 items, centered)
        if (avatarList.length == 10)
          StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: avatarList.entries.skip(8).map((entry) {
                final currentAnswer = surveyState!.getAnswer(pageIndex, questionIndex) as Set<String>? ?? {};

                return Container(
                  width: MediaQuery.of(context).size.width / 4 - 8, // Adjust width to match grid cell
                  padding: EdgeInsets.all(4),
                  child: AvatarWithTitleWidget(
                    key: ValueKey(entry.key),
                    isLocalImage: isLocalImage,
                    backGroundColor: HexColor(entry.value.background ?? ''),
                    isParentGrid: true,
                    avatarImage: entry.value.icon,
                    numberTaped: entry.value.isSelected ? 1 : 0,
                    title: entry.value.title,
                    isSelected: entry.value.isSelected,
                    isDisable: false,
                    onTap: () {
                      if (onTap != null) {
                        entry.value.isSelected = !entry.value.isSelected;
                        onTap!({
                          'key': entry.key,
                          'currentAnswer': currentAnswer,
                          'isSelected': entry.value.isSelected
                        });
                      }
                    },
                    isMultiTapped: false,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}



class AvatarWithTitleWidget extends StatelessWidget {
  const AvatarWithTitleWidget({
    Key? key,
    required this.title,
    this.isSelected = false,
    this.isDisable = false,
    this.showGuide = false,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.isParentGrid = false,
    this.width = 90,
    this.numberTaped,
    required this.isMultiTapped,
    this.avatarImage,
    this.backGroundColor,
    this.isLocalImage = false,
    this.onTwoTap,
    this.onThreeTap,
  }) : super(key: key);
  final String title;
  final bool isSelected;
  final bool? isDisable;
  final bool isParentGrid;
  final void Function()? onTap;
  final void Function()? onTwoTap;
  final void Function()? onThreeTap;
  final double width;
  final EdgeInsetsGeometry padding;
  final int? numberTaped;
  final bool isLocalImage;
  final bool isMultiTapped;
  final bool showGuide;

  final String? avatarImage;
  final Color? backGroundColor;

  @override
  Widget build(BuildContext context) {
    return isParentGrid ? _gridBuilder(context) : _itemBuilder(context);
  }

  Widget _gridBuilder(BuildContext context) {
    return _widgetBuilder(context);
  }

  Widget _itemBuilder(BuildContext context) {
    return SizedBox(
      width: width,
      child: _widgetBuilder(context),
    );
  }

  Widget _widgetBuilder(BuildContext context) {
    if (isMultiTapped) {
      return FocusedMenuHolder(
        blurSize: 4.0,
        duration: const Duration(milliseconds: 100),
        animateMenuItems: true,
        blurBackgroundColor: Colors.white,
        bottomOffsetHeight: 0,
        menuItem: FocusedMenuItem(
          onThreeX: () {
            if (onThreeTap != null) {
              onThreeTap!();
            }
          },
          onTwoX: () {
            if (onTwoTap != null) {
              onTwoTap!();
            }
          },
        ),
        onPressed: () {},
        onLongPressed: () {},
        child: Padding(
          padding: padding,
          child: GestureDetector(
            onTap: () {
              if (onTap != null) {
                onTap!();
              }
            },
            child: Column(
              children: [
                MarchCircleAvatarWithSelectorForShow(
                  isLocalImage: isLocalImage,
                  backGroundColor: backGroundColor,
                  avatarImage: avatarImage,
                  isSelected: isSelected,
                  isDisable: isDisable,
                  numberTaped: numberTaped,
                  isMultiTapped: isMultiTapped,
                ),
                MarchSize.smallVerticalSpacer,
                SizedBox(
                  // width: MarchSize.mediumWidth * 3.437,
                  width: MediaQuery.of(context).size.width / 5.3,
                  // height: MediaQuery.of(context).size.width / 5,

                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                        color: isSelected
                            ? marchColorData[
                        MarchColor.purpleExtraDark]
                            : marchColorData[MarchColor.blackText],
                        fontSize: 9,
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w500,
                        height: .9),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: padding,
        child: GestureDetector(
          onTap: () {
            if (onTap != null) {
              onTap!();
            }
          },
          child: Column(
            children: [
              MarchCircleAvatarWithSelectorForShow(
                isLocalImage: isLocalImage,
                backGroundColor: backGroundColor,
                avatarImage: avatarImage,
                isSelected: isSelected,
                isDisable: isDisable,
                numberTaped: numberTaped,
                isMultiTapped: isMultiTapped,
              ),
              MarchSize.smallVerticalSpacer,
              SizedBox(
                // width: MarchSize.mediumWidth * 3.437,
                width: MediaQuery.of(context).size.width / 5.2,
                // height: MediaQuery.of(context).size.width / 5,

                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? marchColorData[MarchColor.purpleExtraDark]
                          : marchColorData[MarchColor.blackText],
                      fontSize: 9,
                      fontWeight:
                      isSelected ? FontWeight.w900 : FontWeight.w500,
                      height: .9),
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}


class GridItemModel extends SelectedAvatarModel {
  GridItemModel({
    String? id,
    required String title,
    bool isSelected = false,
    bool hasDisable = false,
    required String background,
    int stateSelectedAvatar = 0,
    required String icon,
  }) : super(
    id: id,
    title: title,
    icon: icon,
    background: background,
    isSelected: isSelected,
    hasDisable: hasDisable,
  );
}

class SelectedAvatarModel {
  final String? id;
  final String title;
  final String icon;
  final String? background;
  bool isSelected;
  bool hasDisable;

  SelectedAvatarModel({
    this.id,
    required this.title,
    required this.icon,
    this.background,
    this.isSelected = false,
    this.hasDisable = false,
  });
}

