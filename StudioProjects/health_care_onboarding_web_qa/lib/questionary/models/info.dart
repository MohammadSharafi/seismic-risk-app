import 'package:flutter/cupertino.dart';

class InfoPage {
  final String  buttonTitle;
  final Function ? buttonCallBack;
  final Function? secondButtonCallBack;
  final String ? secondButtonTitle;
  final Widget child;
  final bool ? canBack;


  InfoPage( {this.secondButtonTitle, this.buttonCallBack, this.secondButtonCallBack, required this.buttonTitle, required this.child,this.canBack,});
}

class LoadingPage {
  final int  timer;
  final Widget child;

  LoadingPage({ required this.timer, required this.child});
}



