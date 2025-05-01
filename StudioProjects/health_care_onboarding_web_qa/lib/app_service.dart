import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_care_onboarding_web_qa/questionary/controllers/paymentState.dart';
import 'package:health_care_onboarding_web_qa/questionary/models/questionary/QuestionaryReqModel.dart';
import 'package:health_care_onboarding_web_qa/questionary/models/questionary/questionary_repo.dart';
import 'package:health_care_onboarding_web_qa/routes/router.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../injection.dart';

mixin AppService {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set transparent status bar color (has no effect on web but safe to keep)
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    await initHive();
    configureInjection(Environment.prod);
    await registerSingletons();
  }
}

Future<void> registerSingletons() async {
  getIt.registerSingleton<AppRouter>(AppRouter());

  getIt.registerSingleton<QuestionaryRepository>(
    QuestionaryRepositoryImpl(getIt.get<Box<QuestionaryReqModel>>()),
  );

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<PaymentState>(PaymentState());
}

Future<void> initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(QuestionaryReqModelAdapter());
  Hive.registerAdapter(UserQuestionaryAdapter());

  final secureStorage = FlutterSecureStorage();
  // Web does not support secure storage or encryption easily
  if (kIsWeb) {
    final box = await Hive.openBox<QuestionaryReqModel>("QuestionaryReqModel");
    getIt.registerSingleton<Box<QuestionaryReqModel>>(box);
  } else {
    // Mobile/desktop encrypted Hive setup
    String? keyString = await secureStorage.read(key: 'hive_encryption_key');
    if (keyString == null) {
      var random = Random.secure();
      var keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      keyString = base64UrlEncode(keyBytes);
      await secureStorage.write(key: 'hive_encryption_key', value: keyString);
    }
    var key = base64Url.decode(keyString);

    final box = await Hive.openBox<QuestionaryReqModel>(
      "QuestionaryReqModel",
      encryptionCipher: HiveAesCipher(key),
    );

    getIt.registerSingleton<Box<QuestionaryReqModel>>(box);
  }
}
