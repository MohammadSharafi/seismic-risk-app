import 'dart:async';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/march_style/march_icons.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/buttons.dart';
import 'package:health_care_onboarding_web_qa/routes/router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';



@RoutePage()
class PurchaseFailedPage extends StatelessWidget {
  const PurchaseFailedPage({super.key});

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
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text(
                        "PURCHASE FAILED",
                        style: GoogleFonts.montserrat(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color:HexColor('#FA7473'),
                        ),
                                     ),
                     ],
                   ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        MarchIcons.smartphone, // Use a green checkmark image here
                        height: 120,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                   Text(
                    'It looks like your payment did not go through.\nNo worries, this can happen sometimes. Your spot in the Endometriosis Master Care Plan is still reserved.',
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 24),
                   Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'What Happens Next?',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                   Text(
                    'If any amount was deducted, it will be automatically returned to your account within 24 hours by Stripe, our secure payment partner.',
                    style: GoogleFonts.nunito(fontSize: 14),
                  ),



                  const SizedBox(height: 24),
                   Text(
                    'What Should I Do Now?',
                     style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16),
                     textAlign: TextAlign.start,



                   ),
                  const SizedBox(height: 8),
                  Text(
                    'You can try again or contact us if you need help. We are here for you.',
                    style: GoogleFonts.nunito(fontSize: 14),
                  ),
                  Spacer(),
                  MarchButton(
                    btnText: 'Try Again',
                    btnCallBack: () async {
                      AutoRouter.of(context).replace(const ProgramRoute());
                    },
                    buttonSize: ButtonSize.LARG,
                    alignment: Alignment.center,
                    hasPadding: false,
                  ),
                  const SizedBox(height: 8),

                ],
              ),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: true,
          child: Image.asset(MarchIcons.hands2,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter),
        ),
      ],
    );
  }
}
