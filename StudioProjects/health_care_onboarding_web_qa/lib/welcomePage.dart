import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/march_style/march_icons.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/buttons.dart';
import 'package:health_care_onboarding_web_qa/questionary/controllers/question_controller.dart';
import 'package:health_care_onboarding_web_qa/routes/router.dart';
import 'package:http/http.dart' as http;



@RoutePage()
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: 0,

          child: IgnorePointer(
            ignoring: true,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Image.asset(MarchIcons.welcomeCover,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter),
            ),
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
                    'Living with endometriosis can feel overwhelming, but you are not alone. We have created this care program to support you through the challenges and help you reclaim your strength.',
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Let’s take this first small step together.',
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.black87,fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),

                  Spacer(),


                  MarchButton(
                    btnText: 'Start My Journey',
                    btnCallBack: () async {
                      String userIdentifier = await getUserId();
                      sendData(
                          question:'start page',
                          questionId:'',
                          answer:'STARTED' ,
                          fullName: 'N/A',
                          userIdentifier: userIdentifier);
                      AutoRouter.of(context).push(SurveyRoute());
                    },
                    buttonSize: ButtonSize.LARG,
                    alignment: Alignment.center,
                    hasPadding: false,
                  ),

                  Spacer(),
                  Spacer(),

                ],
              ),
            ),
          ),
        ),

      ],
    );
  }


  Future<void> sendData(
      {required String question,
        required String questionId,
        required String answer,
        required String fullName,
        required String userIdentifier}) async {
    try {
      final  body =jsonEncode({
        "userIdentifier": "$userIdentifier",
        "category": "WELCOME PAGE",
        "question": "$question",
        "answer": "$answer",
        "questionId": "$questionId",
        "fullName": "$fullName"
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
        body:body,
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




}

