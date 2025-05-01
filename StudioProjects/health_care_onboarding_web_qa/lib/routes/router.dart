

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';

import '../ConsentScreen.dart';
import '../NoEndoPage.dart';
import '../onboardingConfirmedPage.dart';
import '../payConfirmedPage.dart';
import '../programPage.dart';
import '../purchaseFailedPage.dart';
import '../questionary/screens/question_loading_page.dart';
import '../questionary/screens/survey_page.dart';
import '../under_eighteenPage.dart';
import '../welcomePage.dart';

part 'router.gr.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Page,Route',
)
// extend the generated private router
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();
  @override
  final List<AutoRoute> routes = [
    AutoRoute(page: WelcomeRoute.page, path: '/'),
    AutoRoute(page: SurveyRoute.page, path: '/SurveyPage'),
    AutoRoute(page: ProgramRoute.page, path: '/ProgramPage'),
    AutoRoute(page: ConsentRoute.page, path: '/ConsentPage'),
    AutoRoute(page: OnboardingConfirmedRoute.page, path: '/OnboardingConfirmedPage'),
    AutoRoute(page: PayConfirmedRoute.page, path: '/PayConfirmedPage'),
    AutoRoute(page: PurchaseFailedRoute.page, path: '/PurchaseFailedPage'),
    AutoRoute(page: UnderEighteenRoute.page, path: '/UnderEighteenPage'),
    AutoRoute(page: NoEndoRoute.page, path: '/NoEndoPage'),





  ];
}
