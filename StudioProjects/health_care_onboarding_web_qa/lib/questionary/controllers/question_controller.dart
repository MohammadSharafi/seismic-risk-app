// State management with Provider
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/Answers.dart';
import '../models/Questions.dart';
import '../models/info.dart';
import '../models/listOfQuestions.dart';
import '../models/questionary/QuestionaryReqModel.dart';
import 'package:http/http.dart' as http;

class SurveyState extends ChangeNotifier {
  int currentPage = 0;
  int progressbarPage = 0;
  final List<dynamic> pages;
  final SurveyAnswer surveyAnswer = SurveyAnswer();
  final Map<String, TextEditingController> _textControllers =
      {}; // Added for controllers

  SurveyState(this.pages);

  // Add this new method
  bool areAllQuestionsAnswered() {
    final currentPageData = pages[currentPage];

    // If it's an InfoPage, consider it "answered" as it has no questions
    if (currentPageData is InfoPage || currentPageData is LoadingPage) {
      return true;
    }

    // If it's a SurveyPageData, check all questions
    if (currentPageData is SurveyPageData) {
      for (int i = 0; i < currentPageData.questionList.length; i++) {
        final answer = surveyAnswer.getAnswer(progressbarPage, i);
        final questionType = currentPageData.questionTypeList[i];

        // Check if answer exists and is valid based on question type
        if (answer == null) return false;

        switch (questionType) {
          case QuestionType.multipleChoice:
            if (answer is! Set || answer.isEmpty) return false;
            break;
          case QuestionType.textField:
            if (answer is! String || answer.isEmpty) return false;
            break;
          case QuestionType.numberField:
            if (answer is! String || answer.isEmpty) return false;
            break;
          case QuestionType.periodCalendar:
          case QuestionType.calendar:
          case QuestionType.datePicker:
            if (answer is! DateTime) return false;
            break;
          case QuestionType.singleChoice:
            if (answer is! String || answer.isEmpty) return false;
            break;
          case QuestionType.slider:
            if (answer == null)
              return false; // Assuming slider returns a number
            break;
          case QuestionType.info:
            return true; // Info doesn't require an answer
          case QuestionType.gridView:
            if (answer is! Set || answer.isEmpty) return false;
            break;
          case QuestionType.dropDown:
            if (answer == null) return false;
            break;
          case QuestionType.singleChoiceWithNone:
            if (answer is! String || answer.isEmpty) return false;
            break;
          case QuestionType.multipleChoiceWithNone:
            if (answer is! Set || answer.isEmpty) return false;
            break;
          case QuestionType.dropDownWithData:
            if (answer is! String || answer.isEmpty) return false;
            break;
          case QuestionType.bigTextField:
            if (answer is! String || answer.isEmpty) return false;
            break;
          case QuestionType.phoneNumberField:
            if ((answer is! String ||
                answer.isEmpty ||
                !isValidPhoneNumber(answer))) return false;
            break;
        }
      }
      return true;
    }

    return false; // Default case, should not occur
  }

  bool isValidPhoneNumber(String phoneNumber) {
    final RegExp phoneRegex = RegExp(r'^\+\d{1,5}(?:[\s-]?\d{3,5}){2,3}$');
    return phoneRegex.hasMatch(phoneNumber);
  }
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    if (userId == null) {
      userId = Uuid().v4();
      await prefs.setString('user_id', userId);
    }
    return userId;
  }
  void nextPage() {
    if (currentPage < pages.length - 1) {
      currentPage++;
      if (pages[currentPage] is SurveyPageData) {
        progressbarPage++;

      }
      notifyListeners();
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      if (pages[currentPage] is SurveyPageData) {
        progressbarPage--;
      }
      currentPage--;

      notifyListeners();
    }
  }
  List<SurveyPageData> gatherSurveyPageData(List<dynamic> surveyData) {
    return surveyData.where((item) => item is SurveyPageData).cast<SurveyPageData>().toList();
  }
  Future<void> saveAnswer(
      int pageIndex, int questionIndex, dynamic answer) async {
    print('Started saving answer');
    surveyAnswer.setAnswer(pageIndex, questionIndex, answer);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(pageIndex==0){
      prefs.setBool('allow_collect_data', true);
    }

  bool allow =  prefs.getBool('allow_collect_data')??true;

  if(allow){
    print('Allowing data collection');
    dynamic answers =  surveyAnswer.getAnswer(pageIndex, questionIndex);
    String name = surveyAnswer.getAnswer(0, 0);
    String value =  '';

    switch (answers.runtimeType) {
      case String:
        value = answer.toString();
        break;
      case DateTime:
        value = (answer as DateTime).toString().split(' ')[0];
        break;
      case Set:
        value = (answer as Set).toList().join(',');
        break;
      default:
        value = answer.toString();
    }

    String userIdentifier = await getUserId();

    sendData(question: gatherSurveyPageData(surveyData)[pageIndex].questionList.first, questionId: gatherSurveyPageData(surveyData)[pageIndex].listOfTags.first, answer: value, fullName: name, userIdentifier:userIdentifier );


  }
  else{
    print('Not allowing data collection');
  }

    if (pageIndex == 1) {
      prefs.setInt(
          'STEP_2',
          calculateAgeFromAnswer((answer is DateTime)
              ? (answer).toString().split(' ')[0]
              : answer.toString()));
    } else if (pageIndex == 2) {
      prefs.setBool(
          'STEP_3', answer.toString().toLowerCase() == 'yes' ? true : false);
    }
    print('Finished saving answer');

    notifyListeners();
  }

  dynamic getAnswer(int pageIndex, int questionIndex) {
    return surveyAnswer.getAnswer(pageIndex, questionIndex);
  }

  TextEditingController getController(int pageIndex, int questionIndex) {
    final key = '$pageIndex-$questionIndex';
    if (!_textControllers.containsKey(key)) {
      _textControllers[key] = TextEditingController(
        text: getAnswer(pageIndex, questionIndex)?.toString() ?? '',
      );
    }
    return _textControllers[key]!;
  }

  int calculateAgeFromAnswer(dynamic answer) {
    DateTime birthDate;

    // Handle input based on type
    if (answer is DateTime) {
      birthDate = answer;
    } else if (answer is String) {
      // Parse string like 'YYYY-MM-DD'
      try {
        birthDate = DateTime.parse(answer.toString().split(' ')[0]);
      } catch (e) {
        throw FormatException('Invalid date format');
      }
    } else {
      throw ArgumentError('Input must be a DateTime or a valid date string');
    }

    // Calculate age
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    // Adjust age if birthday hasn't occurred this year
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> sendData({required String question,required String questionId,required String answer,required String fullName, required String userIdentifier}) async {
    try {
      print('userIdentifier: $userIdentifier'+
          'question: $question' +
          'questionId: $questionId' +
          'answer: $answer' +
          'fullName: $fullName');
      final response = await http.post(
        Uri.parse(
            'https://certainly-helpful-fish.ngrok-free.app/api/v1/webhooks/on-create-endo-master-care-plan-submissions'),
        headers: {
          "ngrok-skip-browser-warning": "69420",
          "on-create-endo-master-care-plan-submission-api-key": "Tz70zitgtytNFYPvkPUsSFhGTRSlYHTCBrjjCQGu4V7ZH7LIFnzREjSXPz0yITtZ",
        },
        body: jsonEncode({
          "userIdentifier": "$userIdentifier",
          "category": "ENDO MASTER CARE PLAN SUBMISSION",
          "question": "$question",
          "answer": "$answer",
          "questionId": "$questionId",
          "fullName": "$fullName"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
      } else {
        throw Exception(
            'Failed to send data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print(e);
    }
  }

  QuestionaryReqModel submitSurvey() {
    final List<UserQuestionary> userQuestionaryList = [];
    final List<SurveyPageData> surveyPages =
        pages.whereType<SurveyPageData>().toList();

    for (int pageIndex = 0; pageIndex <= surveyPages.length - 1; pageIndex++) {
      final pageData = surveyPages[pageIndex];
      for (int questionIndex = 0;
          questionIndex < pageData.questionList.length;
          questionIndex++) {
        final answer = getAnswer(pageIndex, questionIndex);
        if (answer != null) {
          dynamic formattedAnswer;
          final tag = pageData.listOfTags[questionIndex];
          switch (tag) {
            case 'STEP_1':
              formattedAnswer = answer.toString();
              break;
            case 'STEP_2':
              formattedAnswer = (answer is DateTime)
                  ? (answer).toString().split(' ')[0]
                  : answer.toString();
              break;
            case 'STEP_3':
              formattedAnswer =
                  answer.toString().toLowerCase() == 'yes' ? true : false;
              break;
            case 'STEP_4':
              formattedAnswer = answer.toString();
              break;
            case 'STEP_5':
              formattedAnswer = answer.toString();
              break;
            case 'STEP_6':
              formattedAnswer = (answer as Set).toList();
              break;
            case 'STEP_7':
              formattedAnswer = int.parse(answer.toString().trim());
              break;
            case 'STEP_8':
              formattedAnswer = answer.toString();
              break;
            case 'STEP_9':
              formattedAnswer = answer.toString();
              break;
            case 'STEP_10':
              formattedAnswer = (answer as Set).toList();
              break;
            case 'STEP_11':
              formattedAnswer = answer.toString();
              break;
            case 'STEP_12':
              formattedAnswer = answer.toString();
              break;
            case 'STEP_13':
              formattedAnswer = answer.toString();
              break;
            case 'STEP_14':
              formattedAnswer = (answer as Set).toList();
              break;
            case 'STEP_15':
              formattedAnswer = (answer as Set).toList();
              break;
            case 'STEP_16':
              formattedAnswer = answer.toString();
              break;
            case 'STEP_17':
              formattedAnswer = answer.toString();
              break;
            case 'STEP_18':
              formattedAnswer = answer.toString();
              break;
            default:
              formattedAnswer = answer.toString(); // Fallback
          }

          final stepId = stepIdMapping[tag] ?? '';
          userQuestionaryList.add(UserQuestionary(
            questionId: stepId,
            answer: formattedAnswer,
          ));
        }
      }
    }

    final reqModel = QuestionaryReqModel(userQuestionary: userQuestionaryList);
    return reqModel;
  }

// Mapping of pageIndex-questionIndex to stepId
  final Map<String, String> stepIdMapping = {
    'STEP_1': '5a1b2c3d4e5f60718293a4b5',
    'STEP_2': '6b2c3d4e5f607293a4b5182c',
    'STEP_3': '7c3d4e5f607384a4b518293d',
    'STEP_4': '8d4e5f607495b518293c4e6f',
    'STEP_5': '9e5f607596c6293d4e5f7081',
    'STEP_6': 'af607697d73a4e5f708192b3',
    'STEP_7': 'b07187ae84b5f708293c4d25',
    'STEP_8': 'c18298bf95c607193d4e5f36',
    'STEP_9': 'd293a9c0a6d7182a4e5f6047',
    'STEP_10': 'e3a4b0d1b7e8293b5f607158',
    'STEP_11': 'f4b5c1e2c8f93a4c60718269',
    'STEP_12': '05c6d2f3d90a4b5d7182937a',
    'STEP_13': '16d7e304ea1b5c6e8293a48b',
    'STEP_14': '27e8f415fb2c6d7f93a4b59c',
    'STEP_15': '38f90526gc3d7e8094b5c6ad',
    'STEP_16': '490a1637hd4e8f91a5c6d7be',
    'STEP_17': '5a1b2748ie5f90a2b6d7e8cf',
    'STEP_18': '6b2c3859jf6071b3c7e8f9d0',
  };

  @override
  void dispose() {
    _textControllers.forEach((_, controller) => controller.dispose());
    _textControllers.clear();
    super.dispose();
  }
}
