import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/screens/consent_screen.dart';
import 'package:seismic_risk_app/presentation/screens/dashboard_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SeismicRiskApp(),
    ),
  );
}

class SeismicRiskApp extends StatelessWidget {
  const SeismicRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seismic Risk Assessment',
      theme: AppTheme.lightTheme,
      home: const ConsentScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
