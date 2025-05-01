import 'package:flutter/material.dart';

import '../../march_style/march_theme.dart';


class QuestionaryStepIndicator extends StatelessWidget {
  QuestionaryStepIndicator({required this.selectedIndex, required this.onTap});
  final int ? selectedIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(10, (index) {
              return GestureDetector(
                onTap: () {

                  onTap.call(index + 1);
                },
                child: StepCircle(
                  stepNumber: index + 1,
                  isSelected:selectedIndex== index+1,
                ),
              );
            }),
          ),
        ),
        Container(
          height: 30,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Barely Noticeable',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Spacer(),
              Text(
                'Extremely Painful',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StepCircle extends StatelessWidget {

  StepCircle({required this.stepNumber, required this.isSelected});
  final int stepNumber;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 25.0,
          height: 25.0,
          decoration: BoxDecoration(
            color:
                isSelected ? marchColorData[MarchColor.purpleExtraDark] : null,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(
                    color: marchColorData[MarchColor.purpleExtraDark]!,
                    width: 2.0,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : marchColorData[MarchColor.purpleExtraDark],
                fontSize: 11.0,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w300,
              ),
            ),
          ),
        ),
        if (stepNumber != 10) const SizedBox(width: 8.0),
      ],
    );
  }
}
