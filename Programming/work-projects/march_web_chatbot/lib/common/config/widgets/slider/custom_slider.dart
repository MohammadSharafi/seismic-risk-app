import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:provider/provider.dart';

import '../../march_style/march_icons.dart';
import '../../march_style/march_size.dart';

class SliderProvider with ChangeNotifier {
  int _currentValue;

  SliderProvider(this._currentValue);

  int get currentValue => _currentValue;

  void setValue(int newValue) {
    _currentValue = newValue;
    notifyListeners();
  }
}



class CustomSlider extends StatelessWidget {
  final ValueChanged<SliderItem> onTap;
  final String name;

  const CustomSlider({super.key, required this.onTap, required this.name});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<SliderProvider>(
      builder: (context, sliderProvider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Slider bar
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: HexColor('#F3F4F6'),
                inactiveTrackColor: HexColor('#F3F4F6'),
                thumbColor: HexColor('#514E7F'),
                overlayColor: HexColor('#514E7F').withAlpha(32),
                thumbShape: RoundedSquareSliderThumbShape(),
                trackHeight: 10.0,
              ),
              child: Slider(
                value: sliderProvider.currentValue.toDouble(),
                min: 1,
                max: 10,
                onChanged: (value) {
                  sliderProvider.setValue(value.toInt());
                  onTap.call(SliderItem(name: name, value: value.toInt(),));
                },
              ),
            ),
            // Number labels below slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(10, (i) {
                  int displayValue = i+1;
                  return Text(
                    displayValue.toString().padRight(3),
                    style: GoogleFonts.montserrat(
                      color:HexColor('#2F2E41'),
                      fontWeight: displayValue == sliderProvider.currentValue
                    ? FontWeight.bold
                        : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,


                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}




class RoundedSquareSliderThumbShape extends SliderComponentShape {
  final double thumbSize;
  final double cornerRadius;

  RoundedSquareSliderThumbShape({
    this.thumbSize = 21.0,
    this.cornerRadius = 4.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbSize, thumbSize);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;

    // Draw rounded square
    final rect = Rect.fromCenter(
      center: center,
      width: thumbSize,
      height: thumbSize,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));
    context.canvas.drawRRect(rrect, paint);
  }
}



class SliderItem with ChangeNotifier {
  int value;
  String name;

  SliderItem( {required this.value ,required this.name});


}
