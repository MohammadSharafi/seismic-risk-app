import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              Image.asset('assets/end.png',width: 200,),

              const SizedBox(height: 20),
              const Text(
                    '📲 Get Started with March Health!\n\n'
                    '🚀 Your account is now created & customized! Start tracking your cycle, symptoms, and receive personalized health recommendations in the March Health.\n'
                    '🎁 Enjoy 3 months of free access to premium features as our welcome gift 💙\n'
                    '🎉 Expert insights, advanced tracking, and personalized care are now unlocked just for you!',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  const url = 'https://marchapp.app.link/7QkeYUYJHRb';

                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor:HexColor('#6750A4') ,
                ),
                child: const Text(
                  'Claim Your Gift',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }





}