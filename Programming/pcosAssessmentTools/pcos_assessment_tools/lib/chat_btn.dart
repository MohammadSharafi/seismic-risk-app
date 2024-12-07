import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcos_assessment_tools/march_style/hexColor.dart';

Widget marchButton(
{
  required String text,
  required VoidCallback onPressed,
  double borderRadius = 4.0,
}
) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: HexColor.fromHex('#F6CEEC'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    child: Text(
      text,
      style: GoogleFonts.arimo(
        fontSize: 13,
        color: Colors.black,
        fontWeight: FontWeight.w400,
      ), // Custom text style),
    ), // Custom text style),
  );
}
