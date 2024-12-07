import 'package:flutter/material.dart';

class RatingScale extends StatefulWidget {
  final String questionId;
  final List<int> options;
  final Function(int) onSelected;

  RatingScale({required this.questionId, required this.options, required this.onSelected});

  @override
  _RatingScaleState createState() => _RatingScaleState();
}

class _RatingScaleState extends State<RatingScale> {
  int? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Never',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
        // Options
        Row(
          children: widget.options.map((option) {
            bool isSelected = selectedOption == option;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedOption = option;
                });
                widget.onSelected(option);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: CircleAvatar(
                  radius: 20, // Size of the circle
                  backgroundColor: isSelected ? Colors.black : Colors.grey[300],
                  child: Text(
                    option.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Right label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Always',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
