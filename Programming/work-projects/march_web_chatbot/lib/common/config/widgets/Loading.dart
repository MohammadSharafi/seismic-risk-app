import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class Loading extends StatelessWidget {
  static bool isLoading = false;
 final BuildContext context;

  const Loading({Key? key, required this.context}) : super(key: key);
   void show() {
    if(isLoading) return;
    isLoading = true;
    showDialog(
      barrierDismissible: true,
      context: context,

      builder: (ctx) => Theme(
        data: Theme.of(ctx).copyWith(dialogBackgroundColor: Colors.transparent),
        child: Loading(context: context,),
      ),
    );
  }
   void dismiss() {
    if(isLoading){
      isLoading = false;
      Navigator.pop(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child:Lottie.asset('assets/loading.json',width: 150),
      ),
    );
  }
}