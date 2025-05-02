import 'dart:async';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/march_style/march_icons.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/buttons.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';







@RoutePage()
class UnderEighteenPage extends StatelessWidget {
  const UnderEighteenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: true,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Image.asset(MarchIcons.hands2,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.topCenter),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [


                  Spacer(),

                   Text(
                    'We’re so sorry to hear you are facing these challenges, and we appreciate you reaching out. Our Endometriosis Master Care Plan is designed for users 18 and older due to program requirements. We would love to support you in the future. If you would like, you can share this with a guardian who can explore the program on your behalf.',
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),

                  Spacer(),



                  MarchButton(
                    btnText: 'Return to Homepage',
                    btnCallBack: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.remove('STEP_2');
                      prefs.remove('STEP_3');
                      final Uri url = Uri.parse('https://march.health/');
                      if (await canLaunchUrl(url)) {
                        html.window.location.href = 'https://march.health/';
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    buttonSize: ButtonSize.LARG,
                    alignment: Alignment.center,
                    hasPadding: false,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.remove('STEP_2');
                      prefs.remove('STEP_3');
                      AutoRouter.of(context).replaceNamed('/');

                    },
                    child: Text(
                      'Back',
                      style: GoogleFonts.nunito(fontSize: 13, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Spacer(),

                ],
              ),
            ),
          ),
        ),

      ],
    );
  }
}
