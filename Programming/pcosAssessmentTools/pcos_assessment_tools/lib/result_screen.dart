import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcos_assessment_tools/chat_btn.dart';
import 'package:pcos_assessment_tools/march_style/march_icons.dart';
import 'package:pcos_assessment_tools/march_style/march_size.dart';
import 'package:pcos_assessment_tools/req_model_class.dart';
import 'package:pcos_assessment_tools/start_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'challenge_res_model.dart';
import 'chat_screen.dart';
import 'generate_pdf.dart';
import 'march_style/hexColor.dart';

class ResultPage extends StatelessWidget {
  late Size size;
  final ChallengeResModel response;
  final ChallengeModel challengeModel;


  ResultPage({super.key, required this.response, required this.challengeModel,});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    // Dynamic content based on state
    final stateConfig = _getStateContent(response.data?.challenge?.mMeta?.result??'');

    return Scaffold(
      backgroundColor: HexColor.fromHex('#FCF6F9'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),

            // Main Content Section
            Container(
              width: size.width,
              padding: EdgeInsets.symmetric(
                vertical: MarchSize.littleGap * 4,
                horizontal: MarchSize.littleGap * 8,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your Results Are In!',
                        style: GoogleFonts.arimo(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Your Score: “${response.data?.challenge?.mMeta?.totalScore??0}”',
                    style: GoogleFonts.arimo(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,

                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    stateConfig['stateMessage'],
                    style: GoogleFonts.arimo(
                      fontSize: 14,
                      height: 1.6,
                      color: stateConfig['stateColor'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // Explanation Section
                  SizedBox(height: 20),
                  _buildSectionTitle('What Does This Mean?'),
                  SizedBox(height: 8),

                  Text(
                    stateConfig['meaning'],
                    style: GoogleFonts.arimo(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  // Understanding Your Score Section
                  SizedBox(height: 20),
                  _buildSectionTitle('Understanding Your Score:'),
                  SizedBox(height: 8),

                  Text(
                    stateConfig['scoreDetails'],
                    style: GoogleFonts.arimo(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  // Offer Section
                  SizedBox(height: 24),
                  _buildOfferSection(response.data?.challenge?.mMeta?.result??'',context),

                  // App Promotion Section
                  SizedBox(height: 24),
                  _buildSectionTitle('What’s Next?'),
                  SizedBox(height: 8),

                  Text(
                    '''
You can now download the app and sign in with the same email you used for the assessment to: 
• View your results and personalized health guide instantly. 
• Track symptoms and monitor your health patterns. 
• Access expert advice and tailored resources for managing PCOS.
                    ''',
                    style: GoogleFonts.arimo(fontSize: 14, height: 1.6, color: Colors.black87),
                  ),

                  SizedBox(height: 24),
                  _buildSectionTitle('Take Charge of Your Health'),
                  SizedBox(height: 8),



                  Text(
                    '''Your results are a starting point for meaningful action. With the March app, you’ll have the tools and support you need to navigate your journey.''',
                    style: GoogleFonts.arimo(fontSize: 14, height: 1.6, color: Colors.black87),
                  ),
                  SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      marchButton(
                        text: ' Download March App ',
                        onPressed: () async {
                          final Uri url = Uri.parse('https://march.health'); // Replace with your website
                          if (!await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          )) {
                            throw Exception('Could not launch $url');
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle('Why Choose March?'),
                  SizedBox(height: 8),

                  Text(
                    '''We are dedicated to empowering women’s health journeys with AI-Powered tools, information, and support tailored to their needs. Let us be part of your journey toward better health.''',
                    style: GoogleFonts.arimo(fontSize: 14, height: 1.6, color: Colors.black87),
                  ),

                  // Call-to-Action Buttons
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      marchButton(
                        text: ' Download Responses ',
                        onPressed: () {
                          generatePdf(challengeModel);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      marchButton(
                        text: 'Retake the Assessment',
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => StartPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),


                ],
              ),
            ),
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
            percent: 1,
            // The progress percentage (0.0 to 1.0)
            center: Text(
            "100%", // Text to display in the center
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


  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style:  GoogleFonts.arimo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildOfferSection(String state,context) {
    final offerText = state == 'low' || state == 'moderate'
        ? 'To support your journey, we’re offering you an exclusive 20% discount to access the March app annual subscription!'
        : 'Get your first month completely free on the March app, followed by a 15-month subscription for the price of 12—a full year and three bonus months for a single payment.';

    return Container(
      padding: EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: HexColor.fromHex('#FDE8E8'),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎁 Exclusive for You:',
            style: GoogleFonts.arimo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87,fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 8),
          Text(
            offerText,
            style: GoogleFonts.arimo(fontSize: 13, height: 1.6, color: Colors.black87),
          ),
          SizedBox(height: 10),

          Text(
            '⏳ But hurry. The offer expires in 24 hours!',
            style: GoogleFonts.arimo(fontSize: 15, height: 1.6, color: Colors.black87,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStateContent(String state) {
    switch (state) {
      case 'LOW_PCOS_POSSIBILITY':
        return {
          'stateMessage': '🟢 Your responses suggest a low probability of PCOS.',
          'stateColor': Colors.green,
          'meaning':
          'It’s important to maintain regular health check-ups and monitor any changes in your symptoms or health status.',
          'scoreDetails': '''
• Menstrual Irregularities: Hormonal imbalances are key indicators.
• Hirsutism and Acne: Provide insight into androgen levels.
• Weight and BMI: Overweight or obesity can exacerbate PCOS symptoms.
• Family History: Increases your likelihood of developing PCOS.''',
        };
      case 'MEDIUM_PCOS_POSSIBILITY':
        return {
          'stateMessage': '🟠 Your responses suggest a moderate probability of PCOS.',
          'stateColor': HexColor.fromHex('#ED950F'),
          'meaning':
          'Discuss these results with a healthcare provider who can conduct evaluations like physical examinations, blood tests, or ultrasounds.',
          'scoreDetails': '''
• Hormonal imbalances, irregular cycles, acne, weight, and family history contribute to PCOS risks.
• Early consultation helps manage symptoms and explore treatments effectively.''',
        };
      case 'HIGH_PCOS_POSSIBILITY':
        return {
          'stateMessage': '🔴 Your responses suggest a high probability of PCOS.',
          'stateColor': Colors.red,
          'meaning':
          'It is crucial to seek a thorough assessment from a healthcare provider.',
          'scoreDetails': '''
• Menstrual irregularities, hirsutism, acne, BMI, and family history are important factors reflected in your total score.
• Addressing these factors proactively can lead to better health outcomes.''',
        };
      default:
        return {};
    }
  }
}
