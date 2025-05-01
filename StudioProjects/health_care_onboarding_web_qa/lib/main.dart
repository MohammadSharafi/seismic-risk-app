import 'dart:async';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:health_care_onboarding_web_qa/routes/router.dart';
import 'app_service.dart';
import 'injection.dart';
import 'march_style/controllers/theme_controller.dart';
import 'march_style/march_theme.dart';
import 'march_style/theme_service/theme_service.dart';
import 'march_style/theme_service/theme_service_mem.dart';

void main() async {
  await AppService.init();
  final ThemeService themeService = ThemeServiceMem();
  await themeService.init();
  final ThemeController themeController = ThemeController(themeService);
  await themeController.loadAll();
  await init();

  runApp(
    shouldEnableDevicePreview()
        ? DevicePreview(
            enabled: true,
            isToolbarVisible: false,
            builder: (context) => App(themeController),
          )
        : App(themeController),
  );
}

bool shouldEnableDevicePreview() {
  // Enable DevicePreview only if running on the web or a desktop platform
  return kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

class App extends StatefulWidget {
  App(this.themeController, {Key? key}) : super(key: key);
  final ThemeController themeController;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  _AppState createState() => _AppState(themeController);
}

class _AppState extends State<App> {
  _AppState(this.themeController);

  final ThemeController themeController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controllerData.close();
    streamSubscription?.cancel();
  }

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();

  ///https://marchapp.app.link/hKZe0duOlQb
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: themeController,
        builder: (BuildContext context, Widget? child) {
          final router = getIt<AppRouter>();
          return MaterialApp.router(
            title: 'March',
            key: App.navigatorKey,
            theme: marchMainThemeLight(themeController),
            themeMode: themeController.themeMode,
            debugShowCheckedModeBanner: false,
            routerDelegate: AutoRouterDelegate(
              router,
            ),
            routeInformationParser: router.defaultRouteParser(),
          );
        });
  }
}
