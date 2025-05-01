// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    ConsentRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ConsentPage(),
      );
    },
    NoEndoRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NoEndoPage(),
      );
    },
    OnboardingConfirmedRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OnboardingConfirmedPage(),
      );
    },
    PayConfirmedRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PayConfirmedPage(),
      );
    },
    ProgramRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProgramPage(),
      );
    },
    PurchaseFailedRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PurchaseFailedPage(),
      );
    },
    QuestionLoadingRoute.name: (routeData) {
      final args = routeData.argsAs<QuestionLoadingRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: QuestionLoadingPage(
          key: args.key,
          userName: args.userName,
        ),
      );
    },
    SurveyRoute.name: (routeData) {
      final args = routeData.argsAs<SurveyRouteArgs>(
          orElse: () => const SurveyRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SurveyPage(key: args.key),
      );
    },
    UnderEighteenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UnderEighteenPage(),
      );
    },
    WelcomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const WelcomePage(),
      );
    },
  };
}

/// generated route for
/// [ConsentPage]
class ConsentRoute extends PageRouteInfo<void> {
  const ConsentRoute({List<PageRouteInfo>? children})
      : super(
          ConsentRoute.name,
          initialChildren: children,
        );

  static const String name = 'ConsentRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NoEndoPage]
class NoEndoRoute extends PageRouteInfo<void> {
  const NoEndoRoute({List<PageRouteInfo>? children})
      : super(
          NoEndoRoute.name,
          initialChildren: children,
        );

  static const String name = 'NoEndoRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OnboardingConfirmedPage]
class OnboardingConfirmedRoute extends PageRouteInfo<void> {
  const OnboardingConfirmedRoute({List<PageRouteInfo>? children})
      : super(
          OnboardingConfirmedRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingConfirmedRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PayConfirmedPage]
class PayConfirmedRoute extends PageRouteInfo<void> {
  const PayConfirmedRoute({List<PageRouteInfo>? children})
      : super(
          PayConfirmedRoute.name,
          initialChildren: children,
        );

  static const String name = 'PayConfirmedRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProgramPage]
class ProgramRoute extends PageRouteInfo<void> {
  const ProgramRoute({List<PageRouteInfo>? children})
      : super(
          ProgramRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProgramRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PurchaseFailedPage]
class PurchaseFailedRoute extends PageRouteInfo<void> {
  const PurchaseFailedRoute({List<PageRouteInfo>? children})
      : super(
          PurchaseFailedRoute.name,
          initialChildren: children,
        );

  static const String name = 'PurchaseFailedRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [QuestionLoadingPage]
class QuestionLoadingRoute extends PageRouteInfo<QuestionLoadingRouteArgs> {
  QuestionLoadingRoute({
    Key? key,
    required String userName,
    List<PageRouteInfo>? children,
  }) : super(
          QuestionLoadingRoute.name,
          args: QuestionLoadingRouteArgs(
            key: key,
            userName: userName,
          ),
          initialChildren: children,
        );

  static const String name = 'QuestionLoadingRoute';

  static const PageInfo<QuestionLoadingRouteArgs> page =
      PageInfo<QuestionLoadingRouteArgs>(name);
}

class QuestionLoadingRouteArgs {
  const QuestionLoadingRouteArgs({
    this.key,
    required this.userName,
  });

  final Key? key;

  final String userName;

  @override
  String toString() {
    return 'QuestionLoadingRouteArgs{key: $key, userName: $userName}';
  }
}

/// generated route for
/// [SurveyPage]
class SurveyRoute extends PageRouteInfo<SurveyRouteArgs> {
  SurveyRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SurveyRoute.name,
          args: SurveyRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SurveyRoute';

  static const PageInfo<SurveyRouteArgs> page = PageInfo<SurveyRouteArgs>(name);
}

class SurveyRouteArgs {
  const SurveyRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'SurveyRouteArgs{key: $key}';
  }
}

/// generated route for
/// [UnderEighteenPage]
class UnderEighteenRoute extends PageRouteInfo<void> {
  const UnderEighteenRoute({List<PageRouteInfo>? children})
      : super(
          UnderEighteenRoute.name,
          initialChildren: children,
        );

  static const String name = 'UnderEighteenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [WelcomePage]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
      : super(
          WelcomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'WelcomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
