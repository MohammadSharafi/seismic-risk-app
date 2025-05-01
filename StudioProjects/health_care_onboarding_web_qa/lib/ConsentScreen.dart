import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/buttons.dart';
import 'package:health_care_onboarding_web_qa/routes/router.dart';




@RoutePage()
class ConsentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header text
              Text(
                "You're just one step away!",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "Before we continue, please review and sign the consent form for the 30-Day Endometriosis Care Plan. This program offers support, guidance, and insights, but it is not a substitute for medical advice. Your understanding helps us move forward together with care and clarity.",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 16),
              // Scrollable consent text
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed dictum massa sed erat ullamcorper tristique. Suspendisse facilisis lacus ac velit hendrerit, vitae condimentum magna vulputate. Phasellus tellus lorem, tempor ut nulla sed, malesuada mattis tortor. Ut non mauris suscipit, eleifend felis quis, pulvinar nisl. Pellentesque at vestibulum augue. In ultrices, lorem vitae bibendum viverra, ligula turpis viverra justo, sed elementum odio est quis magna. Vivamus sagittis nunc vitae sollicitudin ullamcorper. Cras tincidunt pulvinar tincidunt.\n\n"
                      "Curabitur blandit nulla sit amet facilisis tempor. Mauris ac hendrerit tortor, at venenatis odio. Morbi leo arcu, faucibus a enim id, tincidunt ultrices mi. Donec sem massa, placerat sed dapibus sit amet, porttitor vel nisi. Vivamus in aliquam erat, quis luctus ligula. Vivamus blandit sodales odio sit amet gravida. Phasellus et augue viverra, bibendum lacus ac, posuere mi. Cras leo nunc, egestas vitae sagittis ut, sodales et ligula.\n\n"
                      "Curabitur blandit nulla sit amet facilisis tempor. Mauris ac hendrerit tortor, at venenatis odio. Morbi leo arcu, faucibus a enim id, tincidunt ultrices mi. Donec sem massa, placerat sed dapibus sit amet, porttitor vel nisi. Vivamus in aliquam erat, quis luctus ligula. Vivamus blandit sodales odio sit amet gravida. Phasellus et augue viverra, bibendum lacus ac, posuere mi. Cras leo nunc, egestas vitae sagittis ut, sodales et ligula.\n\n"
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed dictum massa sed erat ullamcorper tristique. Suspendisse facilisis lacus ac velit hendrerit, vitae condimentum magna vulputate. Phasellus tellus lorem, tempor ut nulla sed, malesuada mattis tortor. Ut non mauris suscipit, eleifend felis quis, pulvinar nisl. Pellentesque at vestibulum augue. In ultrices, lorem vitae bibendum viverra, ligula turpis viverra justo, sed elementum odio est quis magna. Vivamus sagittis nunc vitae sollicitudin ullamcorper. Cras tincidunt pulvinar tincidunt.",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              MarchButton(btnText: 'I Agree', btnCallBack: (){
                AutoRouter.of(context).replace(ProgramRoute());

              }, buttonSize: ButtonSize.LARG, alignment: Alignment.center,hasPadding: false,)
            ],
          ),
        ),
      ),
    );
  }
}