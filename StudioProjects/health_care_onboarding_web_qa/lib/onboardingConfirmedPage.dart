import 'dart:async';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/march_style/march_icons.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/buttons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';


@RoutePage()
class OnboardingConfirmedPage extends StatelessWidget {
  const OnboardingConfirmedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                  color: Color(0xFF60C977),
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                MarchIcons.success, // Use a green checkmark image here
                height: 120,
              ),
              const SizedBox(height: 24),
               Text(
                'Your Onboarding Session is Confirmed!',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black,
                ),
                 textAlign: TextAlign.start,
              ),
              const SizedBox(height: 12),
               Text(
                'You are one step closer to beginning your journey with the Endometriosis Master Care Plan.\n\n'
                    'We are excited to meet you at your onboarding session, where we will help you get started with personalized support. '
                    'You will receive a confirmation email with your session details shortly.',
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 24),
               Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Next Step',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
               Text(
                'Before your session, take a moment to watch our walkthrough video.\n\n'
                    'It will show you how to set up your profile, track your symptoms, and get the most out of your care plan.\n\n'
                    'It is a simple way to feel prepared and confident as you begin.',
                style: GoogleFonts.nunito(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text("Walkthrough Video Placeholder")),
              ),
              const SizedBox(height: 32),
               Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Next, Get Ready\nDownload March Health',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
               Text(
                'To start your journey, download the March Health.\n'
                    'It is where you will track your symptoms, access personalized insights powered by AI, and connect with a community that truly understands.\n'
                    'Let’s get you set up and moving forward with care and confidence.',
                style: GoogleFonts.nunito(fontSize: 14),
              ),
              const SizedBox(height: 16),
              MarchButton(btnText: 'Download March Health', btnCallBack: (){}, buttonSize: ButtonSize.INFINITY, alignment: Alignment.center),

              const SizedBox(height: 24),
              Image.asset(
                MarchIcons.qrCode,// Replace with your actual QR image asset
                height: 120,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
