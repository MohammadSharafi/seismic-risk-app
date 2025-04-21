import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../injection.dart';

abstract class AppService {
  static init() async {

    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent,));

    configureInjection(Environment.dev);

    await registerSingletons();

  }
}

Future<void> registerSingletons()async {


}

