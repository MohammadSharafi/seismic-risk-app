import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcos_assessment_tools/chat_btn.dart';
import 'package:pcos_assessment_tools/march_style/march_size.dart';
import 'package:pcos_assessment_tools/req_model_class.dart';
import 'package:pcos_assessment_tools/start_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:html' as html;
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
import 'challenge_res_model.dart';
import 'clickableText.dart';
import 'generate_pdf.dart';
import 'march_style/hexColor.dart';
import 'march_style/march_icons.dart';

class ResultPage extends StatelessWidget {
  late Size size;
  final ChallengeResModel response;
  final ChallengeModel challengeModel;
  final String email;



  ResultPage({super.key, required this.response, required this.challengeModel, required this.email,});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    // Dynamic content based on state
    final stateConfig = _getStateContent(response.data?.challenge?.mMeta?.result??'');

    return Scaffold(
      backgroundColor: HexColor.fromHex('#FCF6F9'),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your Results Are In!',
                            style: GoogleFonts.arimo(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your Score: “${response.data?.challenge?.mMeta?.totalScore??0}”',
                        style: GoogleFonts.arimo(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 28),
                      Text(
                        stateConfig['stateMessage'],
                        style: GoogleFonts.arimo(
                          fontSize: 22,
                          height: 1.6,
                          color: HexColor.fromHex(stateConfig['stateColor']),
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      SizedBox(height: 24),

                      Text(
                        stateConfig['meaning'],
                        style: GoogleFonts.arimo(
                          fontSize: 18,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('What You Should Know About Your Score'),
                      const SizedBox(height: 12),
                      Text(
                        stateConfig['about_score'],
                        style: GoogleFonts.arimo(
                          fontSize: 18,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 18),
                      _buildSectionTitle('What’s Next?'),
                      const SizedBox(height: 12),
                      Text(
                        stateConfig['new'],
                        style: GoogleFonts.arimo(
                          fontSize: 18,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),

                      _buildOfferSection(response.data?.challenge?.mMeta?.result??'',context,stateConfig),

                      SizedBox(height: 24),

                      _buildSectionTitle('Remember:'),
                      SizedBox(height: 18),

                      Text(
                        '${stateConfig['remember']}',
                        style: GoogleFonts.arimo(
                            fontSize: 18, height: 1.6, color: Colors.black87),
                      ),
                      SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(),
                          Spacer(),
                          ClickableTextWidget(
                            onTap: () async {
                              generatePdf(challengeModel, stateConfig['stateMessage_pdf'],stateConfig['stateColor'],stateConfig['meaning'],'${response.data?.challenge?.mMeta?.totalScore??0}');

                            },
                            text: 'Download Responses',
                          ),
                          Spacer(),
                          ClickableTextWidget(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => StartPage(),
                                ),
                                    (Route<dynamic> route) => false, // This condition removes all previous routes.
                              );
                            },
                            text: 'Retake the Assessment',
                          ),
                          Spacer(),
                          Spacer(),
                        ],
                      ),

                      SizedBox(height: 24),




                    ],
                  ),
                ),

              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: ElTooltip(
                content: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black), // Default text style
                    children: [
                      const TextSpan(
                        text:
                        'Your data is completely secure with us.\n Your privacy is our priority.\n Want to learn more? Check out our privacy policy.',
                      ),
                      TextSpan(
                        text: 'HERE.',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            html.window.open("https://march.health/privacy-policy/", "_blank");

                          },
                      ),
                    ],
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    MarchIcons.shield,
                    width: 40, // Adjust size as needed
                    height: 40,
                  ),
                ),
              ),
            )

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
          topRight: Radius.circular(16),
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
                  fontSize: 22,
                ),
              ),
              SizedBox(height: MarchSize.littleGap),
              Text(
                'Take the Quiz. Empower Yourself.',
                style: GoogleFonts.arimo(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 18,
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
              style: GoogleFonts.arimo(fontSize: 14.0, fontWeight: FontWeight.w500),
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
      style: GoogleFonts.arimo(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: Colors.black87,
      ),
    );
  }


  Widget _buildOfferSection(
      String likelihood, context, Map<String, dynamic> json) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: HexColor.fromHex(json['next_step_color']),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Next Step?',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white,fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: json['next_step'],
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                  ),
                ),
                TextSpan(
                  text: json['next_step_bold'],
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Spacer(),
              ElevatedButton(
                onPressed: () async {
                  String data = await generateLink(likelihood);
                  html.window.open(data, 'March');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  HexColor.fromHex(json['next_step_btn_color']),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Text(
                    'Start Your Health Journey',
                    style: TextStyle(
                      fontSize: 18,
                      color: HexColor.fromHex(json['next_step_btn_text_color']),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ), // Custom text style),
                  ),
                ), // Custom text style),
              ),
              Spacer(),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStateContent(String state) {
    switch (state) {
      case 'LOW_PCOS_POSSIBILITY':
        return {
          'stateMessage': '🟢 Your responses suggest a “Low” likelihood of PCOS.',
          'stateMessage_pdf': '🟢 Your responses suggest a Low likelihood of PCOS.',
          'stateColor': '#00B100',
          'meaning':
          "Good news! Your results show no major signs of PCOS. The March app can still support your wellness journey by helping you monitor any future changes and stay proactive with your health.",
          'about_score':
'''
Your result is based on several key factors commonly associated with PCOS. These factors can influence your health and help identify potential symptoms: 

🔄 Menstrual Irregularities: Hormonal imbalances can disrupt your cycle, a common sign of PCOS. 

💁‍♀️ Hirsutism: Increased hair growth can signal elevated androgen levels, often linked to PCOS. 

🌱 Acne & Skin Issues: Hormonal shifts may cause acne flare-ups. Tracking them helps identify triggers and solutions. 

⚖️ Weight & Metabolic Health: Maintaining a healthy weight can help reduce PCOS risks. 

👨‍👩‍👧 Family History: PCOS can be genetic, so understanding your family history is key for early detection.
''',
          'new':
'''
Managing PCOS is easier with the March app by your side. Here’s how March can help: 

💖 Cycle Tracking: Use March to log your periods and identify irregularities. Get actionable insights to help you manage your cycles more effectively. 

🧑‍🔬 Hormone Insights: Track symptoms like hair growth, acne, and mood changes with March. The app helps you monitor hormonal fluctuations and provides tips to manage them. 

🍎 Weight & Wellness: March can help you track your weight and BMI trends. You’ll receive recommendations for healthier habits to reduce PCOS symptoms and improve your well-being. 

👨‍👩‍👧 Family History Matters: Input your family’s medical history in the March app to get more personalized health insights and preventive strategies.
''',
          'remember':
          'This questionnaire is not a definitive diagnostic tool. If you’re experiencing concerning symptoms or health issues, we recommend discussing your results with a healthcare professional or gynecologist to ensure proper diagnosis and care.',
          'next_step':
          'Download the March app and start your journey to stay informed and manage your PCOS symptoms more effectively. Plus, ',
          'next_step_bold':
          'enjoy an exclusive 20% discount on your annual subscription! 🎁',
          'next_step_color': '#E478AC',
          'next_step_btn_color': '#F0D0EA',
          'next_step_btn_text_color': '#352F42',
        };
      case 'MEDIUM_PCOS_POSSIBILITY':
        return {
          'stateMessage': '🟠 Your responses suggest a “Medium” likelihood of PCOS.',
          'stateMessage_pdf': '🟠 Your responses suggest a Medium likelihood of PCOS',

          'stateColor': '#ED950F',
          'meaning':
          'Some of your responses suggest signs of PCOS. We recommend talking to a healthcare provider for further tests, like blood work or ultrasounds. The March app offers tools to track your cycle, weight, and symptoms, making it easier to manage your health and monitor changes over time.',
          'about_score':
'''
Your result is based on several key factors commonly associated with PCOS. These factors can influence your health and help identify potential symptoms: 

🔄 Menstrual Irregularities: Hormonal imbalances can disrupt your cycle, a common sign of PCOS. 

💁‍♀️ Hirsutism: Increased hair growth can signal elevated androgen levels, often linked to PCOS. 

🌱 Acne & Skin Issues: Hormonal shifts may cause acne flare-ups. Tracking them helps identify triggers and solutions. 

⚖️ Weight & Metabolic Health: Maintaining a healthy weight can help reduce PCOS risks. 

👨‍👩‍👧 Family History: PCOS can be genetic, so understanding your family history is key for early detection.
''',
          'new':
'''
Managing PCOS is easier with the March app by your side. Here’s how March can help: 

💖 Cycle Tracking: Use March to log your periods and identify irregularities. Get actionable insights to help you manage your cycles more effectively. 

🧑‍🔬 Hormone Insights: Track symptoms like hair growth, acne, and mood changes with March. The app helps you monitor hormonal fluctuations and provides tips to manage them. 

🍎 Weight & Wellness: March can help you track your weight and BMI trends. You’ll receive recommendations for healthier habits to reduce PCOS symptoms and improve your well-being. 

👨‍👩‍👧 Family History Matters: Input your family’s medical history in the March app to get more personalized health insights and preventive strategies.
''',
          'remember':
          'This questionnaire is not a definitive diagnostic tool. If you’re experiencing concerning symptoms or health issues, we recommend discussing your results with a healthcare professional or gynecologist to ensure proper diagnosis and care.',
          'next_step':
          'Download the March app and start your journey to stay informed and manage your PCOS symptoms more effectively. Plus, ',
          'next_step_bold':
          'enjoy an exclusive 50% discount on your annual subscription! 🎁',
          'next_step_color': '#E478AC',
          'next_step_btn_color': '#F0D0EA',
          'next_step_btn_text_color': '#352F42',
        };
      case 'HIGH_PCOS_POSSIBILITY':
        return {
          'stateMessage': '🔴 Your responses suggest a “High” likelihood of PCOS.',
          'stateMessage_pdf': '🔴 Your responses suggest a High likelihood of PCOS.',

          'stateColor': '#D34141',
          'meaning':
          'Your responses strongly align with PCOS symptoms. It’s essential to seek a detailed assessment from a healthcare provider. The March app can help you track your symptoms and prepare for those important conversations with your doctor. Early diagnosis can improve your quality of life and reduce long-term risks like infertility and insulin resistance.',
          'about_score':
'''
Your result is based on several key factors commonly associated with PCOS. These factors can influence your health and help identify potential symptoms:
 
🔄 Menstrual Irregularities: Hormonal imbalances can disrupt your cycle, a common sign of PCOS. 

💁‍♀️ Hirsutism: Increased hair growth can signal elevated androgen levels, often linked to PCOS. 

🌱 Acne & Skin Issues: Hormonal shifts may cause acne flare-ups. Tracking them helps identify triggers and solutions. 

⚖️ Weight & Metabolic Health: Maintaining a healthy weight can help reduce PCOS risks. 

👨‍👩‍👧 Family History: PCOS can be genetic, so understanding your family history is key for early detection.
''',
'new':
'''
Managing PCOS is easier with the March app by your side. Here’s how March can help: 

💖 Cycle Tracking: Use March to log your periods and identify irregularities. Get actionable insights to help you manage your cycles more effectively. 

🧑‍🔬 Hormone Insights: Track symptoms like hair growth, acne, and mood changes with March. The app helps you monitor hormonal fluctuations and provides tips to manage them. 

🍎 Weight & Wellness: March can help you track your weight and BMI trends. You’ll receive recommendations for healthier habits to reduce PCOS symptoms and improve your well-being. 

👨‍👩‍👧 Family History Matters: Input your family’s medical history in the March app to get more personalized health insights and preventive strategies.
''',
          'remember':
          'This questionnaire is not a definitive diagnostic tool. If you’re experiencing concerning symptoms or health issues, we recommend discussing your results with a healthcare professional or gynecologist to ensure proper diagnosis and care.',
          'next_step':
          'Download the March app and start your journey to stay informed and manage your PCOS symptoms more effectively. Plus, ',
          'next_step_bold':
          'enjoy an exclusive 50% discount on your annual subscription! 🎁',
          'next_step_color': '#E478AC',
          'next_step_btn_color': '#F0D0EA',
          'next_step_btn_text_color': '#352F42',
        };
      default:
        return {
          'stateMessage': '',
          'stateMessage_pdf': '',
          'stateColor': '',
          'meaning': '',
          'about_score':'',
          'remember': '',
          'next_step': '',
          'next_step_bold': '',
          'next_step_color': '#E478AC',
          'next_step_btn_color': '#F0D0EA',
          'next_step_btn_text_color': '#352F42',
        };
    }
  }


  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  void initDeepLinkData(String Offer) {
    String dateString = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    metadata = BranchContentMetaData()
      ..addCustomMetadata('EMAIL', '${email}')
      ..addCustomMetadata('OFFER', '${Offer}')
    ;


    final canonicalIdentifier = const Uuid().v4();
    buo = BranchUniversalObject(
        canonicalIdentifier: 'march/referral_$canonicalIdentifier',

        title: 'Special Offer Just for You!',
        imageUrl: 'https://march-health.sirv.com/Images/march_icon.png',
        contentDescription: 'Special Offer Just for You! - $dateString',
        contentMetadata: metadata,
        keywords: ['Plugin', 'Offer', 'Invite'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch);
    lp = BranchLinkProperties(
      channel: 'offer',
      feature: 'sharing',

      stage: 'discount offer',
      campaign: 'OFFERING',
    )
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200);

  }
  String url='';
  Future<String> generateLink(String  likelihood) async {

    if (likelihood.contains('LOW')) {
      return 'https://marchapp.app.link/iF9z8TI1NPb';
    }
    else if (likelihood.contains('MEDIUM')) {
      return 'https://marchapp.app.link/30zG5rr1NPb';
    }
    else if (likelihood.contains('HIGH')) {
      return 'https://marchapp.app.link/i0QYbkPONPb';
    }
    return '';
    // initDeepLinkData(Offer);
    // BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    //   url = response.result;
    //
    //   return url ;
  }
}
