import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:pcos_assessment_tools/start_screen.dart';
import 'package:provider/provider.dart';
import 'API/injection.dart';
import 'message_provider.dart';

void main() async {
  configureDependencies(); // Initialize dependencies

  WidgetsFlutterBinding.ensureInitialized();

  await FlutterBranchSdk.init(enableLogging: false, disableTracking: false);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: MaterialApp(
        home: StartPage(),
      ),
    ),
  );
}