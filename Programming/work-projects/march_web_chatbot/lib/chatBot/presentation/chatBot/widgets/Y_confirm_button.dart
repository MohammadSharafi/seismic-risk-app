import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../../common/config/widgets/button.dart';

class YConfirmButton extends Button {
  YConfirmButton({
    Key? key,
    required ButtonController controller,
    required double size,
  }) : super(
    key: key,
    controller: controller,
    color: HexColor('#FAFAFA'),
    textStyle: GoogleFonts.montserrat(

      color: HexColor('#2F2E41'),
      fontSize:size?? 24,
      fontWeight: FontWeight.w400
    ),
    borderRadius: 360.0, // Custom border radius
  );
}
