import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../../common/config/widgets/button.dart';

class ResultConfirmButton extends Button {
  ResultConfirmButton({
    Key? key,
    required ButtonController controller,
    required double size,
  }) : super(
    key: key,
    controller: controller,
    color: HexColor('#4A4458'),
    textStyle: GoogleFonts.montserrat(

      color: Colors.white,
      fontSize:size?? 24,
      fontWeight: FontWeight.w400
    ),
    borderRadius: 360.0, // Custom border radius
  );
}
