import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../common/config/march_style/march_icons.dart';



class MultiRangeSliderWithPointers extends StatelessWidget {
  final List<Tuple> ranges;
  final List<double> pointerPositions;
  final double width;

  MultiRangeSliderWithPointers({required this.ranges, required this.pointerPositions, required this.width});

  @override
  Widget build(BuildContext context) {

    bool isMobile = MediaQuery.of(context).size.width < 800;


    return Container(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base range slider with ranges highlighted
          CustomPaint(
            painter: MultiRangeSliderPainter(ranges: ranges),
            child: Container(height: 30), // Ensures CustomPaint takes up the height
          ),
          // Positioned pointers
          ...pointerPositions.map((position) {
            return Positioned(
              left: position * width - (isMobile?8:15), // Adjust based on pointer width
              child: PointerIndicator(value: (isMobile?8:15)),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class Tuple {
  final double start;
  final double end;

  Tuple(this.start, this.end);
}

class MultiRangeSliderPainter extends CustomPainter {
  final List<Tuple> ranges;
  final double trackHeight = 10.0;

  MultiRangeSliderPainter({required this.ranges});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw base track
    final Paint trackPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    final Rect baseTrackRect = Rect.fromLTWH(0, size.height / 2 - trackHeight / 2, size.width, trackHeight);
    canvas.drawRRect(RRect.fromRectAndRadius(baseTrackRect, Radius.circular(4.0)), trackPaint);

    // Draw highlighted ranges
    final Paint highlightPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    for (final range in ranges) {
      final double startX = range.start * size.width;
      final double endX = range.end * size.width;
      final Rect rangeRect = Rect.fromLTWH(startX, size.height / 2 - trackHeight / 2, endX - startX, trackHeight);
      canvas.drawRRect(RRect.fromRectAndRadius(rangeRect, Radius.circular(4.0)), highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PointerIndicator extends StatelessWidget {
  final double value;

  const PointerIndicator({super.key, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: value*2,
      margin: EdgeInsets.only(top: 20),
      height: value*2,
      child: SvgPicture.asset(MarchIcons.polygon_icon),
    );
  }
}

class RangeSliderWidget extends StatelessWidget {
  final List<Tuple> tuples;
  final double pointerPositions;
  final double width;


  const RangeSliderWidget({super.key, required this.tuples, required this.pointerPositions, required this.width});
  @override
  Widget build(BuildContext context) {
    return MultiRangeSliderWithPointers(
      ranges: tuples,
      pointerPositions: [pointerPositions], width: width, // Position pointers at 10%, 50%, and 80%
    );
  }
}

//...




class GradientSliderWithPointer extends StatelessWidget {
  final double pointerPosition;
  final List<Color> colors;
  final double width;


  GradientSliderWithPointer({required this.pointerPosition, required this.colors, required this.width});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient track
          CustomPaint(
            painter: GradientSliderPainter(colors),
            child: Container(height: 20), // Ensures CustomPaint takes up the height
          ),
          // Positioned pointer
          Positioned(
            left: pointerPosition * width - (isMobile?8:15), // Adjust based on pointer width
            child: PointerIndicator(value: (isMobile?8:15)),
          ),
        ],
      ),
    );
  }
}

class GradientSliderPainter extends CustomPainter {
  final double trackHeight = 10.0;
  final List<Color> colors;

  GradientSliderPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw gradient track
    final Paint gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, trackHeight))
      ..style = PaintingStyle.fill;

    final Rect gradientTrackRect = Rect.fromLTWH(0, size.height / 2 - trackHeight / 2, size.width, trackHeight);
    canvas.drawRRect(RRect.fromRectAndRadius(gradientTrackRect, Radius.circular(4.0)), gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



class GradientSliderWidget extends StatelessWidget {
  final double percent;
  final List<Color> colors;
  final double width;


  const GradientSliderWidget({super.key, required this.percent, required this.colors, required this.width});
  @override
  Widget build(BuildContext context) {
    return GradientSliderWithPointer(
      pointerPosition: percent, colors: colors, width: width,
    );
  }
}
