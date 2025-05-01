import 'package:flutter/widgets.dart';

/// March Custom Sizes that used all over the app
class MarchSize {
  MarchSize._instantiate();

  /// get Instance For March size to use all over the app
  static final MarchSize instance = MarchSize._instantiate();
  static double? _heightValue;
  static double? _widthValue;

  // Buttons size
  static const double _buttonsRadius = 24.0;
  static const Size _bigButtonSize = Size(320.0, 56.0);
  static const Size _mediumButtonSize = Size(320.0, 50.0);
  static const Size _smallButtonSize = Size(152.0, 45.0);
  static const Size _verySmallButtonSize = Size(68.0, 56.0);
  static const Size _circleButtonSize = Size(72.0, 72.0);

  // Inputs size
  static const double _inputsRadius = 8.0;
  static const Size _inputsSize = Size(320.0, 48.0);

  // Inputs size
  static const double _checkBoxRadius = 8.0;
  static const double _mainBorderRadius = 8.0;
  static const Size _checkBoxSize = Size(24.0, 24.0);

  // Vectors size
  static const double _vectorsSize = 88.0;

  /// values setters
  void setHeight(double h) => _heightValue = h;
  void setWidth(double w) => _widthValue = w;

  /// values getters - height
  static double? get height => _heightValue;

  /// values getters - width
  static double? get width => _widthValue;

  /// Screen size
  void initializingScreenSizes({
    required double height,
    required double width,
    double dpi = 1,
  }) {
    setHeight(height);
    setWidth(width);
  }

  // Buttons functions
  /// app button Radius
  static double get buttonRadius => _buttonsRadius;

  /// big button size
  static Size get bigButton => Size(
        _bigButtonSize.width,
        _bigButtonSize.height,
      );

  /// medium btn default Size
  static Size get mediumButton => Size(
        _mediumButtonSize.width,
        _mediumButtonSize.height,
      );

  /// small btn default Size
  static Size get smallButton => Size(
        _smallButtonSize.width,
        _smallButtonSize.height,
      );

  /// very-small btn default Size
  static Size get verySmallButton => Size(
        _verySmallButtonSize.width,
        _verySmallButtonSize.height,
      );

  /// circle btn default Size
  static Size get circleButton => Size(
        _circleButtonSize.width,
        _circleButtonSize.height,
      );

  /// Inputs functions
  static double get inputsRadius => _inputsRadius;

  /// Input Widgets Size
  static Size get inputs => Size(_inputsSize.width, _inputsSize.height);

  /// Check box functions
  static double get checkBoxRadius => _checkBoxRadius;
  static double get mainBorderRadius => _mainBorderRadius;

  /// ChatBox Default Size
  static Size get checkBox => Size(_checkBoxSize.width, _checkBoxSize.height);

  /// return Vector Size
  static double get vectors => _vectorsSize;

  /// return default IconSize
  static double get iconSizeTiny => 12;
  static double get iconSize => 21;
  static double get iconSizeLarge => 24;
  static double get iconSizeMedium => 18;
  static double get iconSizeSmall => 16;
  static double get iconExtraSizeSmall => 16;
  static double get iconExtraSizeLarge => 35;

  /// return IconBox Size
  static double get iconBoxSize => 40;

  /// return Big avatar size
  static double get avatarSizeBig => 88;

  /// return medium Avatar Size
  static double get avatarSizeMedium => 72;

  /// return small Avatar Size
  static double get avatarSizeSmall => 40;

  /// return appBar Size
  static double get appBarHeight => 56;

  /// return textField Radius
  static double get textFieldRadius => 12;
  static double get globalMediumRadius => 12;

  /// return smallBorder Width
  static double get smallBorderWidth => 1;

  /// return mediumBorder Width
  static double get mediumBorderWidth => 2;

  /// return bigBorder Width
  static double get bigBorderWidth => 3;

  /// return minimum Height for SuffixIcon
  static double get minHeightSuffixIconSize => 21;

  /// return minimum Width for SuffixIcon
  static double get minWidthSuffixIconSize => 21;

  /// return maximum Height for SuffixIcon
  static double get maxHeightSuffixIconSize => 24;

  /// return maximum Width for SuffixIcon
  static double get maxWidthSuffixIconSize => 24;

  /// return minimum Height for SuffixIcon
  static double get minHeightPrefixIconSize => 21;

  /// return minimum Height for SuffixIcon
  static double get minWidthPrefixIconSize => 21;

  /// return minimum Height for SuffixIcon
  static double get maxHeightPrefixIconSize => 24;

  /// return minimum Height for SuffixIcon
  static double get maxWidthPrefixIconSize => 24;

  /// Loading-Size
  static double get loadingSize => 200;

  /// Splash Circle motion Size
  static double get circleMotionDesign => 150;

  /// Splash march_logo motion Size
  static double get splashLogoSize => 120;
  static double get bmiCircle => 150;
  static double get logoSizeSmall => 60;

  /// paddings
  static double get paddingLongLeft => 64.0;
  static double get paddingMediumLeft => 24.0;
  static double get paddingLongTop => 40.0;
  static double get paddingExtraLongTop => 64.0;
  static double get paddingSmallTop => 32.0;
  static double get paddingExtraSmallTop => 18.0;
  static double get paddingMediumTop => 20.0;
  static double get marginMediumTop => 30.0;
  static double get marginLargeTop => 50.0;
  static double get marginSmallTop => 20.0;
  static double get marginExtraSmallTop => 10;
  static double get symmetricHorizontalPaddingMedium => 16.0;
  static double get symmetricVerticalPaddingMedium => 16.0;
  static double get symmetricHorizontalPaddingLong => 22.0;
  static double get symmetricHorizontalPaddingSmall => 10.0;
  static double get symmetricHorizontalPaddingExtraSmall => 8.0;
  static double get symmetricVerticalPaddingExtraSmall => 8.0;
  static double get littleGap => 4.0;
  static double get paddingVeryTinyBottom => 2.0;
  static double get paddingTinyBottom => 4.0;

  // Padding All
  static double get smallPaddingAll => 8.0;
  static double get largePaddingAll => 24.0;

  //padding Start

  static double get veryTinyPaddingStart => 2;
  static double get tinyCirclePaddingStart => 4;
  static double get smallCirclePaddingStart => 8;
  static double get mediumPaddingStart => 16;
  static double get largePaddingStart => 24;
  static double get xlargePaddingStart => 32;

  //padding End

  static double get veryTinyPaddingEnd => 2;
  static double get tinyCirclePaddingEnd => 4;
  static double get smallCirclePaddingEnd => 8;
  static double get mediumPaddingEnd => 16;
  static double get largePaddingEnd => 24;
  static double get xlargePaddingEnd => 32;

  //Text Field
  static double get textFieldHeight => 50;
  static double get textFieldHorizontalMargin => 24;

  //back ground
  static double get backGroundHeightForRich => 44;
  static double get backGroundWidthForRich => 140;
  static double get lineSpace => 8;
  static double get authAppBarSpace => 130;

  // Image Size - height
  static double get extraSmallImageHeight => 60.0;
  static double get smallImageHeight => 80.0;
  static double get mediumImageHeight => 180.0;
  static double get largeImageHeight => 230.0;
  static double get extraLargeImageHeight => 350.0;
  static double get outerRingRadiusFactor => 0.94;
  static double get gestureDetectorHandlerSize => 312;
  static double get innerShadowSize => 270;
  static double get innerShadowSpreadRadius => 26;
  static double get staticRingPaintSize => 244;
  // Image Size - width
  static double get smallImageHeightOnboard => 80.0;
  static double get mediumImageHeightOnboard => 300.0;

  /// Ring Size
  static double get gaugeRangeWidth => 0.15;
  static double get gaugeRangeOffset => -0.044;
  // big circle
  static double get bigCircleBlurRadiusBlack => 1;
  static double get bigCircleSpreadRadiusBlack => 0;
  static double get bigCircleBlurRadiusWhite => 10;
  static double get bigCircleSpreadRadiusWhite => 5;
  // small circle
  static double get smallCircleBlurRadiusBlack => 8;

  // chart Sizes
  static double get chartHeight => 100;
  static double get chartVerticalLineWidth => 2;
  static double get cycleDetailBackGroundHeight => 10;
  static double get cycleDetailHeight => 6;

  //calendar appBar
  static double get calendarBarRadius => 36;
  static double get communityBarRadius => 36;
  static double get communityBlurRadius => 10;
  static double get calendarBlurRadius => 10;
  static double get calendarSpreadRadius => 15;
  static double get communitySpreadRadius => 15;
  static double get calendarOffsetDY => 3;
  static double get communityOffsetDY => 3;
  static double get calendarBarHeight => 30;
  static double get communityBarHeight => 30;
  static double get calendarBarPadding => 6;
  static double get communityBarPadding => 6;
  static double get innerVerticalPadding => 20;

  //report
  static double get reportBigCardSize => 100;
  static double get reportSmallCardSize => 45;
  static double get commentRadius => 18;

  static double get modeChooserWidth => 230;
  static double get ringSize => 60;

  static double get badgeReportSize => 100;

  static double get challengeCardHeight => 80;
  static double get challengeCardWidth => 180;

  static double get stateTagWidth => 75;
  static double get stateTagHeight => 25;

//  Width
  static double get smallWidth => 22;
  static double get mediumWidth => 16;
  static double get largeWidth => 50;
  static double get xlargeWidth => 105;
  static double get xxLargeWidth => 64;
  static double get xxxLargeWidth => 324;

//  Radius
  static double get tinyRadius => 8;
  static double get smallRadius => 20;

  // Font
  static double get largeFont => 45;

//  Height
  static double get veryTinyHeight => 5;
  static double get smallHeight => 20;
  static double get mediumHeight => 16;
  static double get largeHeight => 24;
  static double get xlargeHeight => 32;
  static double get xxLargeHeight => 64;
  static double get xxxLargeHeight => 160;

  static SizedBox veryTinyHorizontalSpacer = const SizedBox(width: 2);
  static SizedBox tinyHorizontalSpacer = const SizedBox(width: 4);
  static SizedBox smallHorizontalSpacer = const SizedBox(width: 8);
  static SizedBox mediumHorizontalSpacer = const SizedBox(width: 16);
  static SizedBox largeHorizontalSpacer = const SizedBox(width: 24);
  static SizedBox xLargeHorizontalSpacer = const SizedBox(width: 32);
  static SizedBox xxLargeHorizontalSpacer = const SizedBox(width: 64);

  //Vertical Spacer
  static SizedBox veryTinyVerticalSpacer = const SizedBox(height: 2);
  static SizedBox tinyVerticalSpacer = const SizedBox(height: 4);
  static SizedBox smallVerticalSpacer = const SizedBox(height: 8);
  static SizedBox smallMediumVerticalSpace = const SizedBox(height: 12);
  static SizedBox mediumVerticalSpacer = const SizedBox(height: 16);
  static SizedBox largeVerticalSpacer = const SizedBox(height: 24);
  static SizedBox xLargeVerticalSpacer = const SizedBox(height: 32);
  static SizedBox xxLargeVerticalSpacer = const SizedBox(height: 64);

  // Circle Size

  static double get veryTinyCircle => 2;
  static double get tinyCircle => 4;
  static double get smallCircle => 8;
  static double get mediumCircle => 16;
  static double get largeCircle => 24;
  static double get xlargeCircle => 32;
  static double get xxLargeCircle => 64;

  static double get bannerSizeSmall => 100;
}
