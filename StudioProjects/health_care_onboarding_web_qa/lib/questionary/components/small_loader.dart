import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import '../../march_style/march_size.dart';

Widget smallLoading() {
  return Container(
    child: Lottie.asset(
      'assets/lottie_files/Loop.json',
      width: MarchSize.smallImageHeight,
    ),
    width: MarchSize.smallWidth,
    height: MarchSize.smallWidth,
  );
}
