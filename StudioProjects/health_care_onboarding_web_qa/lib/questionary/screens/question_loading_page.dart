import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../march_style/march_size.dart';

@RoutePage()
class QuestionLoadingPage extends StatefulWidget {
  final String userName;

  const QuestionLoadingPage({Key? key, required this.userName}) : super(key: key);

  @override
  _QuestionLoadingPageState createState() => _QuestionLoadingPageState();
}

class _QuestionLoadingPageState extends State<QuestionLoadingPage> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

   // await AutoRouter.of(context).replace(AuthSliderRoute());

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               SizedBox(height: MarchSize.paddingExtraLongTop),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Building Your Personalized Health Plan, ${widget.userName}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Lottie.asset(
                  'assets/animation/Animation - 1713705557348.json',
                  height: MediaQuery.of(context).size.height * 0.56,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "We're analyzing your symptoms, cycle, and goals to create a plan just for you.\nHang tight. This will only take a moment!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
