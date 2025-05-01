import 'dart:async';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/march_style/march_icons.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/buttons.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';






@RoutePage()
class NoEndoPage extends StatelessWidget {
  const NoEndoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [


                  Spacer(),

                   Text(
                    'Thank you for sharing your story with us. Right now, the Endometriosis Master Care Plan is designed for those with a confirmed diagnosis.\n\n'
                        'But your journey matters just as much, and we are here for you.\n'
                        'The March Health app can help you track your symptoms, find patterns, and feel more prepared when speaking with doctors.\n\n'
                        'To support you, we are offering 50% off your first year on the app.\n'
                        'Take this step toward clarity, confidence, and better care, you deserve it.',
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),



                  const SizedBox(height: 40),

                  MarchButton(
                    btnText: 'Get 50% Off and Start Today',
                    btnCallBack: () async {

                    },
                    buttonSize: ButtonSize.LARG,
                    alignment: Alignment.center,
                    hasPadding: false,
                  ),
                  Spacer(),

                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: 0,
          child: IgnorePointer(
            ignoring: true,
            child: Image.asset(MarchIcons.hands,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter),
          ),
        ),
      ],
    );
  }
}
