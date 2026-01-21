import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/app.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VirtualHospitalApp(),
    ),
  );
}

class VirtualHospitalApp extends StatelessWidget {
  const VirtualHospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Hospital',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Disable text scaling to match React exactly
          ),
          child: child!,
        );
      },
      home: const App(),
    );
  }
}
