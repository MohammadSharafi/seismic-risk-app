import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:march_web_chatbot/chatBot/presentation/chatBot/screens/show_data_screen.dart';
import 'package:provider/provider.dart';
import '../../../../common/config/march_style/hexColor.dart';
import '../../../../common/config/march_style/march_icons.dart';
import '../../../../common/config/march_style/march_size.dart';
import '../../../../common/config/widgets/Loading.dart';
import '../../../../common/config/widgets/button.dart';
import '../../../../common/config/widgets/checkbox/custom_check_box.dart';
import '../../../../common/config/widgets/slider/custom_slider.dart';
import '../controllers/assesment_notifier.dart';
import '../widgets/start_confirm_button.dart';


List<String> healthConditions = [];
List<String> treatmentGoals = [];
Map<String, int> symptoms = {};


class GetDataScreen extends StatelessWidget {
  const GetDataScreen();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    bool isMobile = MediaQuery
        .of(context)
        .size
        .width < 800;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(0, 0),
        child: Container(height: 0),
      ),
      body: isMobile ? MobileViewGetData(size: size) : DesktopViewGetData(size: size),
    );
  }
}

class MobileViewGetData extends StatelessWidget {
  final Size size;

  AssessmentNotifier assessmentNotifier = AssessmentNotifier();

  MobileViewGetData({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor.fromHex('#F1EFF0'),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                children: [
                  Text(
                    '1. HEALTH CONDITIONS',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 4,
                  ),
                  Text(
                    'Select Sarah’s reproductive health condition(s) to create her profile:',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 14,
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
                      child: Column(
                        children: [
                          'Endometriosis',
                          'PCOS',
                          'Irregular Menstrual Cycle',
                          'Other',
                        ].map((item) {
                          return ChangeNotifierProvider(
                            create: (_) => CheckboxModel(),
                            child: Container(
                              height: 50,
                              child: Row(
                                children: [
                                  CustomCheckbox(
                                    selectedSvgPath: MarchIcons.check_box_icon,
                                    iconSize: 25,
                                    unselectedWidget: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: HexColor.fromHex('#2F2E41'), width: 2)),
                                    ),
                                    onTap: (Item value) {
                                      if (value.isSelected) {
                                        healthConditions.add(value.name);
                                      }
                                      else {
                                        if (healthConditions.contains(value.name))
                                          healthConditions.remove(value.name);
                                      }
                                    },
                                    item: item,
                                  ),
                                  SizedBox(width: MarchSize.littleGap * 3),
                                  Text(
                                    item,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      padding: EdgeInsets.all(MarchSize.littleGap * 6),
                    ),
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 12,
                  ),
                  Text(
                    '2. SYMPTOMS',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 4,
                  ),
                  Text(
                    'Adjust Sarah’s symptom levels based on her current conditions.',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 14,
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
                      child: Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        children: [5, 4, 3, 2, 1]
                            .asMap()
                            .entries
                            .map((entry) {
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
                                          color: Colors.black,
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
                                CustomSlider(onTap: (SliderItem value) {
                                  symptoms.update(
                                    value.name,
                                        (_) => value.value,
                                    ifAbsent: () => value.value,
                                  );
                                }, name: ['Pelvic Pain', 'Fatigue', 'Mood Fluctuations', 'Heavy Menstrual Bleeding', 'Bloating'][index],),
                                SizedBox(
                                  height: MarchSize.littleGap * 8,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 12,
                  ),
                  Text(
                    '3. TREATMENT GOALS',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 4,
                  ),
                  Text(
                    'Set Sarah’s main goals for treatment and symptom management.',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 14,
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
                      child: Wrap(
                        children: [
                          'Pain Reduction',
                          'Cycle Regularity',
                          'Improved Mood Stability',
                          'Enhanced Energy',
                          'Reduced Bloating',
                        ].map((item) {
                          return ChangeNotifierProvider(
                            create: (_) => CheckboxModel(),
                            child: Container(
                              height: 50,
                              child: Row(
                                children: [
                                  CustomCheckbox(
                                    selectedSvgPath: MarchIcons.check_box_icon,
                                    unselectedWidget: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: HexColor.fromHex('#2F2E41'), width: 2)),
                                    ),
                                    iconSize: 25,
                                    onTap: (Item value) {

                                      if (value.isSelected) {
                                        treatmentGoals.add(value.name);
                                      }
                                      else {
                                        if (treatmentGoals.contains(value.name))
                                          treatmentGoals.remove(value.name);
                                      }
                                    },
                                    item: '',
                                  ),
                                  SizedBox(width: MarchSize.littleGap * 3),
                                  Text(
                                    item,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      padding: EdgeInsets.all(MarchSize.littleGap * 6),
                    ),
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 10,
                  ),
                  ConfirmButton(
                    controller: ButtonController(
                        buttonText: 'Confirm and Start Monitoring',
                        onPressed: () async {
                          Loading(context: context,).show();


                          Map<String, dynamic> data = {
                            'health_condition': healthConditions,
                            'symptoms': symptoms,
                            'treatment_goals': treatmentGoals,
                          };

                          // Convert to JSON string
                          String jsonData = jsonEncode(data);

                          HealthData  healthData =   await  assessmentNotifier.sendData(jsonData);

                          Loading(context: context,).dismiss();

                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ShowDataScreen(healthData)),
                          );
                        }
                    ),
                    size: 16,
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DesktopViewGetData extends StatelessWidget {
  final Size size;
  AssessmentNotifier assessmentNotifier = AssessmentNotifier();

  DesktopViewGetData({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor.fromHex('#F1EFF0'),
      child: Stack(
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
            margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
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
                  Text(
                    '1. HEALTH CONDITIONS',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 4,
                  ),
                  Text(
                    'Select Sarah’s reproductive health condition(s) to create her profile:',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 20,
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
                      child: Wrap(
                        children: [
                          'Endometriosis',
                          'PCOS',
                          'Irregular Menstrual Cycle',
                          'Other',
                        ].map((item) {
                          return ChangeNotifierProvider(
                            create: (_) => CheckboxModel(),
                            child: Container(
                              width: size.width * 0.4,
                              height: 50,
                              child: Row(
                                children: [
                                  CustomCheckbox(
                                    selectedSvgPath: MarchIcons.check_box_icon,
                                    unselectedWidget: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: HexColor.fromHex('#2F2E41'), width: 2)),
                                    ),
                                    iconSize: 25,
                                    onTap: (Item value) {
                                      if (value.isSelected) {
                                        healthConditions.add(value.name);
                                      }
                                      else {
                                        if (healthConditions.contains(value.name))
                                          healthConditions.remove(value.name);
                                      }
                                    },
                                    item: item,
                                  ),
                                  SizedBox(width: MarchSize.littleGap * 3),
                                  Text(
                                    item,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      padding: EdgeInsets.all(MarchSize.littleGap * 6),
                    ),
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 22,
                  ),
                  Text(
                    '2. SYMPTOMS',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 4,
                  ),
                  Text(
                    'Adjust Sarah’s symptom levels based on her current conditions.',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 20,
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
                      child: Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        children: [5, 4, 3, 2, 1]
                            .asMap()
                            .entries
                            .map((entry) {
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
                                          color: Colors.black,
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
                                CustomSlider(onTap: (SliderItem value) {
                                  symptoms.update(
                                    value.name,
                                        (_) => value.value,
                                    ifAbsent: () => value.value,
                                  );
                                }, name: ['Pelvic Pain', 'Fatigue', 'Mood Fluctuations', 'Heavy Menstrual Bleeding', 'Bloating'][index],),
                                SizedBox(
                                  height: MarchSize.littleGap * 8,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 22,
                  ),
                  Text(
                    '3. TREATMENT GOALS',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 4,
                  ),
                  Text(
                    'Set Sarah’s main goals for treatment and symptom management.',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 20,
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
                      child: Wrap(
                        children: [
                          'Pain Reduction',
                          'Cycle Regularity',
                          'Improved Mood Stability',
                          'Enhanced Energy',
                          'Reduced Bloating',
                        ].map((item) {
                          return ChangeNotifierProvider(
                            create: (_) => CheckboxModel(),
                            child: Container(
                              width: size.width * 0.4,
                              height: 50,
                              child: Row(
                                children: [
                                  CustomCheckbox(
                                    item: item,
                                    selectedSvgPath: MarchIcons.check_box_icon,
                                    unselectedWidget: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: HexColor.fromHex('#2F2E41'), width: 2)),
                                    ),
                                    iconSize: 25,
                                    onTap: (Item value) {

                                      if (value.isSelected) {
                                        treatmentGoals.add(value.name);
                                      }
                                      else {
                                        if (treatmentGoals.contains(value.name))
                                          treatmentGoals.remove(value.name);
                                      }
                                    },
                                  ),
                                  SizedBox(width: MarchSize.littleGap * 3),
                                  Text(
                                    item,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      padding: EdgeInsets.all(MarchSize.littleGap * 6),
                    ),
                  ),
                  SizedBox(
                    height: MarchSize.littleGap * 15,
                  ),
                  Container(
                      width: size.width * 0.35,
                      child: ConfirmButton(
                        controller: ButtonController(
                            buttonText: 'Confirm and Start Monitoring',
                            onPressed: () async {
                              Loading(context: context,).show();

                              Map<String, dynamic> data = {
                                'health_condition': healthConditions,
                                'symptoms': symptoms,
                                'treatment_goals': treatmentGoals,
                              };

                              // Convert to JSON string
                              String jsonData = jsonEncode(data);

                            HealthData  healthData =   await  assessmentNotifier.sendData(jsonData);

                              Loading(context: context,).dismiss();

                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ShowDataScreen(healthData)),
                              );
                            }

                            ),
                        size: 24,
                      )),
                  SizedBox(
                    height: MarchSize.littleGap * 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
