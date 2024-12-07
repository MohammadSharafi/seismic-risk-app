import 'package:flutter/material.dart';
import 'package:pcos_assessment_tools/challenge_res_model.dart';
import 'package:pcos_assessment_tools/result_screen.dart';
import 'package:pcos_assessment_tools/start_screen.dart';
import 'package:provider/provider.dart';

import 'message_provider.dart';

void main() {

  runApp(
    ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: MaterialApp(
        home: StartPage(),
      ),
    ),
  );
}