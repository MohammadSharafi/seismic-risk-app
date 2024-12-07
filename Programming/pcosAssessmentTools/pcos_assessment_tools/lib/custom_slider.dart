import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
 final Function(double) onSelect;

  const CustomSlider({super.key, required this.onSelect});
  @override
  _CustomSliderState createState() => _CustomSliderState(onSelect);
}

class _CustomSliderState extends State<CustomSlider> {
  double _currentValue = 1;
  final Function(double) onSelect;

  _CustomSliderState(this.onSelect);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Never',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            Text(
              'Value: ${_currentValue.toInt()}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            Text(
              'Always',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
        Slider(
          value: _currentValue,
          min: 1,
          max: 5,
          divisions: 4, // Number of steps (1 to 5)
          activeColor: Colors.black,
          inactiveColor: Colors.grey[300],
          onChanged: (double value) {

            setState(() {
              _currentValue = value;
            });
          },
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 20.0),
          child: ElevatedButton(
            onPressed: () {
              onSelect.call(_currentValue);
            },
            child: Text('Next'),
          ),
        ),

      ],
    );
  }
}
