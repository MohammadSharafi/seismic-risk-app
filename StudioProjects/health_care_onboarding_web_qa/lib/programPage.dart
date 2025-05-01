import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/march_style/march_icons.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/buttons.dart';
import 'package:health_care_onboarding_web_qa/questionary/controllers/paymentState.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:html' as html;
import 'package:provider/provider.dart';

import 'injection.dart';

@RoutePage()
class ProgramPage extends StatefulWidget {
  const ProgramPage({Key? key}) : super(key: key);

  @override
  _ProgramPageState createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  void _launchEmail(String email) {
    html.window.open('mailto:$email', '_self');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                getIt.get<PaymentState>()..fetchPaymentDetails(context)),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Consumer<PaymentState>(builder: (context, paymentState, child) {
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JOIN THE',
                          style: GoogleFonts.montserrat(
                              color: HexColor('#3F3D56'),
                              fontWeight: FontWeight.w900,
                              fontSize: 24),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.centerLeft,
                              colors: [
                                HexColor('#FF7EFA'),
                                HexColor('#627AFE'),
                              ],
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            );
                          },
                          child: Text(
                            'ENDOMETRIOSIS',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              color: Colors.transparent,
                              shadows: [
                                const BoxShadow(
                                  color: Colors.white,
                                  spreadRadius: 5,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.centerLeft,
                              colors: [
                                HexColor('#FF7EFA'),
                                HexColor('#627AFE'),
                              ],
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            );
                          },
                          child: Text(
                            'MASTER CARE PROGRAM',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              color: Colors.transparent,
                              shadows: [
                                const BoxShadow(
                                  color: Colors.white,
                                  spreadRadius: 5,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),
                        Text(
                          "We’re so glad you are taking this important step for yourself. You’ll unlock a personalized 30-day care program designed to help ease your pain and support your journey with endometriosis. Let’s make this a true turning point together.",
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: 24),
                        // What's Included Section
                        Text(
                          "What’s Included in Your 30-Day Care Plan",
                          style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              height: 0.9,
                              color: HexColor('#3F3D56')),
                        ),
                        SizedBox(height: 16),
                        // Card with program details
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProgramItem(
                                icon: MarchIcons.program_treatment,
                                color: '#647AFE',
                                title: "Personalized Care Plan",
                                description:
                                    "Tailored recommendations based on your unique needs.",
                              ),
                              _buildProgramItem(
                                icon: MarchIcons.program_user_md_chat,
                                color: '#7B7BFE',
                                title: "Health Coach Session",
                                description:
                                    "Personalized support sessions to guide your next steps.",
                              ),
                              _buildProgramItem(
                                icon: MarchIcons.program_hr,
                                color: '#897BFD',
                                title: "VIP Community Access",
                                description:
                                    "A private, supportive space to connect, share, and learn with others on the same journey.",
                              ),
                              _buildProgramItem(
                                icon: MarchIcons.program_lesson,
                                color: '#A07CFD',
                                title: "Full Scientific Training Course",
                                description:
                                    "A complete, evidence-based educational program to help you manage symptoms and improve daily life.",
                              ),
                              _buildProgramItem(
                                icon: MarchIcons.program_room_service,
                                color: '#B47CFC',
                                title: "Nutrition Guidance",
                                description:
                                    "Simple, symptom-friendly nutrition advice to support your healing.",
                              ),
                              _buildProgramItem(
                                icon: MarchIcons.program_wisdom,
                                color: '#C57CFB',
                                title: "Mental Well-Being Support",
                                description:
                                    "Practical strategies to help you find emotional balance and build resilience.",
                              ),
                              _buildProgramItem(
                                icon: MarchIcons.program_webinar,
                                color: '#D87DFB',
                                title: "Live Webinars and Workshops",
                                description:
                                    "Real-time expert sessions to support your learning and growth.",
                              ),
                              _buildProgramItem(
                                icon: MarchIcons.program_analyse,
                                color: '#E87DFA',
                                title: "Symptom Tracker",
                                description:
                                    "Spot patterns and understand your body better.",
                              ),
                              _buildProgramItem(
                                icon: MarchIcons.program_file,
                                color: '#FA7DFA',
                                title: "Personalized Health Report",
                                description:
                                    "A summary of your tracked symptoms and progress to help you understand patterns and advocate for your care.",
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        // 30-Day Timeline Section
                        Text(
                          "Your 30-Day Timeline",
                          style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              height: 0.9,
                              color: HexColor('#3F3D56')),
                        ),

                        SizedBox(height: 8),
                        Text(
                          "Your Endometriosis Master Care Plan is designed to help you feel supported, seen, and empowered every step of the way.",
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 24),
                        // Ready to Start Section
                        Text(
                          "READY TO START YOUR JOURNEY?",
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            fontStyle: FontStyle.italic,
                            color: HexColor('#3F3D56'),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Join the Endometriosis Master Care Program for a one-time fee of \$50.",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 24),
                        // Money-Back Guarantee Section
                        Text(
                          "NO COMMITMENT. MONEY-BACK GUARANTEE.",
                          style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              height: 0.9,
                              color: HexColor('#3F3D56')),
                        ),

                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                "We want you to feel confident in your decision. If you are not satisfied within the first 7 days, contact us for a full refund. We guarantee a 100% refund within 7 days of purchase, no questions asked.",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            // Placeholder for the money-back guarantee badge
                            Image.asset(
                              MarchIcons.program_removebg,
                              width: 80,
                            )
                          ],
                        ),
                        SizedBox(height: 24),
                        // Your Info is Safe Section

                        Text(
                          "Your information is safe",
                          style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              height: 0.9,
                              color: HexColor('#3F3D56')),
                        ),

                        SizedBox(height: 8),
                        Text(
                          "We never sell or rent your personal information for marketing purposes.",
                          style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 0.9,
                              color: HexColor('#3F3D56')),
                        ),
                        SizedBox(height: 16),
                        // Secure Checkout Section
                        Text(
                          "Secure checkout",
                          style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              height: 0.9,
                              color: HexColor('#3F3D56')),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Your payment is encrypted and protected using Secure Sockets Layer (SSL) technology.",
                          style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 0.9,
                              color: HexColor('#3F3D56')),
                        ),
                        const SizedBox(height: 16),
                        // Need Help Section
                        Text(
                          "Need help?",
                          style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              height: 0.9,
                              color: HexColor('#3F3D56')),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Text(
                              "Send us an email: ",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 0.9,
                                color: HexColor('#3F3D56'),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _launchEmail('matt@march.health'),
                              child: Text(
                                "matt@march.health",
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  height: 0.9,
                                  color: HexColor('#3F3D56'),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: (!paymentState.isLoading)
                    ? IgnorePointer(
                        ignoring:(paymentState.paymentLink??'').isEmpty,
                        child: Opacity(
                          opacity: (paymentState.paymentLink??'').isNotEmpty? 1.0 : 0.5,
                          // Grey out when disabled
                          child: MarchButton(
                            btnText: 'Start Now',
                            btnCallBack: (paymentState.paymentLink??'').isNotEmpty
                                ? () {
                                    paymentState.initiatePayment();
                                  }
                                : () {},
                            // No-op when disabled
                            buttonSize: ButtonSize.LARG,
                            alignment: Alignment.center,

                          ),
                        ),
                      )
                    : Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: HexColor('#3F3D56'),
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProgramItem({
    required String icon,
    required String color,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration:
                BoxDecoration(color: HexColor(color), shape: BoxShape.circle),
            child: SvgPicture.asset(
              icon,
              width: 16,
              height: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: HexColor('#242424'),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: HexColor('#242424'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
