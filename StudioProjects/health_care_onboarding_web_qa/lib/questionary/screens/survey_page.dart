import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/routes/router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../injection.dart';
import 'package:provider/provider.dart';
import '../../march_style/march_icons.dart';
import '../../march_style/march_size.dart';
import '../../march_style/march_theme.dart';
import '../components/buttons.dart';
import '../components/disableWidget.dart';
import '../components/questionWidget.dart';
import '../components/stepProgressIndicator.dart';
import '../controllers/question_controller.dart';
import '../models/Questions.dart';
import '../models/info.dart';
import '../models/listOfQuestions.dart';
import '../models/questionary/QuestionaryReqModel.dart';
import '../models/questionary/questionary_repo.dart';

@RoutePage()
class SurveyPage extends StatelessWidget {
  SurveyPage({Key? key}) : super(key: key);

//
  QuestionaryRepository questionaryRepository =
      getIt.get<QuestionaryRepository>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SurveyState(surveyData),
        ),
      ],
      child: Consumer<SurveyState>(
        builder: (context, surveyState, child) {
          if (surveyState.pages.isEmpty ||
              surveyState.currentPage >= surveyState.pages.length) {
            return const Scaffold(
              body: Center(child: Text('No survey data available')),
            );
          }

          final pageData = surveyState.pages[surveyState.currentPage];

          return Scaffold(
            body: _buildPageContent(context, surveyState, pageData),
          );
        },
      ),
    );
  }

  Widget _buildPageContent(
      BuildContext context, SurveyState surveyState, dynamic pageData) {
    if (pageData is SurveyPageData) {
      return _buildSurveyPage(context, surveyState, pageData);
    }
    else if (pageData is InfoPage) {
      final currentPageData = surveyState.pages[surveyState.currentPage];
      return Stack(
        children: [
          (currentPageData.canBack == true)
              ? Positioned(
                  top: MarchSize.paddingExtraLongTop + MarchSize.littleGap * 2,
                  left: MarchSize.littleGap * 2,
                  child: GestureDetector(
                      onTap: () {
                        surveyState.previousPage();
                      },
                      child: Padding(
                          padding: EdgeInsets.all(MarchSize.littleGap * 2),
                          child: SvgPicture.asset(
                            MarchIcons.left_arrow,
                            width: 15,
                            color: marchColorData[MarchColor.blackText],
                          ))),
                )
              : Container(),
          _buildCustomPage(context, surveyState),
        ],
      );
    } else {
      return _buildLoadingPage(context, surveyState);
    }
  }

  Widget _buildSurveyPage(
      BuildContext context, SurveyState surveyState, SurveyPageData pageData) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(bottom: MarchSize.littleGap * 1.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: MarchSize.littleGap * 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (surveyState.currentPage != 0)
                        ? GestureDetector(
                            onTap: () {
                              if (surveyState.currentPage > 0) {
                                surveyState.previousPage();
                              } else {
                                // AutoRouter.of(context).replace( QuestionaryWelcomeRoute());
                              }
                            },
                            child: Padding(
                                padding:
                                    EdgeInsets.all(MarchSize.littleGap * 2),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: marchColorData[MarchColor.blackText],
                                  size: 16,
                                )))
                        : Container(
                            width: 8,
                          ),
                    Expanded(child: _buildProgressIndicator(surveyState)),
                  ],
                ),
                _buildQuestionList(context, surveyState, pageData),
                SizedBox(height: MarchSize.littleGap * 16),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: MarchSize.littleGap * 3,
          left: 0,
          right: 0,
          child: Disable(
            disabled: !surveyState.areAllQuestionsAnswered() ,
            child: (surveyState.currentPage < surveyState.pages.length - 1)
                ? MarchButton(
                    btnText: 'Next',
                    btnCallBack: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();


                      int? age = prefs.getInt('STEP_2');

                      if (age != null && age < 18) {
                        // Add your logic here
                        AutoRouter.of(context).replace(const UnderEighteenRoute());
                      } else {
                        if (surveyState.currentPage <
                            surveyState.pages.length - 1) {
                          surveyState.nextPage();
                        }
                      }
                    },
                    buttonSize: ButtonSize.LARG,
                    alignment: Alignment.center,
                  )
                : MarchButton(
                    btnText: 'Next',
                    btnCallBack: () async {
                      QuestionaryReqModel questionaryReqModel = surveyState.submitSurvey();
                      await questionaryRepository.add(questionaryReqModel);
                      AutoRouter.of(context).replace(const ConsentRoute());
                    },
                    buttonSize: ButtonSize.LARG,
                    alignment: Alignment.center,
                  ),
          ),
        ),
      ],
    );
  }
  bool isEmailValid(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }
  Widget _buildProgressIndicator(SurveyState surveyState) {
    return (surveyState.progressbarPage + 1) <= 18
        ? StepProgressIndicator(
            currentStep: surveyState.progressbarPage + 1,
            totalSteps: 18,
          )
        : SizedBox(height: MarchSize.littleGap * 6);
  }

  Widget _buildQuestionList(
      BuildContext context, SurveyState surveyState, SurveyPageData pageData) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        itemCount: pageData.questionList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => QuestionWidget(
          pageIndex: surveyState.progressbarPage,
          questionIndex: index,
          title: pageData.questionList[index] ?? '',
          type: pageData.questionTypeList[index],
          description: pageData.descriptionList[index] ?? '',
          options: pageData.listOfOptions[index],
          hint: pageData.hintList[index] ?? '',
          gridItems: pageData.GridItemLists[index] ?? {},
          image: pageData.image[index],
        ),
      ),
    );
  }

  Widget _buildCustomPage(BuildContext context, SurveyState surveyState) {
    final currentPageData = surveyState.pages[surveyState.currentPage];
    return Stack(
      children: [
        Center(
          child: currentPageData.child ?? const SizedBox.shrink(),
        ),
        Positioned(
          bottom: MarchSize.littleGap * 5,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MarchButton(
                btnText: currentPageData.buttonTitle ?? 'Next',
                btnCallBack: () async {
                  if (currentPageData.buttonCallBack != null) {
                    currentPageData.buttonCallBack?.call();
                  }
                  if (surveyState.currentPage < surveyState.pages.length - 1) {
                    surveyState.nextPage();
                  }
                },
                buttonSize: ButtonSize.LARG,
                alignment: Alignment.center,
              ),
              (currentPageData.secondButtonTitle != null)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: InkWell(
                          onTap: () {
                            currentPageData.secondButtonCallBack?.call();
                            surveyState.nextPage();
                          },
                          child: Text(currentPageData.secondButtonTitle,
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w300, fontSize: 13))),
                    )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingPage(BuildContext context, SurveyState surveyState) {
    final currentPageData = surveyState.pages[surveyState.currentPage];

    // Trigger navigation to the next page after the timer duration
    if (currentPageData.timer != null) {
      Future.delayed(Duration(seconds: currentPageData.timer), () async {
        if (surveyState.currentPage < surveyState.pages.length - 1) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          bool? answer = prefs.getBool('STEP_3');

          if (answer == true) {
            surveyState.nextPage();
          } else {
            AutoRouter.of(context).replace(NoEndoRoute());
          }
        }
      });
    }

    return currentPageData.child;
  }

  bool isValidEmail(SurveyState surveyState) {
    bool  isEmail = ((surveyData.where((item) => item is SurveyPageData).cast<SurveyPageData>().toList()[surveyState.myCurrentPageIndex].hintList)??['']).first!.toLowerCase().contains('email');
    if(!isEmail) {
      return true;
    }
    else if(isEmail && isEmailValid(surveyState.getAnswer(surveyState.myCurrentPageIndex,surveyState.myCurrentQuestionIndex))){
      return true;
    }
    else{
      return false;
    }
  }


}
