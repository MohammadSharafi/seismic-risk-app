import 'dart:async';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/march_style/march_icons.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/buttons.dart';
import 'package:health_care_onboarding_web_qa/questionary/models/questionary/QuestionaryReqModel.dart';
import 'package:health_care_onboarding_web_qa/questionary/models/questionary/questionary_repo.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:html' as html;

import 'injection.dart';

// Provider class to manage loading state
class PayConfirmedViewModel extends ChangeNotifier {
  bool _isLoading = false;

  PayConfirmedViewModel(){
    sendDataConfirm(

    );
  }

  bool get isLoading => _isLoading;

  Future<void> sendData(BuildContext context) async {
    if (_isLoading) return; // Prevent multiple calls

    _isLoading = true;
    notifyListeners();

    try {
      QuestionaryReqModel model = await getIt.get<QuestionaryRepository>().get();
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      String? sessionId = prefs.getString('sessionId');
      QuestionaryReqModel newModel = QuestionaryReqModel(
        userQuestionary: model.userQuestionary,
        sessionId: sessionId,
        userIdentifier: userId,
      );

      final response = await http.post(
        Uri.parse(
            'https://api.march.health/monomarch/api/v1/webhooks/on-endo-master-care-plan-onboarding'),
        headers: {
          'Content-Type': 'application/json',
          "ngrok-skip-browser-warning": "69420",
          "on-create-endo-master-care-plan-submission-api-key":
          "Tz70zitgtytNFYPvkPUsSFhGTRSlYHTCBrjjCQGu4V7ZH7LIFnzREjSXPz0yITtZ",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(newModel.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        WidgetsBinding.instance.addPostFrameCallback((_) {

          html.window.location.href = 'https://outlook.office.com/bookwithme/user/143098a1ce2f4559b77b436570b92ade@March.health/meetingtype/YveKdn3x60GHNizlEMtmkQ2?anonymous&ismsaljsauthenabled&ep=mcard';

        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to schedule onboarding session')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendDataConfirm() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? userId = prefs.getString('user_id');

      final  body =jsonEncode({
        "userIdentifier": "$userId",
        "category": "ENDO MASTER CARE PLAN SUBMISSION",
        "question": "Successfully paid for Endometriosis Master Care Plan",
        "answer": "Yes",
        "questionId": "SUCCESS",
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

@RoutePage()
class PayConfirmedPage extends StatelessWidget {
  const PayConfirmedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PayConfirmedViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "YOU'RE ALL SET",
                  style: GoogleFonts.montserrat(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: const Color(0xFF60C977),
                  ),
                ),
                const SizedBox(height: 16),
                Image.asset(
                  MarchIcons.smartphoneV2, // Use a green checkmark image here
                  height: 180,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Welcome to the\nEndometriosis Master Care Plan',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'We have sent you an email with all the details about your Endometriosis Master Care Plan, including how to get started and what to expect. Please check your inbox (and your spam or junk folder, just in case) for the next steps.',
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Let’s Get Started\nBook Your Onboarding Meeting',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your first step is to schedule your onboarding session. This meeting will introduce you to your care team, help you set your personal goals, and show you how to make the most of your program. Make sure to enter the email address that you applied with. Take a moment to book your session now and start your journey with confidence.',
                  style: GoogleFonts.nunito(fontSize: 14),
                ),
                const Spacer(),
                Consumer<PayConfirmedViewModel>(
                  builder: (context, viewModel, child) {
                    return viewModel.isLoading
                        ? const CircularProgressIndicator()
                        : MarchButton(
                      btnText: 'Schedule Your Onboarding Session',
                      btnCallBack: () {
                        viewModel.sendData(context);
                      },
                      buttonSize: ButtonSize.INFINITY,
                      alignment: Alignment.center,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}