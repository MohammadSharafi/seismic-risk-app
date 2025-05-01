import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import 'controllers/theme_controller.dart';

enum MarchColor {
  mainBg,
  navbarBg,
  errorBg,
  successColor,
  successBg,
  mainBlack,
  extraBlack,
  blackShadow,
  lightBlackShadow,
  whiteShadow,
  whiteShadowLv2,
  errorColor,
  pinkBg,
  forumTitleColor,
  grey,
  lightGrey,
  white,
  primary,
  lightBlack,
  extraLightBlack,
  borderPurple,
  transparent,
  commentBgColor,
  commentBorderColor,
  redDark,
  ringSideColor,
  redLight,
  redCalendarPeriod,
  blueDark,
  blueLight,
  greenDark,
  greenLight,
  yellowDark,
  yellowLight,
  purpleDark,
  purpleLight,
  mainPurple,
  targetColor,
  ringRedColor,
  ringGreyColor,
  ringBlueColor,
  ringPurpleColor,
  chartPointerColor,
  chartBackGroundPurpleColor,
  dayPickerColor,
  calendarCurrentMonthCellColor,
  calendarNormalDay,
  calendarToday,
  yearlyCalendarRed,
  yearlyCalendarBlue,
  yearlyCalendarNormal,
  purpleExtraDark,
  createStoryBGColor,
  storyBGColor,
  blackPurple,
  blackPurpleV2,
  purpleBG,
  blueTitle,
  notifBg,
  purpleTitle,
  redTitle,
  tableColor,
  redGradiant,
  pink,
  blueGradiant,
  commentColor,
  blueBMI,
  redBMI,
  yellowBMI,
  darkRedBMI,
  greenBMI,
  monthlyChartRedColor,
  monthlyChartBlueColor,
  mainGreenColor,
  mainBottomSheetBG,
  blackInput,
  blackText,
  blueAvatar,
  orangeLight,
  orangeDeeper,
  purpleLighter,
  pinkMid,
  redMid,
  purpleMid,
  lightYellow,
  greenMid,
  blueMid,
  purpleVeryLight,
  purpleDeeper,
  redMidDeeper,
  purpleMidDeeper,
  lightYellowDeeper,
  pinkMidDeeper,
  greenMidDeeper,
  blueMidDeeper,
  tagColorIcon,
  greyDisable,
  yellowMid,
  sleepColor,
  greenStepper,
  vaginaAvatarColor,
  grayLightColor,
  grayRef,
  liteBlueRef,
  dashColor,
  yellowBgAvatar,
  paintPurple,
  paintLightPurple,
  paintRed,
  paintPink,
  paintGreen,
  paintBlue,
  paintYellow,
  paintGray,
  taskProgressGray,
  lilac,
  timeLineGray,
  textGray,
  textLightGray,
  mustard,
  expireRed,
  disableBorder,
  expireGreen,
  focusBorder,
  greenSuccess,
  lightShimmer,
  darkShimmer,
  shimmerBaseColor,
  shimmerHighlightColor,
  pinkText,
  levelYellow,
  questsCardPurple,
  levelTextBlue,
  levelTextPurple,
  endoOrange,
  pcosBlue,
  earlyPink,
  navbarTitle,
  shoppingTherapyHeaderChocolate,
}

const FlexSchemeData _myFlexScheme = FlexSchemeData(
  name: 'Midnight blue',
  description: 'Midnight blue theme, custom definition of all colors',
  light: FlexSchemeColor(
    primary: Color(0xFF00296B),
    primaryContainer: Color(0xFF2F5C91),
    secondary: Color(0xFFFF7B00),
    secondaryContainer: Color(0xFFFDB100),
  ),
  dark: FlexSchemeColor(
    primary: Color(0xFF6B8BC3),
    primaryContainer: Color(0xFF4874AA),
    secondary: Color(0xffff7155),
    secondaryContainer: Color(0xFFF1CB9D),
  ),
);

ThemeData marchMainThemeLight(ThemeController themeController) {
  return FlexThemeData.light(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // We could have stored the light scheme in a FlexSchemeColor
    // and used it for the colors, but we will use both the light and
    // dark colors also on the HomePage for the theme switch screens
    // and to display its name, where we pass it as a FlexSchemeData
    // object that contains both the light and dark scheme and its
    // name and description.
    colors: _myFlexScheme.light,
    background: const Color.fromRGBO(243, 243, 243, 1.0),
    onBackground: const Color.fromRGBO(243, 243, 243, 1.0),
    scaffoldBackground: const Color.fromRGBO(243, 243, 243, 1.0),

    // Opt in/out on FlexColorScheme sub-themes with theme controller.
    //subThemesData: themeController.useSubThemes,
    // Use very low elevation light theme mode. On light colored
    // AppBars this show up as a nice thin underline effect.
    appBarElevation: 0.5,
    // Here we want the large default visual density on all platforms.
    // Like Flutter SDK it default to
    // VisualDensity.adaptivePlatformDensity, which uses standard on
    // devices, but compact on desktops, compact is very compact,
    // maybe even a bit too compact
    // You can add a font via just a fontFamily from e.g. GoogleFonts.
    // For better results, prefer defining complete TextThemes,
    // using a font and its different styles, potentially even
    // more then one font, and then assign the TextTheme to the
    // textTheme and primaryTextTheme in FlexThemeData. This is
    // just how you would use it with ThemeData too.
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.normal,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.normal,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.normal,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontStyle: FontStyle.normal,
      ),
      displayLarge: TextStyle(
          fontSize: 18,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w400),
      displayMedium: TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w500),
      displaySmall: TextStyle(
          fontSize: 22,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
          fontSize: 28,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w800),
      titleLarge: TextStyle(
        fontSize: 30,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w900,
        fontFamily: GoogleFonts.nunitoSans().fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontStyle: FontStyle.normal,
      ),
      titleMedium: TextStyle(
        fontSize: 13,
        fontStyle: FontStyle.normal,
      ),
      titleSmall: TextStyle(
        fontSize: 11,
        fontStyle: FontStyle.normal,
      ),
    ),

    primary: mainBlueColor,
    fontFamily: GoogleFonts.nunito().fontFamily,
  );
}

final List<Color> cycleChartGradiant = [
  const Color(0xFFEC0079),
  const Color(0xFF6049BB),
];
final List<Color> lightGradiant = [
  HexColor('#74B9FF'),
  HexColor('#87ADFF'),
  HexColor('#A29BFE'),
];

final List<Color> premiumGradiant = [
  HexColor('#CB59BB'),
  HexColor('#9365FD'),
  HexColor('#617BFE'),
];

final List<Color> yellowGradiant = [
  const Color(0xFFFFEB4D),
  const Color(0xFFFFEB4D),
  const Color(0xFFFFEB4D),
  const Color(0xFFFFEB4D),
  const Color(0xFFFFEB4D),
  const Color(0xFFFDB100),
  const Color(0xFFFDB100),
  const Color(0xFFFE7100).withOpacity(0.5),
  const Color(0xFFFDB100),
  const Color(0xFFFFEB4D),
  const Color(0xFFFFEB4D),
];

final List<Color> darkGradiant = [
  HexColor('#EC0079'),
  HexColor('#6049BB'),
];
final List<Color> cardRefGradiant = [
  HexColor('#6049BB'),
  HexColor('#FFA8EE'),
];

final List<Color> referGradiant = [
  HexColor('#A29BFE'),
  HexColor('#E1F0FF'),
];

final List<Color> lightGradiant2 = [
  HexColor('#B2ADEE'),
  HexColor('#A6C9F1'),
];
final List<Color> purpleGradiant = [
  const Color(0xff797EF6),
  const Color(0xff6750A4),
];
final List<Color> darkPurpleGradiant = [
  const Color(0xff2C2666),
  const Color(0xff5843AE),
];
final List<Color> bluePurpleGradiant = [
  const Color(0xffA09BFE),
  const Color(0xff74B9FF),
  const Color(0xffA29BFE),
];
final List<Color> darkBluePurpleGradiant = [
  const Color(0xff6750A4),
  const Color(0xff82C0FF),
  const Color(0xff6750A4),
];
final List<Color> fadeBluePurpleGradiant = [
  const Color(0xbb6750A4),
  const Color(0xbb82C0FF),
  const Color(0xbb6750A4),
];
final List<Color> fadeLightPurpleGradiant = [
  HexColor('#C1AAFF'),
  HexColor('#C4E1FF'),
  HexColor('#C1AAFF'),
];
final List<Color> uploadImageBluePurpleGradiant = [
  const Color(0xff7267E9),
  const Color(0xff5689F2),
];

final List<Color> pinkToPurpleGradiant = [
  HexColor('#AC74E1'),
  HexColor('#7A8AFB'),
];

final List<Color> purpleToPinkGradiant = [
  HexColor('#7A8AFB'),
  HexColor('#AC74E1'),
];

final List<Color> premiumCardGradiant = [
  HexColor('#74B9FF'),
  HexColor('#A29BFE'),
];

final List<Color> offerInfoGradiant = [
  HexColor('#6049BB'),
  HexColor('#EC0079'),
];

final List<Color> goldenColors = [
  Colors.amber,
  Colors.amberAccent,
  Colors.amber,
];
final marchColorData = {
  MarchColor.mainBg: const Color.fromRGBO(243, 243, 243, 1.0),
  MarchColor.errorBg: const Color.fromRGBO(246, 198, 198, 1.0),
  MarchColor.successColor: HexColor('#48B384'),
  MarchColor.successBg: HexColor('#DCF7E3'),
  MarchColor.mainBlack: const Color.fromRGBO(47, 46, 65, 1.0),
  MarchColor.blackPurple: HexColor('#514E7F'),
  MarchColor.blackPurpleV2: HexColor('#9392AA'),
  MarchColor.extraBlack: Colors.black87,
  MarchColor.lightBlack: Colors.black54,
  MarchColor.blackShadow: const Color.fromRGBO(1, 1, 1, 0.4),
  MarchColor.endoOrange: HexColor('#F0CEC8'),
  MarchColor.pcosBlue: HexColor('#A5D5F4'),
  MarchColor.earlyPink: HexColor('#FFDEF6'),
  MarchColor.lightBlackShadow:
      const Color.fromRGBO(1, 1, 1, 0.1450980392156863),
  MarchColor.whiteShadow:
      const Color.fromRGBO(243, 243, 243, 0.9529411764705882),
  MarchColor.whiteShadowLv2:
      const Color.fromRGBO(238, 238, 238, 0.6980392156862745),
  MarchColor.extraLightBlack: const Color.fromRGBO(190, 190, 206, 1.0),
  MarchColor.borderPurple: HexColor('#6750A4'),
  MarchColor.transparent: Colors.transparent,
  MarchColor.grey: const Color.fromARGB(255, 91, 91, 103),
  MarchColor.ringSideColor: const Color.fromARGB(255, 238, 238, 238),
  MarchColor.lightGrey: const Color.fromARGB(37, 102, 102, 106),
  MarchColor.primary: const Color.fromARGB(255, 103, 80, 164),
  MarchColor.errorColor: const Color.fromRGBO(217, 53, 79, 1.0),
  MarchColor.white: const Color.fromRGBO(255, 255, 255, 1.0),
  MarchColor.focusBorder: const Color.fromRGBO(113, 116, 227, 1),
  MarchColor.redDark: Colors.red,
  MarchColor.redLight: Colors.redAccent,
  MarchColor.redCalendarPeriod: const Color.fromRGBO(255, 118, 117, 1.0),
  MarchColor.blueDark: Colors.blue,
  MarchColor.purpleExtraDark: Colors.blueAccent,
  MarchColor.greenDark: Colors.green,
  MarchColor.greenLight: Colors.greenAccent,
  MarchColor.yellowDark: Colors.yellow,
  MarchColor.yellowLight: Colors.yellowAccent,
  MarchColor.purpleDark: Colors.purple,
  MarchColor.purpleLight: Colors.purpleAccent,
  MarchColor.greenSuccess: const Color.fromRGBO(31, 199, 167, 1),
  MarchColor.mainPurple: const Color.fromRGBO(121, 126, 246, 1.0),
  MarchColor.ringRedColor: const Color.fromRGBO(255, 118, 117, 1.0),
  MarchColor.ringGreyColor: HexColor('#BEBECE'),
  MarchColor.ringBlueColor: const Color.fromRGBO(114, 182, 252, 1.0),
  MarchColor.ringPurpleColor: const Color.fromRGBO(159, 152, 250, 1.0),
  MarchColor.chartPointerColor: const Color.fromARGB(255, 205, 1, 105),
  MarchColor.chartBackGroundPurpleColor: const Color.fromARGB(255, 87, 90, 137),
  MarchColor.dayPickerColor: const Color.fromARGB(96, 232, 147, 195),
  MarchColor.timeLineGray: const Color.fromARGB(255, 228, 226, 226),
  MarchColor.disableBorder: const Color.fromARGB(255, 165, 182, 198),
  MarchColor.expireGreen: const Color.fromARGB(255, 158, 202, 84),
  MarchColor.calendarCurrentMonthCellColor:
      const Color.fromARGB(255, 190, 190, 206),
  MarchColor.calendarNormalDay: const Color.fromARGB(255, 190, 190, 206),
  MarchColor.calendarToday: const Color.fromARGB(255, 152, 152, 167),
  MarchColor.yearlyCalendarRed: const Color.fromARGB(255, 232, 147, 195),
  MarchColor.pink: const Color.fromARGB(255, 232, 147, 195),
  MarchColor.pinkText: const Color.fromARGB(255, 255, 156, 235),
  MarchColor.pinkBg: HexColor('#EADDFF'),
  MarchColor.mustard: const Color.fromARGB(255, 222, 167, 0),
  MarchColor.yearlyCalendarBlue: const Color.fromARGB(255, 125, 180, 243),
  MarchColor.yearlyCalendarNormal: const Color.fromARGB(255, 112, 112, 128),
  MarchColor.purpleExtraDark: const Color.fromARGB(255, 103, 80, 164),
  MarchColor.taskProgressGray: const Color.fromARGB(255, 176, 167, 192),
  MarchColor.commentColor: HexColor('#381E72'),
  MarchColor.purpleBG: HexColor('#EBE9FF'),
  MarchColor.blueTitle: HexColor('#3C88EA'),
  MarchColor.purpleTitle: HexColor('#6C63FF'),
  MarchColor.redTitle: HexColor('#D9354F'),
  MarchColor.redGradiant: HexColor('#DD334E'),
  MarchColor.blueGradiant: HexColor('#74B9FF'),
  MarchColor.blueBMI: HexColor('#74B9FF'),
  MarchColor.greenBMI: HexColor('#48B384'),
  MarchColor.redBMI: HexColor('#DD334E'),
  MarchColor.darkRedBMI: HexColor('#BD2E62'),
  MarchColor.yellowBMI: HexColor('#F8C422'),
  MarchColor.storyBGColor: const Color.fromARGB(255, 247, 248, 255),
  MarchColor.textGray: const Color.fromARGB(255, 63, 61, 86),
  MarchColor.textLightGray: const Color.fromARGB(255, 51, 51, 59),
  MarchColor.storyBGColor: const Color.fromARGB(255, 243, 241, 241),
  MarchColor.tableColor: const Color.fromRGBO(227, 241, 255, 1.0),
  MarchColor.createStoryBGColor: const Color.fromARGB(255, 231, 231, 231),
  MarchColor.targetColor: const Color.fromARGB(255, 236, 0, 121),
  MarchColor.darkShimmer: const Color.fromRGBO(31, 31, 31, 0.3),
  MarchColor.lightShimmer: const Color.fromRGBO(240, 240, 240, 1),
  MarchColor.monthlyChartRedColor: HexColor('#D17D97'),
  MarchColor.monthlyChartBlueColor: HexColor('#575A89'),
  MarchColor.mainGreenColor: HexColor('#48B384'),
  MarchColor.notifBg: const Color.fromARGB(255, 180, 171, 231),
  MarchColor.mainBottomSheetBG: const Color.fromARGB(255, 175, 165, 190),
  MarchColor.commentBgColor: const Color.fromARGB(255, 56, 30, 114),
  MarchColor.commentBorderColor: HexColor('#381E72'),
  MarchColor.blackInput: HexColor('#212121'),
  MarchColor.blackText: HexColor('#33333B'),
  MarchColor.blueAvatar: HexColor('#5689F2'),
  MarchColor.orangeLight: HexColor('#EFDFD9'),
  MarchColor.orangeDeeper: HexColor('#CC917A'),
  MarchColor.purpleLighter: HexColor('#E0DAF1'),
  MarchColor.purpleDeeper: HexColor('#907ACC'),
  MarchColor.redMid: HexColor('#FFE8E8'),
  MarchColor.redMidDeeper: HexColor('#FF9999'),
  MarchColor.purpleMid: HexColor('#FFE6F8'),
  MarchColor.purpleMidDeeper: HexColor('#CC7AB5'),
  MarchColor.lightYellow: HexColor('#FFF6E1'),
  MarchColor.lightYellowDeeper: HexColor('#CCB47A'),
  MarchColor.pinkMid: HexColor('#EFD9DF'),
  MarchColor.pinkMidDeeper: HexColor('#EF8FA9'),
  MarchColor.greenMid: HexColor('#D9EEDB'),
  MarchColor.greenMidDeeper: HexColor('#7ACC82'),
  MarchColor.blueMid: HexColor('#DAE9EF'),
  MarchColor.blueMidDeeper: HexColor('#7AB4CC'),
  MarchColor.purpleVeryLight: HexColor('#DAE1EF'),
  MarchColor.tagColorIcon: HexColor('#B2A7D1'),
  MarchColor.greyDisable: HexColor('#e2e2e2'),
  MarchColor.yellowMid: HexColor('#FFF6E1'),
  MarchColor.sleepColor: HexColor('#CBBEE6'),
  MarchColor.greenStepper: HexColor('#78EF89'),
  MarchColor.vaginaAvatarColor: HexColor('#78ABEF'),
  MarchColor.grayLightColor: HexColor('#cacaca'),
  MarchColor.grayRef: HexColor('#ebe9f3'),
  MarchColor.liteBlueRef: HexColor('#e1f0ff'),
  MarchColor.dashColor: HexColor('#b1b0b0'),
  MarchColor.yellowBgAvatar: HexColor('#F7C822'),
  MarchColor.pinkBg: HexColor('#FFE8E8'),
  MarchColor.forumTitleColor: const Color.fromARGB(255, 113, 116, 227),
  MarchColor.levelYellow: const Color.fromARGB(255, 255, 235, 77),
  MarchColor.lilac: HexColor('#DADBFC'),
  MarchColor.expireRed: const Color.fromARGB(255, 220, 54, 46),
  MarchColor.levelTextBlue: const Color.fromARGB(255, 123, 179, 238),
  MarchColor.levelTextPurple: const Color.fromARGB(255, 128, 122, 209),

  MarchColor.paintPurple: const Color.fromRGBO(81, 69, 243, 1),
  MarchColor.paintLightPurple: const Color.fromRGBO(143, 94, 229, 1),
  MarchColor.paintRed: const Color.fromRGBO(243, 87, 87, 1),
  MarchColor.paintPink: const Color.fromRGBO(236, 95, 167, 1),
  MarchColor.paintGreen: const Color.fromRGBO(90, 226, 71, 1),
  MarchColor.paintBlue: const Color.fromRGBO(79, 232, 243, 1),
  MarchColor.paintYellow: const Color.fromRGBO(243, 171, 62, 1),
  MarchColor.paintGray: const Color.fromRGBO(165, 165, 165, 1),
  MarchColor.shimmerBaseColor: const Color.fromARGB(255, 185, 185, 185),
  MarchColor.shimmerHighlightColor: const Color.fromARGB(255, 209, 209, 209),
  MarchColor.questsCardPurple: const Color.fromARGB(255, 207, 207, 226),

// navbar
  MarchColor.navbarBg: HexColor('#3F3D56'),
  MarchColor.navbarTitle: const Color(0xff3f3d56),

  //Shopping Therapy
  MarchColor.shoppingTherapyHeaderChocolate: const Color(0xff5F4A3D),
};

const Color mainBlueColor = Color.fromARGB(255, 116, 185, 255);
Color errorColor = const Color.fromRGBO(217, 53, 79, 1.0);
Color notActiveColor = const Color.fromRGBO(0, 0, 0, 0.10196078431372549);
