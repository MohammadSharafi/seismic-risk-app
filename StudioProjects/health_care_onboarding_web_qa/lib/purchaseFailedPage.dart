import 'dart:async';
import 'dart:convert';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/march_style/march_icons.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/buttons.dart';
import 'package:health_care_onboarding_web_qa/routes/router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class PurchaseFailedPage extends StatefulWidget {
  const PurchaseFailedPage({super.key});

  @override
  _PurchaseFailedPageState createState() => _PurchaseFailedPageState();
}

class _PurchaseFailedPageState extends State<PurchaseFailedPage> {
  @override
  void initState() {
    super.initState();
    // Call sendDataFail after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sendDataFail();
    });
  }

  Future<void> sendDataFail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      final body = jsonEncode({
        "userIdentifier": "$userId",
        "category": "ENDO MASTER CARE PLAN SUBMISSION",
        "question": "Failed to purchase the Endometriosis Master Care Plan",
        "answer": "No",
        "questionId": "FAILED_TO_PURCHASE_ENDO_MASTER_CARE_PLAN",
      });

      final response = await http.post(
        Uri.parse(
            'https://api.march.health/monomarch/api/v1/webhooks/on-create-endo-master-care-plan-submissions'),
        headers: {
          "ngrok-skip-browser-warning": "69420",
          "on-create-endo-master-care-plan-submission-api-key":
          "Tz70zitgtytNFYPvkPUsSFhGTRSlYHTCBrjjCQGu4V7ZH7LIFnzREjSXPz0yITtZ",
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('Request Body: $body');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Data sent successfully ${response.body}');
      } else {
        throw Exception(
            'Failed to send data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print(e);
    }
  }

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
                          color: HexColor('#FA7473'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        MarchIcons.smartphone,
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
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700, fontSize: 16),
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
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700, fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can try again or contact us if you need help. We are here for you.',
                    style: GoogleFonts.nunito(fontSize: 14),
                  ),
                  const Spacer(),
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
          child: Image.asset(
            MarchIcons.hands2,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
      ],
    );
  }
}