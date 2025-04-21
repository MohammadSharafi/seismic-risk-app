import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/config/march_style/hexColor.dart';
import '../../../../common/config/march_style/march_icons.dart';
import '../../../../common/config/march_style/march_size.dart';
import '../../../../common/config/widgets/button.dart';
import '../widgets/start_button.dart';
import 'get_data_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(0, 0),
        child: Container(height: 0),
      ),
      body: isMobile ? MobileView(size: size) : DesktopView(size: size),
    );
  }
}

class MobileView extends StatelessWidget {
  final Size size;

  const MobileView({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor.fromHex('#F1EFF0'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MarchSize.littleGap * 3,
          ),
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
          Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: MarchSize.littleGap * 4),
                    child: Text(
                      'Welcome To March\nHealth’s Interactive\nDigital Twin And Health Agent Demo',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'MontserratExtraBold'),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: MarchSize.littleGap * 4),
                    child: Text(
                      'Today, you’re helping Sarah, a 34-year-old woman managing complex reproductive health issues. Configure her profile to best represent her unique symptoms and treatment goals, and explore how March Health’s technology can support her.',
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: MarchSize.littleGap * 4),
                    child: StartButton(
                      size: 16,
                      controller: ButtonController(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GetDataScreen()),
                          );
                        },
                        buttonText: 'Start Profile Setup',
                      ),
                    ),
                  ),
                ],
              )),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Spacer(),
                Image.asset(
                  MarchIcons.bg_small,
                  fit: BoxFit.fitHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopView extends StatelessWidget {
  final Size size;

  const DesktopView({required this.size});

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
                MarchIcons.sign_up_bg_icon,
                height: size.height,
                fit: BoxFit.fitHeight,
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Spacer(),
                Container(
                  width: size.width * 0.3,
                  child: Text(
                    'Welcome To March\nHealth’s Interactive\nDigital Twin And Health Agent Demo',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black, fontSize: 40, fontWeight: FontWeight.w900, fontFamily: 'MontserratExtraBold'),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  height: MarchSize.littleGap * 8,
                ),
                Container(
                  width: size.width * 0.3,
                  child: Text(
                    'Today, you’re helping Sarah, a 34-year-old woman managing complex reproductive health issues. Configure her profile to best represent her unique symptoms and treatment goals, and explore how March Health’s technology can support her.',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  height: MarchSize.littleGap * 12,
                ),
                Container(
                  width: size.width * 0.3,
                  child: StartButton(
                    size: 24,
                    controller: ButtonController(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GetDataScreen()),
                        );
                      },
                      buttonText: 'Start Profile Setup',
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  '© Copyright 2024, All Rights Reserved For March Inc.',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: MarchSize.littleGap * 4,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
