import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_service.dart';
import 'chatBot/presentation/chatBot/model/chat_bot_repo.dart';
import 'chatBot/presentation/chatBot/webBot_page.dart';
import 'injection.dart';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {

  AppService.init();


  HttpOverrides.global = MyHttpOverrides();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  getIt.registerSingleton<ChatBotRepository>(ChatBotRepositoryImpl(prefs));

  runApp(WebBotPage());

  runZonedGuarded(() {}, (error, stack) => (){});

}

