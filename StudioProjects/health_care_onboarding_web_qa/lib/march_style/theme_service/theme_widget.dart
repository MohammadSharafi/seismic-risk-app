import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/src/theme/range_slider_theme.dart';
import 'package:syncfusion_flutter_core/src/theme/slider_theme.dart';
import 'calendar_theme.dart';
import 'daterangepicker_theme.dart';

/// Applies a theme to descendant Syncfusion screens.
///
/// If [SfTheme] is not specified, then based on the
/// [Theme.of(context).brightness], brightness for
/// Syncfusion screens will be applied.
///
/// ```dart
/// Widget build(BuildContext context) {
///   return Scaffold(
///     body: Center(
///       child: SfTheme(
///         data: SfThemeData(
///           chartThemeData: SfChartThemeData(
///             backgroundColor: Colors.grey,
///             brightness: Brightness.dark
///           )
///         ),
///         child: SfCartesianChart(
///         )
///       ),
///     )
///   );
/// }
/// ```
class SfTheme extends StatelessWidget {
  /// Creating an argument constructor of SfTheme class.
  const SfTheme({
    Key? key,
    this.data,
    required this.child,
  }) : super(key: key);

  /// Specifies a widget that can hold single child.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return Scaffold(
  ///     body: Center(
  ///       child: SfTheme(
  ///         data: SfThemeData(
  ///           chartThemeData: SfChartThemeData(
  ///             backgroundColor: Colors.grey,
  ///             brightness: Brightness.dark
  ///           )
  ///         ),
  ///         child: SfCartesianChart(
  ///         )
  ///       ),
  ///     )
  ///   );
  /// }
  /// ```
  final Widget child;

  /// Specifies the color and typography values for descendant screens.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return Scaffold(
  ///     body: Center(
  ///       child: SfTheme(
  ///         data: SfThemeData(
  ///           chartThemeData: SfChartThemeData(
  ///             backgroundColor: Colors.grey,
  ///             brightness: Brightness.dark
  ///           )
  ///         ),
  ///         child: SfCartesianChart(
  ///         )
  ///       ),
  ///     )
  ///   );
  /// }
  /// ```
  final SfThemeData? data;

  //ignore: unused_field
  static final SfThemeData _kFallbackTheme = SfThemeData.fallback();

  /// The data from the closest [SfTheme] instance that encloses the given
  /// context.
  ///
  /// Defaults to [SfThemeData.fallback] if there is no [SfTheme] in the given
  /// build context.
  ///
  static SfThemeData of(BuildContext context) {
    final _SfInheritedTheme? inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<_SfInheritedTheme>();
    return inheritedTheme?.data ??
        (Theme.of(context).colorScheme.brightness == Brightness.light
            ? SfThemeData.light()
            : SfThemeData.dark());
  }

  @override
  Widget build(BuildContext context) {
    return _SfInheritedTheme(data: data, child: child);
  }
}

class _SfInheritedTheme extends InheritedTheme {
  const _SfInheritedTheme({Key? key, this.data, required Widget child})
      : super(key: key, child: child);

  final SfThemeData? data;

  @override
  bool updateShouldNotify(_SfInheritedTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    final _SfInheritedTheme? ancestorTheme =
        context.findAncestorWidgetOfExactType<_SfInheritedTheme>();
    return identical(this, ancestorTheme)
        ? child
        : SfTheme(data: data, child: child);
  }
}

/// Holds the color and typography values for light and dark themes. Use
///  this class to configure a [SfTheme] widget.
///
/// To obtain the current theme, use [SfTheme.of].
///
/// ```dart
/// Widget build(BuildContext context) {
///   return Scaffold(
///     body: Center(
///       child: SfTheme(
///         data: SfThemeData(
///           chartThemeData: SfChartThemeData(
///             backgroundColor: Colors.grey,
///             brightness: Brightness.dark
///           )
///         ),
///         child: SfCartesianChart(
///         )
///       ),
///     )
///   );
/// }
/// ```
@immutable
class SfThemeData with Diagnosticable {
  /// Creating an argument constructor of SfThemeData class.
  factory SfThemeData({
    Brightness? brightness,
    SfCalendarThemeData? calendarThemeData,
    SfDateRangePickerThemeData? dateRangePickerThemeData,
    SfSliderThemeData? sliderThemeData,
    SfRangeSliderThemeData? rangeSliderThemeData,
  }) {
    brightness ??= Brightness.light;

    calendarThemeData =
        calendarThemeData ?? SfCalendarThemeData(brightness: brightness);
    dateRangePickerThemeData = dateRangePickerThemeData ??
        SfDateRangePickerThemeData(brightness: brightness);
    sliderThemeData = sliderThemeData ?? SfSliderThemeData();

    rangeSliderThemeData = rangeSliderThemeData ?? SfRangeSliderThemeData();
    return SfThemeData.raw(
      brightness: brightness,
      calendarThemeData: calendarThemeData,
      dateRangePickerThemeData: dateRangePickerThemeData,
      sliderThemeData: sliderThemeData,
      rangeSliderThemeData: rangeSliderThemeData,
    );
  }

  /// Create a [SfThemeData] given a set of exact values. All the values must be
  /// specified.
  ///
  /// This will rarely be used directly. It is used by [lerp] to
  /// create intermediate themes based on two themes created with the
  /// [SfThemeData] constructor.
  ///
  const SfThemeData.raw({
    required this.brightness,
    required this.calendarThemeData,
    required this.dateRangePickerThemeData,
    required this.sliderThemeData,
    required this.rangeSliderThemeData,
  });

  /// This method returns the light theme when no theme has been specified.
  factory SfThemeData.light() => SfThemeData(brightness: Brightness.light);

  /// This method is used to return the dark theme.
  factory SfThemeData.dark() => SfThemeData(brightness: Brightness.dark);

  /// The default color theme. Same as [SfThemeData.light].
  ///
  /// This is used by [SfTheme.of] when no theme has been specified.
  factory SfThemeData.fallback() => SfThemeData.light();

  /// The brightness of the overall theme of the
  /// application for the Syncusion screens.
  ///
  /// If [brightness] is not specified, then based on the
  /// [Theme.of(context).brightness], brightness for
  /// Syncfusion screens will be applied.
  ///
  /// Also refer [Brightness].
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///  return Scaffold(
  ///    appBar: AppBar(),
  ///      body: Center(
  ///        child: SfTheme(
  ///          data: SfThemeData(
  ///            brightness: Brightness.dark
  ///          ),
  ///          child: SfCartesianChart(),
  ///        ),
  ///      )
  ///   );
  /// }
  /// ```
  final Brightness brightness;

  /// Defines the default configuration of [SfPdfViewer] screens.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///  return Scaffold(
  ///    appBar: AppBar(),
  ///      body: Center(
  ///        child: SfTheme(
  ///          data: SfThemeData(
  ///            pdfViewerThemeData: SfPdfViewerThemeData()
  ///          ),
  ///      child: SfPdfViewer.asset(
  ///           'story_assets/flutter-succinctly.pdf',
  ///         ),
  ///        ),
  ///      )
  ///   );
  /// }
  /// ```
  final SfDateRangePickerThemeData dateRangePickerThemeData;

  /// Defines the default configuration of calendar screens.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///  return Scaffold(
  ///    appBar: AppBar(),
  ///      body: Center(
  ///        child: SfTheme(
  ///          data: SfThemeData(
  ///            calendarThemeData: SfCalendarThemeData()
  ///          ),
  ///          child: SfCalendar(),
  ///        ),
  ///      )
  ///   );
  /// }
  /// ```
  final SfCalendarThemeData calendarThemeData;

  /// Defines the default configuration of range slider screens.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///  return Scaffold(
  ///    appBar: AppBar(),
  ///      body: Center(
  ///        child: SfTheme(
  ///          data: SfThemeData(
  ///            rangeSliderThemeData: SfRangeSliderThemeData()
  ///          ),
  ///          child: SfRangeSlider(),
  ///        ),
  ///      )
  ///   );
  /// }
  /// ```
  final SfRangeSliderThemeData rangeSliderThemeData;

  /// Defines the default configuration of slider screens.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///  return Scaffold(
  ///    appBar: AppBar(),
  ///      body: Center(
  ///        child: SfTheme(
  ///          data: SfThemeData(
  ///            sliderThemeData: SfSliderThemeData()
  ///          ),
  ///          child: SfSlider(),
  ///        ),
  ///      )
  ///   );
  /// }
  /// ```
  final SfSliderThemeData sliderThemeData;

  /// Creates a copy of this theme but with the given
  /// fields replaced with the new values.
  SfThemeData copyWith({
    Brightness? brightness,
    SfCalendarThemeData? calendarThemeData,
    SfDateRangePickerThemeData? dateRangePickerThemeData,
    SfSliderThemeData? sliderThemeData,
    SfRangeSliderThemeData? rangeSliderThemeData,
  }) {
    return SfThemeData.raw(
      brightness: brightness ?? this.brightness,
      calendarThemeData: calendarThemeData ?? this.calendarThemeData,
      dateRangePickerThemeData:
          dateRangePickerThemeData ?? this.dateRangePickerThemeData,
      sliderThemeData: sliderThemeData ?? this.sliderThemeData,
      rangeSliderThemeData: rangeSliderThemeData ?? this.rangeSliderThemeData,
    );
  }

  /// Linearly interpolate between two themes.
  static SfThemeData lerp(SfThemeData? a, SfThemeData? b, double t) {
    assert(a != null);
    assert(b != null);

    return SfThemeData.raw(
      brightness: t < 0.5 ? a!.brightness : b!.brightness,
      calendarThemeData: SfCalendarThemeData.lerp(
          a!.calendarThemeData, b!.calendarThemeData, t)!,
      dateRangePickerThemeData: SfDateRangePickerThemeData.lerp(
          a.dateRangePickerThemeData, b.dateRangePickerThemeData, t)!,
      sliderThemeData:
          SfSliderThemeData.lerp(a.sliderThemeData, b.sliderThemeData, t)!,
      rangeSliderThemeData: SfRangeSliderThemeData.lerp(
          a.rangeSliderThemeData, b.rangeSliderThemeData, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is SfThemeData &&
        other.brightness == brightness &&
        other.calendarThemeData == calendarThemeData &&
        other.dateRangePickerThemeData == dateRangePickerThemeData &&
        other.sliderThemeData == sliderThemeData &&
        other.rangeSliderThemeData == rangeSliderThemeData;
  }

  @override
  int get hashCode {
    final List<Object> values = <Object>[
      brightness,
      calendarThemeData,
      dateRangePickerThemeData,
      sliderThemeData,
      rangeSliderThemeData,
    ];
    return Object.hashAll(values);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final SfThemeData defaultData = SfThemeData.fallback();
    properties.add(EnumProperty<Brightness>('brightness', brightness,
        defaultValue: defaultData.brightness));

    properties.add(DiagnosticsProperty<SfCalendarThemeData>(
        'calendarThemeData', calendarThemeData,
        defaultValue: defaultData.calendarThemeData));

    properties.add(DiagnosticsProperty<SfDateRangePickerThemeData>(
        'dateRangePickerThemeData', dateRangePickerThemeData,
        defaultValue: defaultData.dateRangePickerThemeData));

    properties.add(DiagnosticsProperty<SfRangeSliderThemeData>(
        'rangeSliderThemeData', rangeSliderThemeData,
        defaultValue: defaultData.rangeSliderThemeData));
    properties.add(DiagnosticsProperty<SfSliderThemeData>(
        'sliderThemeData', sliderThemeData,
        defaultValue: defaultData.sliderThemeData));
  }
}
