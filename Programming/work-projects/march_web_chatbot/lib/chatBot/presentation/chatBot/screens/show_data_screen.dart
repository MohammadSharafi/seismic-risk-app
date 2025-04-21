import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:march_web_chatbot/chatBot/presentation/chatBot/webBot_page.dart';
import 'package:provider/provider.dart';
import '../../../../common/config/march_style/hexColor.dart';
import '../../../../common/config/march_style/march_icons.dart';
import '../../../../common/config/march_style/march_size.dart';
import '../../../../common/config/widgets/Loading.dart';
import '../../../../common/config/widgets/button.dart';
import '../../../../common/config/widgets/slider/custom_slider.dart';
import '../controllers/assesment_notifier.dart';
import '../widgets/Y_confirm_button.dart';
import '../widgets/result_confirm_button.dart';
import '../widgets/show_daha_widgets.dart';


class ShowDataScreen extends StatelessWidget {
  ShowDataScreen(this.healthData);

  final HealthData healthData;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(0, 0),
          child: Container(height: 0),
        ),
        body: ChangeNotifierProvider(create: (_) => ChartUpdateNotifier(healthData), child: isMobile ? MobileViewShowData(size: size) : DesktopViewShowData(size: size)));
  }
}

class MobileViewShowData extends StatelessWidget {
  final Size size;
  AssessmentNotifier assessmentNotifier = AssessmentNotifier();

  MobileViewShowData({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor.fromHex('#F1EFF0'),
      child: SingleChildScrollView(
        child: Consumer<ChartUpdateNotifier>(
          builder: (BuildContext context, ChartUpdateNotifier chartUpdateNotifier, Widget? child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MarchSize.littleGap * 3,
                ),
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 90,
                      child: Center(
                          child: Image.asset(
                        MarchIcons.march_icon,
                        width: 60,
                      )),
                      decoration: BoxDecoration(
                          color: HexColor.fromHex('#2F2E41'),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(360),
                            bottomRight: Radius.circular(360),
                          )),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(
                  height: MarchSize.littleGap * 8,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: MarchSize.littleGap * 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'SARAH’S DIGITAL TWIN DASHBOARD',
                        style: GoogleFonts.montserrat(
                          color: HexColor.fromHex('#4A4458'),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 4,
                      ),
                      Text(
                        'This dashboard brings Sarah’s profile setup to life, letting you visualize how changes in her symptoms affect her overall health.',
                        style: GoogleFonts.montserrat(
                          color: HexColor.fromHex('#4A4458'),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 12,
                      ),
                      Text(
                        'PERSONAL PROFILE',
                        style: GoogleFonts.montserrat(
                          color: HexColor.fromHex('#4A4458'),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 8,
                      ),
                      Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Container(
                          width: size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(MarchIcons.avatar,width: 70,height: 70,),
                              SizedBox(
                                height: MarchSize.littleGap * 4,
                              ),
                              Text(
                                'Sarah Timlton',
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#4A4458'),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 2,
                              ),
                              Text(
                                'Patient ID: 4f76a3a2-b897-4bf8-c98d-08dc23f49a62',
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#4A4458'),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 4,
                              ),
                              Text(
                                'AGE',
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#514E7F'),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 2,
                              ),
                              Text(
                                '34 years old',
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#514E7F'),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 4,
                              ),
                              Text(
                                'DATE OF BIRTH',
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#514E7F'),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 2,
                              ),
                              Text(
                                '09.07.1990',
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#514E7F'),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 4,
                              ),
                              Text(
                                'BMI',
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#514E7F'),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 2,
                              ),
                              Text(
                                '21',
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#514E7F'),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 4,
                              ),
                              Text(
                                'LOCATION',
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#514E7F'),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 2,
                              ),
                              Text(
                                'Chicago, United States of America',
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#514E7F'),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(MarchSize.littleGap * 6),
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 6,
                      ),
                      Text(
                        'CURRENT HEALTH METRICS',
                        style: GoogleFonts.montserrat(
                          color: HexColor.fromHex('#4A4458'),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 8,
                      ),
                      Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Container(
                          width: size.width,
                          child: Column(
                            children: [
                              //1
                              Container(
                                width: size.width * 0.8,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      MarchIcons.bolt_icon,
                                      width: 12,
                                    ),
                                    SizedBox(
                                      width: MarchSize.littleGap * 2,
                                    ),
                                    Text(
                                      'Pain Level',
                                      style: GoogleFonts.montserrat(
                                        color: HexColor.fromHex('#4A4458'),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      chartUpdateNotifier.healthData.painLvl.toString(),
                                      style: GoogleFonts.montserrat(
                                        color: HexColor.fromHex('#4A4458'),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      '/10',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 3,
                              ),
                              Container(
                                height: 40,
                                width: size.width * 0.8,
                                child: GradientSliderWidget(
                                  percent: chartUpdateNotifier.healthData.painLvl / 10,
                                  colors: [
                                    HexColor.fromHex('#8BCE73'),
                                    HexColor.fromHex('#E5E32F'),
                                    HexColor.fromHex('#F0A147'),
                                    HexColor.fromHex('#E8632A'),
                                    HexColor.fromHex('#EA5555'),
                                  ],
                                  width: size.width * 0.8,
                                ),
                              ),

                              SizedBox(
                                height: MarchSize.littleGap * 6,
                              ),

                              //2
                              Container(
                                width: size.width * 0.8,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      MarchIcons.battery_icon,
                                      width: 16,
                                    ),
                                    SizedBox(
                                      width: MarchSize.littleGap * 2,
                                    ),
                                    Text(
                                      'Energy Level',
                                      style: GoogleFonts.montserrat(
                                        color: HexColor.fromHex('#4A4458'),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      ((chartUpdateNotifier.healthData.energyLvl) >= 6) ?'High':'Low',
                                      style: GoogleFonts.montserrat(
                                        color: HexColor.fromHex('#4A4458'),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 3,
                              ),
                              Container(
                                height: 40,
                                width: size.width * 0.8,
                                child: GradientSliderWidget(
                                  percent: chartUpdateNotifier.healthData.energyLvl / 10,
                                  colors: [
                                    HexColor.fromHex('#DDDDDD'),
                                    HexColor.fromHex('#514E7E'),
                                  ],
                                  width: size.width * 0.8,
                                ),
                              ),

                              SizedBox(
                                height: MarchSize.littleGap * 6,
                              ),

                              //3
                              Container(
                                width: size.width * 0.8,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      MarchIcons.blood_icon,
                                      width: 16,
                                    ),
                                    SizedBox(
                                      width: MarchSize.littleGap * 2,
                                    ),
                                    Text(
                                      'Cycle Regularity',
                                      style: GoogleFonts.montserrat(
                                        color: HexColor.fromHex('#4A4458'),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 3,
                              ),
                              Container(
                                height: 40,
                                width: size.width * 0.8,
                                child: RangeSliderWidget(
                                  tuples: chartUpdateNotifier.healthData.cycleRegularity.map((e) {
                                    return Tuple(e.first, e.last);
                                  }).toList(),
                                  pointerPositions: chartUpdateNotifier.healthData.cycle_regularity_current_position as double,
                                  width: size.width * 0.8,
                                ),
                              ),

                              SizedBox(
                                height: MarchSize.littleGap * 12,
                              ),

                              //4
                              Container(
                                width: size.width * 0.8,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      MarchIcons.happy_icon,
                                      width: 16,
                                    ),
                                    SizedBox(
                                      width: MarchSize.littleGap * 2,
                                    ),
                                    Text(
                                      'Mood Fluctuations',
                                      style: GoogleFonts.montserrat(
                                        color: HexColor.fromHex('#4A4458'),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      ((chartUpdateNotifier.healthData.moodFluctuations) >= 6) ?'High Variability':'Low Variability',
                                      style: GoogleFonts.montserrat(
                                        color: HexColor.fromHex('#4A4458'),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 6,
                              ),
                              Container(
                                width: size.width * 0.8,
                                child: Image.asset(
                                  ((chartUpdateNotifier.healthData.moodFluctuations) >= 6) ? MarchIcons.icon_high_phone : MarchIcons.icon_low_phone,
                                  width: size.width * 0.8,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),

                              SizedBox(
                                height: MarchSize.littleGap * 4,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(MarchSize.littleGap * 6),
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 12,
                      ),
                      Text(
                        'SYMPTOMS',
                        style: GoogleFonts.montserrat(
                          color: HexColor.fromHex('#4A4458'),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 4,
                      ),
                      Text(
                        'Adjust Sarah’s symptoms in real time to simulate fluctuations in Sarah’s condition.',
                        style: GoogleFonts.montserrat(
                          color: HexColor.fromHex('#4A4458'),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 8,
                      ),
                      Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Container(
                          width: size.width,
                          padding: EdgeInsets.all(MarchSize.littleGap * 6),
                          child: Column(
                            children: [
                              Wrap(
                                spacing: 16.0,
                                runSpacing: 16.0,
                                children: [5, 4, 3, 2, 1].asMap().entries.map((entry) {
                                  int initialValue = entry.value;
                                  int index = entry.key;

                                  return ChangeNotifierProvider(
                                    create: (_) => SliderProvider(initialValue),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: MarchSize.littleGap * 6),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                [MarchIcons.bolt_icon, MarchIcons.battery_exclamation_icon, MarchIcons.happy_icon, MarchIcons.blood_icon, MarchIcons.wind_icon][index],
                                                width: 14,
                                              ),
                                              SizedBox(
                                                width: MarchSize.littleGap * 2,
                                              ),
                                              Text(
                                                ['Pelvic Pain', 'Fatigue', 'Mood Fluctuations', 'Heavy Menstrual Bleeding', 'Bloating'][index],
                                                style: GoogleFonts.montserrat(
                                                  color: HexColor.fromHex('#4A4458'),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: MarchSize.littleGap * 3,
                                        ),
                                        CustomSlider(
                                          onTap: (SliderItem value) {
                                            chartUpdateNotifier.symptoms.update(
                                              value.name,
                                              (_) => value.value,
                                              ifAbsent: () => value.value,
                                            );
                                          },
                                          name: ['Pelvic Pain', 'Fatigue', 'Mood Fluctuations', 'Heavy Menstrual Bleeding', 'Bloating'][index],
                                        ),
                                        SizedBox(
                                          height: MarchSize.littleGap * 8,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(
                                height: MarchSize.littleGap * 8,
                              ),
                              Container(
                                  child: ResultConfirmButton(
                                controller: ButtonController(
                                    buttonText: 'Confirm Changes',
                                    onPressed: () async {
                                      Loading(
                                        context: context,
                                      ).show();

                                      Map<String, dynamic> data = {
                                        'symptoms': chartUpdateNotifier.symptoms,
                                      };
                                      // Convert to JSON string
                                      String jsonData = jsonEncode(data);
                                      HealthData healthData = await assessmentNotifier.sendData(jsonData);
                                      chartUpdateNotifier.healthData = healthData;

                                      Loading(
                                        context: context,
                                      ).dismiss();
                                    }),
                                size: 16,
                              ))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 8,
                      ),
                      Card(
                        color: HexColor.fromHex('#F4BBBB'),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Container(
                          width: size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    MarchIcons.light_emergency_on_icon,
                                    width: 20,
                                  ),
                                  SizedBox(
                                    width: MarchSize.littleGap * 2,
                                  ),
                                  Container(
                                    width: size.width*0.5,
                                    child: Text(
                                      chartUpdateNotifier.healthData.pain_recommendation_flag,
                                      style: GoogleFonts.montserrat(
                                        color: HexColor.fromHex('#2F2E41'),
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                chartUpdateNotifier.healthData.painRecommendation,
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#2F2E41'),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(MarchSize.littleGap * 6),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        color: HexColor.fromHex('#4A4458'),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Container(
                          width: size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'HEALTH AGENT\nSUGGESTIONS',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                chartUpdateNotifier.healthData.healthAgentSuggestion,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(MarchSize.littleGap * 6),
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 10,
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: MarchSize.littleGap*5,vertical: MarchSize.littleGap*3),
                  color: HexColor.fromHex('#302F41'),
                  width: size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    SizedBox(height: MarchSize.littleGap*8,),

                    Text(
                      'Discover March Health Assist:\nThe Next Step in Personalized Health Care',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize:24,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: MarchSize.littleGap*8,),

                    Text(
                      'March Health Assist is an innovative health agent created to deliver personalized support for various health concerns and questions. By collecting essential information, March Health Assist provides tailored recommendations and expert guidance. Whether supporting daily wellness routines or addressing specific health challenges, it acts as a trusted assistant, offering informed and compassionate care.',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: MarchSize.littleGap*8,),
                    YConfirmButton(controller: ButtonController(textSize: 14,buttonText: 'Explore March Health Assist',onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WebBotPage()),
                      );
                    }), size: 14,),
                    SizedBox(height: MarchSize.littleGap*8,),

                    Image.asset(MarchIcons.yCallBack,width: size.width*0.8,),
                    SizedBox(height: MarchSize.littleGap*8,),



                  ],),
                )

              ],
            );
          },
        ),
      ),
    );
  }
}

class DesktopViewShowData extends StatelessWidget {
  final Size size;
  AssessmentNotifier assessmentNotifier = AssessmentNotifier();

  DesktopViewShowData({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor.fromHex('#F1EFF0'),
      child: Consumer<ChartUpdateNotifier>(
        builder: (BuildContext context, ChartUpdateNotifier chartUpdateNotifier, Widget? child) {
          return Stack(
            children: [
              Row(
                children: [
                  Spacer(),
                  Image.asset(
                    MarchIcons.blur_bg_icon,
                    height: size.height,
                    fit: BoxFit.fitHeight,
                  ),
                ],
              ),
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),

                        child: Row(
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              child: Center(
                                  child: Image.asset(
                                MarchIcons.march_icon,
                                width: 90,
                              )),
                              decoration: BoxDecoration(
                                  color: HexColor.fromHex('#2F2E41'),
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(360),
                                    bottomLeft: Radius.circular(360),
                                  )),
                            ),
                            Spacer()
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Text(
                          'SARAH’S DIGITAL TWIN DASHBOARD',
                          style: GoogleFonts.montserrat(
                            color: HexColor.fromHex('#4A4458'),
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 4,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Text(
                          'This dashboard brings Sarah’s profile setup to life, letting you visualize how changes in her symptoms affect her overall health.',
                          style: GoogleFonts.montserrat(
                            color: HexColor.fromHex('#4A4458'),
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 28,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),

                        child: Text(
                          'PERSONAL PROFILE',
                          style: GoogleFonts.montserrat(
                            color: HexColor.fromHex('#4A4458'),
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 8,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),

                        child: Card(
                          color: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Container(
                            width: size.width,
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(MarchIcons.avatar,width: 120,height: 120,),

                                        SizedBox(
                                          height: MarchSize.littleGap * 12,
                                        ),
                                        Text(
                                          'Sarah Timlton',
                                          style: GoogleFonts.montserrat(
                                            color: HexColor.fromHex('#514E7F'),
                                            fontSize: 30,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        SizedBox(
                                          height: MarchSize.littleGap * 4,
                                        ),
                                        Text(
                                          'Patient ID: 4f76a3a2-b897-4bf8-c98d-08dc23f49a62',
                                          style: GoogleFonts.montserrat(
                                            color: HexColor.fromHex('#514E7F'),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                width: size.width * 0.1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'AGE',
                                                      style: GoogleFonts.montserrat(
                                                        color: HexColor.fromHex('#4A4458'),
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                    SizedBox(
                                                      height: MarchSize.littleGap * 5,
                                                    ),
                                                    Text(
                                                      '34 years old',
                                                      style: GoogleFonts.montserrat(
                                                        color: HexColor.fromHex('#514E7F'),
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w300,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Spacer(),
                                              Container(
                                                width: size.width * 0.3,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'DATE OF BIRTH',
                                                      style: GoogleFonts.montserrat(
                                                        color: HexColor.fromHex('#4A4458'),
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                    SizedBox(
                                                      height: MarchSize.littleGap * 5,
                                                    ),
                                                    Text(
                                                      '09.07.1990',
                                                      style: GoogleFonts.montserrat(
                                                        color: HexColor.fromHex('#514E7F'),
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w300,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: MarchSize.littleGap * 12,
                                        ),
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                width: size.width * 0.1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'BMI',
                                                      style: GoogleFonts.montserrat(
                                                        color: HexColor.fromHex('#4A4458'),
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                    SizedBox(
                                                      height: MarchSize.littleGap * 5,
                                                    ),
                                                    Text(
                                                      '21',
                                                      style: GoogleFonts.montserrat(
                                                        color: HexColor.fromHex('#514E7F'),
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w300,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Spacer(),
                                              Container(
                                                width: size.width * 0.3,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'LOCATION',
                                                      style: GoogleFonts.montserrat(
                                                        color: HexColor.fromHex('#4A4458'),
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                    SizedBox(
                                                      height: MarchSize.littleGap * 5,
                                                    ),
                                                    Text(
                                                      'Chicago, United States of America',
                                                      style: GoogleFonts.montserrat(
                                                        color: HexColor.fromHex('#514E7F'),
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w300,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                            padding: EdgeInsets.all(MarchSize.littleGap * 6),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 20,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Text(
                          'CURRENT HEALTH METRICS',
                          style: GoogleFonts.montserrat(
                            color: HexColor.fromHex('#4A4458'),
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 8,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Card(
                          color: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Container(
                            width: size.width,
                            child: Column(
                              children: [
                                //1
                                Container(
                                  width: size.width * 0.86,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        MarchIcons.bolt_icon,
                                        width: 12,
                                      ),
                                      SizedBox(
                                        width: MarchSize.littleGap * 2,
                                      ),
                                      Text(
                                        'PAIN LEVEL',
                                        style: GoogleFonts.montserrat(
                                          color: HexColor.fromHex('#4A4458'),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        chartUpdateNotifier.healthData.painLvl.toString(),
                                        style: GoogleFonts.montserrat(
                                          color: HexColor.fromHex('#4A4458'),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        '/10',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: MarchSize.littleGap * 3,
                                ),
                                Container(
                                  height: 40,
                                  width: size.width * 0.86,
                                  child: GradientSliderWidget(
                                    percent: chartUpdateNotifier.healthData.painLvl / 10,
                                    colors: [
                                      HexColor.fromHex('#8BCE73'),
                                      HexColor.fromHex('#E5E32F'),
                                      HexColor.fromHex('#F0A147'),
                                      HexColor.fromHex('#E8632A'),
                                      HexColor.fromHex('#EA5555'),
                                    ],
                                    width: size.width * 0.86,
                                  ),
                                ),

                                SizedBox(
                                  height: MarchSize.littleGap * 12,
                                ),

                                //2
                                Container(
                                  width: size.width * 0.86,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        MarchIcons.battery_icon,
                                        width: 16,
                                      ),
                                      SizedBox(
                                        width: MarchSize.littleGap * 2,
                                      ),
                                      Text(
                                        'ENERGY LEVEL',
                                        style: GoogleFonts.montserrat(
                                          color: HexColor.fromHex('#4A4458'),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        ((chartUpdateNotifier.healthData.energyLvl) >= 6) ?'High':'Low',
                                        style: GoogleFonts.montserrat(
                                          color: HexColor.fromHex('#4A4458'),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: MarchSize.littleGap * 3,
                                ),
                                Container(
                                  height: 40,
                                  width: size.width * 0.86,
                                  child: GradientSliderWidget(
                                    percent: chartUpdateNotifier.healthData.energyLvl / 10,
                                    colors: [
                                      HexColor.fromHex('#DDDDDD'),
                                      HexColor.fromHex('#514E7E'),
                                    ],
                                    width: size.width * 0.86,
                                  ),
                                ),

                                SizedBox(
                                  height: MarchSize.littleGap * 12,
                                ),

                                //3
                                Container(
                                  width: size.width * 0.86,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        MarchIcons.blood_icon,
                                        width: 16,
                                      ),
                                      SizedBox(
                                        width: MarchSize.littleGap * 2,
                                      ),
                                      Text(
                                        'CYCLE REGULARITY',
                                        style: GoogleFonts.montserrat(
                                          color: HexColor.fromHex('#4A4458'),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: MarchSize.littleGap * 3,
                                ),
                                Container(
                                  height: 40,
                                  width: size.width * 0.86,
                                  child: RangeSliderWidget(
                                    tuples: chartUpdateNotifier.healthData.cycleRegularity.map((e) {
                                      return Tuple(e.first, e.last);
                                    }).toList(),
                                    pointerPositions: chartUpdateNotifier.healthData.cycle_regularity_current_position as double,
                                    width: size.width * 0.86,
                                  ),
                                ),

                                SizedBox(
                                  height: MarchSize.littleGap * 12,
                                ),

                                //4
                                Container(
                                  width: size.width * 0.86,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        MarchIcons.happy_icon,
                                        width: 16,
                                      ),
                                      SizedBox(
                                        width: MarchSize.littleGap * 2,
                                      ),
                                      Text(
                                        'MOOD FLUCTUATIONS',
                                        style: GoogleFonts.montserrat(
                                          color: HexColor.fromHex('#4A4458'),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        ((chartUpdateNotifier.healthData.moodFluctuations) >= 6) ?'High Variability':'Low Variability',
                                        style: GoogleFonts.montserrat(
                                          color: HexColor.fromHex('#4A4458'),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: MarchSize.littleGap * 6,
                                ),
                                Container(
                                  width: size.width * 0.86,
                                  child: Image.asset(
                                    ((chartUpdateNotifier.healthData.moodFluctuations) >= 6) ? MarchIcons.icon_high_web : MarchIcons.icon_low_Web,
                                    width: size.width * 0.86,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),

                                SizedBox(
                                  height: MarchSize.littleGap * 4,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(MarchSize.littleGap * 6),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 20,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Text(
                          'SYMPTOMS',
                          style: GoogleFonts.montserrat(
                            color: HexColor.fromHex('#4A4458'),
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 4,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Text(
                          'Adjust Sarah’s symptoms in real time to simulate fluctuations in Sarah’s condition.',
                          style: GoogleFonts.montserrat(
                            color: HexColor.fromHex('#4A4458'),
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 8,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(right: MarchSize.littleGap * 2),
                                height: 900,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  child: Container(
                                    width: size.width,
                                    padding: EdgeInsets.all(MarchSize.littleGap * 6),
                                    child: Column(
                                      children: [
                                        Wrap(
                                          spacing: 16.0,
                                          runSpacing: 16.0,
                                          children: [5, 4, 3, 2, 1].asMap().entries.map((entry) {
                                            int initialValue = entry.value;
                                            int index = entry.key;

                                            return ChangeNotifierProvider(
                                              create: (_) => SliderProvider(initialValue),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(left: MarchSize.littleGap * 6),
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          [MarchIcons.bolt_icon, MarchIcons.battery_exclamation_icon, MarchIcons.happy_icon, MarchIcons.blood_icon, MarchIcons.wind_icon][index],
                                                          width: 18,
                                                        ),
                                                        SizedBox(
                                                          width: MarchSize.littleGap * 2,
                                                        ),
                                                        Text(
                                                          ['Pelvic Pain', 'Fatigue', 'Mood Fluctuations', 'Heavy Menstrual Bleeding', 'Bloating'][index],
                                                          style: GoogleFonts.montserrat(
                                                            color: HexColor.fromHex('#4A4458'),
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: MarchSize.littleGap * 3,
                                                  ),
                                                  CustomSlider(
                                                    onTap: (SliderItem value) {
                                                      chartUpdateNotifier.symptoms.update(
                                                        value.name,
                                                        (_) => value.value,
                                                        ifAbsent: () => value.value,
                                                      );
                                                    },
                                                    name: ['Pelvic Pain', 'Fatigue', 'Mood Fluctuations', 'Heavy Menstrual Bleeding', 'Bloating'][index],
                                                  ),
                                                  SizedBox(
                                                    height: MarchSize.littleGap * 8,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        SizedBox(
                                          height: MarchSize.littleGap * 8,
                                        ),
                                        Container(
                                            child: ResultConfirmButton(
                                          controller: ButtonController(
                                              buttonText: 'Confirm Changes',
                                              onPressed: () async {
                                                Loading(
                                                  context: context,
                                                ).show();

                                                Map<String, dynamic> data = {
                                                  'symptoms': chartUpdateNotifier.symptoms,
                                                };

                                                // Convert to JSON string
                                                String jsonData = jsonEncode(data);

                                                HealthData healthData = await assessmentNotifier.sendData(jsonData);
                                                chartUpdateNotifier.healthData = healthData;

                                                Loading(
                                                  context: context,
                                                ).dismiss();
                                              }),
                                          size: 16,
                                        ))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(left: MarchSize.littleGap * 2),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 285,
                                      child: Card(
                                        color: HexColor.fromHex('#F4BBBB'),
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24.0),
                                        ),
                                        child: Container(
                                          width: size.width,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                   SvgPicture.asset(MarchIcons.light_emergency_on_icon,width: 25,),
                                                  SizedBox(
                                                    width: MarchSize.littleGap * 1,
                                                  ),
                                                  Text(
                                                    chartUpdateNotifier.healthData.pain_recommendation_flag,
                                                    style: GoogleFonts.montserrat(
                                                      color: HexColor.fromHex('#2F2E41'),
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              Text(
                                                chartUpdateNotifier.healthData.painRecommendation,
                                                style: GoogleFonts.montserrat(
                                                  color: HexColor.fromHex('#2F2E41'),
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          padding: EdgeInsets.all(MarchSize.littleGap * 6),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Container(
                                      height: 585,
                                      child: Card(
                                        color: HexColor.fromHex('#4A4458'),
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24.0),
                                        ),
                                        child: Container(
                                          width: size.width,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'HEALTH AGENT SUGGESTIONS',
                                                    style: GoogleFonts.montserrat(
                                                      color: Colors.white,
                                                      fontSize: 28,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Text(
                                                chartUpdateNotifier.healthData.healthAgentSuggestion,
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                          padding: EdgeInsets.all(MarchSize.littleGap * 6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MarchSize.littleGap * 18,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: MarchSize.littleGap*16,vertical: MarchSize.littleGap*3),
                        color: HexColor.fromHex('#302F41'),
                        width: size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text(
                                'Discover March Health Assist:\nThe Next Step in Personalized Health Care',
                                style: GoogleFonts.montserrat(
                                  color: HexColor.fromHex('#FAFAFA'),
                                  fontSize:38,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(height: MarchSize.littleGap*8,),
                              SizedBox(
                                width: size.width*0.45,
                                child: Text(
                                  'March Health Assist is an innovative health agent created to deliver personalized support for various health concerns and questions. By collecting essential information, March Health Assist provides tailored recommendations and expert guidance. Whether supporting daily wellness routines or addressing specific health challenges, it acts as a trusted assistant, offering informed and compassionate care.',
                                  style: GoogleFonts.montserrat(
                                    color: HexColor.fromHex('#FAFAFA'),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                                SizedBox(height: MarchSize.littleGap*12,),

                              Container(
                                  width: size.width*0.3,
                                  child: YConfirmButton(controller: ButtonController(textSize: 24,buttonText: 'Explore March Health Assist',onPressed: (){

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => WebBotPage()),
                                    );

                                  }), size: 24,)),


                            ],),
                            Image.asset(MarchIcons.yCallBack,width: size.width*0.4,),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
