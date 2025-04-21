import 'package:flutter/material.dart';
import 'package:march_web_qa/screens/quiz/question_page.dart';
import 'package:march_web_qa/screens/quiz/welcome_page.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';

import 'controllers/question_controller.dart';
import 'models/Questions.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      isToolbarVisible: false,
      builder: (context) =>  MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QuizProvider()),
        ],
        child: const QuizApp(),
      ),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const QuizLoader(),
    );
  }
}

class QuizLoader extends StatelessWidget {
  const QuizLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuizProvider>(context, listen: false);
    provider.initialize(parseQuestions(sample_data));

    return   const WelcomePage();
  }
}