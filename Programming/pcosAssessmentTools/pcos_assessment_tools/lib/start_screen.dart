import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcos_assessment_tools/chat_screen.dart';
import 'package:pcos_assessment_tools/march_style/hexColor.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'chat_btn.dart';
import 'march_style/march_size.dart';

class StartPage extends StatelessWidget {
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: HexColor.fromHex('#FCF6F9'),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),

            Container(
              margin: EdgeInsets.symmetric(horizontal: MarchSize.littleGap*8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const SizedBox(height: 20),
                _buildSectionTitle('Could Your Symptoms Be Related to PCOS?',font: 22,fontWeight: FontWeight.w900),
                 Text(
                  'Find Out in Minutes',
                  style: GoogleFonts.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),
                 Text(
                  'Polycystic Ovary Syndrome (PCOS) can present with various symptoms that often go unnoticed. This self-assessment is designed to help you understand if your symptoms align with PCOS and guide you toward taking the next steps.',
                  style: GoogleFonts.arimo(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),

                // Important Notice
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HexColor.fromHex('#FDE8E8'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Important:',
                        style: GoogleFonts.arimo(
                          fontSize: 15,
                          height: 1.6,
                          color: HexColor.fromHex('#1D192B'),
                          fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 3),
                       Text(
                        'This is not a medical diagnosis. Your results are meant to provide insights and support you in discussing symptoms with a healthcare provider.',
                        style: GoogleFonts.arimo(
                          fontSize: 13,
                          height: 1.6,
                          color: HexColor.fromHex('#1D192B'),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),

                // Why Take the Assessment
                const SizedBox(height: 20),
                _buildSectionTitle('Why Take the Assessment?',font: 16),
                const SizedBox(height: 12),
                 Text(
'''
• Gain clarity on potential symptoms.
• Learn about next steps for managing your health.
• Receive tailored resources and support directly to your inbox.''',
                  style: GoogleFonts.arimo(
                    fontSize: 12,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                // How It Works
                const SizedBox(height: 20),
                _buildSectionTitle('How It Works',font: 16),
                const SizedBox(height: 12),
                 Text(
                  '''
1️. Answer a Few Questions: Help us understand your symptoms and experiences.
2️. Get Personalized Insights: Receive a score indicating the likelihood of experiencing PCOS-related symptoms.
3️. Access Resources & Support: Explore tools and information to navigate your health journey.''',
                  style: GoogleFonts.arimo(
                    fontSize: 12,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                // Contact Information
                const SizedBox(height: 20),
                 Row(
                   children: [
                     Text(
                      '📩 Have Questions? ',
                      style: GoogleFonts.arimo(
                        fontSize: 12,
                        height: 1.6,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                                     ),
                     Text(
                       'Email us anytime at support@march.health',
                       style: GoogleFonts.arimo(
                         fontSize: 12,
                         height: 1.6,
                         fontWeight: FontWeight.w500,
                         color: Colors.black87,
                       ),
                     ),
                   ],
                 ),

                  Row(
                    children: [
                      Text(
                        '🟢 Ready to Begin? ',
                        style: GoogleFonts.arimo(
                          fontSize: 12,
                          height: 1.6,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Click below to take the assessment and gain valuable insights!',
                        style: GoogleFonts.arimo(
                          fontSize: 12,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                // Call-to-Action
                  const SizedBox(height: 20),

                Center(
                  child: marchButton(
                      onPressed:(){
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ChatPage(),
                          ),
                        );
                      },
                      text: 'Get Started'),
                ),

              ],),
            )
            // Title Section

          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: size.width,
      padding: EdgeInsets.symmetric(
        vertical: MarchSize.littleGap * 3,
        horizontal: MarchSize.littleGap * 8,
      ),
      decoration: BoxDecoration(
        color: HexColor.fromHex('#F6CEEC'),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'March PCOS Self-Assessment',
                style: GoogleFonts.arimo(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: MarchSize.littleGap),
               Text(
                'Take the Quiz. Empower Yourself.',
                style: GoogleFonts.arimo(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Spacer(),
          CircularPercentIndicator(
            radius: 22.0,
            // Size of the circle
            lineWidth: 4.0,
            // Width of the progress bar line
            percent: 0,
            // The progress percentage (0.0 to 1.0)
            center: Text(
              "0%", // Text to display in the center
              style: GoogleFonts.arimo(fontSize: 10.0, fontWeight: FontWeight.w500),
            ),
            progressColor: HexColor.fromHex('#141313'),
            // Color of the progress line
            backgroundColor: HexColor.fromHex('#9C8294'),
            circularStrokeCap: CircularStrokeCap.round,
            // Rounded edges of the progress bar
            animation: true, // Enable animation for progress
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title,{double?  font,FontWeight ?fontWeight}) {
    return Text(
      title,
      style:  GoogleFonts.arimo(
        fontSize:font?? 18,
        fontWeight:fontWeight?? FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
