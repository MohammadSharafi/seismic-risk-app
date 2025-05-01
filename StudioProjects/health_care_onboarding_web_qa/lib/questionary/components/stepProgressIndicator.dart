import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';


class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    double progress = currentStep / totalSteps;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$currentStep',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: HexColor('#6750A4'),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 2),
              child: Text(
                ' / $totalSteps',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade400,
                ),
              ),
            ),


          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              HexColor('#6750A4'),
            ),
          ),
        ),
      ],
    );
  }
}