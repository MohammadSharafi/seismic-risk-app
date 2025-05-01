import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../march_style/march_size.dart';




class GradiantTimelineWidget extends StatelessWidget {
  const GradiantTimelineWidget({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class TimelineItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final bool isLast;
  final Color circleColor; // Added color parameter
  final Color? nextCircleColor; // Color of the next circle for gradient

  const TimelineItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isLast,
    required this.circleColor,
    this.nextCircleColor,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor, // Use the provided color
                ),
                child: SvgPicture.asset(
                  icon,
                  color: Colors.white,
                  width: 24,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    child: CustomPaint(
                      painter: DashedLinePainter(
                        startColor: circleColor,
                        endColor: nextCircleColor ?? circleColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: HexColor('#242424'),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: MarchSize.littleGap * 2.5),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    color: HexColor('#242424'),
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: MarchSize.littleGap * 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color startColor;
  final Color endColor;

  DashedLinePainter({required this.startColor, required this.endColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        colors: [startColor, endColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    const double dashHeight = 5;
    const double dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Example usage:
class ExampleTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      HexColor('#9696EC'), // Purple
      HexColor('#FF6B6B'), // Red
      HexColor('#4ECDC4'), // Teal
    ];

    return GradiantTimelineWidget(
      children: [
        TimelineItem(
          icon: 'path/to/icon1.svg',
          title: 'Step 1',
          description: 'Description 1',
          isLast: false,
          circleColor: colors[0],
          nextCircleColor: colors[1],
        ),
        TimelineItem(
          icon: 'path/to/icon2.svg',
          title: 'Step 2',
          description: 'Description 2',
          isLast: false,
          circleColor: colors[1],
          nextCircleColor: colors[2],
        ),
        TimelineItem(
          icon: 'path/to/icon3.svg',
          title: 'Step 3',
          description: 'Description 3',
          isLast: true,
          circleColor: colors[2],
        ),
      ],
    );
  }
}