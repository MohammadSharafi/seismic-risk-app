import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pcos_assessment_tools/march_style/march_size.dart';
import 'package:pcos_assessment_tools/question_list.dart';
import 'package:pcos_assessment_tools/req_model_class.dart';

import 'API/injection.dart';
import 'API/send_answer_status.dart';
import 'API/userservice.dart';
import 'challenge_res_model.dart';
import 'message_state.dart';

class HairAnswer {
  String area;
  int severity;

  HairAnswer(this.area, this.severity);
}

class ChatProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;

  String _email = '';
  String _name = '';
  String _menstrualCycleTyp = '';
  String _pimplesStatus = '';
  List<HairAnswer> _answer = [];
  double _weight = 0.0;
  double _height = 0.0;
  double _bmi = 0.0;
  bool? _userAnswer;
  int _currentQuestionIndex = 0;
  int _currentHairQuestionIndex = -1;
   Map<String, Message> _userResponses = {};
  String get name => _name;
  int _currentMessageIndexInUi = 0;
  int _targetQuestionIndex = 0;
  bool _editing = false;


  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  String get email => _email;

  set email(String value) {
    _email = value;
    notifyListeners();
  }


  int get currentMessageIndexInUi => _currentMessageIndexInUi;

  set currentMessageIndexInUi(int value) {
    _currentMessageIndexInUi = value;
    notifyListeners();
  }



  ChatProvider() {
    // Initialize the first question
    if (questionList.isNotEmpty) {
      addMessage(questionList[_currentQuestionIndex]);
    }
  }

  // Getters
  List<Message> get messages => List.unmodifiable(_messages);

  Map<String, Message> get userResponses => Map.unmodifiable(_userResponses);

  // Add a new message
  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  // Navigate to the next question
  Future<void> nextQuestion() async {
    if (!_editing) {
      addMessage(
        Message(
          id: 'loading',
          isSystem: false,
          questionType: QuestionType.loading,
        ),
      );
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));
      _messages.removeLast();
    }
    _currentMessageIndexInUi++;

    int userResponseIndex = _messages.indexWhere((msg) => msg.id == 'user_EXPERIENCING_HIRSUTISM_TYPES');

    if (userResponseIndex != -1 && _currentHairQuestionIndex < (_messages[userResponseIndex].options ?? []).where((option) => option.isSelected == true).length - 1 && (_messages[userResponseIndex].options?.where((option) => (option.isSelected && !option.id!.contains('NONE'))).toList() ?? []).isNotEmpty) {
      _currentHairQuestionIndex++;
      addMessage(getHairGrowthQuestionById((_messages[userResponseIndex].options?.where((option) => option.isSelected).toList() ?? []).elementAt(_currentHairQuestionIndex).id ?? ''));
    } else {
      if (_currentQuestionIndex < questionList.length - 1) {
        _currentQuestionIndex++;
        addMessage(questionList[_currentQuestionIndex]);
      }
    }






  }

  void update() {
    notifyListeners();
  }

  double calculateBMI() {
    // Convert height from cm to meters
    double heightMeters = _height / 100;

    // Calculate BMI
    _bmi = double.parse((_weight / (heightMeters * heightMeters)).toStringAsFixed(2));

    return _bmi;
  }



  // Update user response
  void updateUserResponse(String questionId, Message? response) {
    _userResponses[questionId] = response ?? Message(id: '');
    // Debug logs
    print("Before update: ${_messages.map((msg) => msg.id).toList()}");
    switch (response?.id) {
      case 'GET_NAME':
        _name = response?.userResponse ?? '';
        callApi(questionId: 'GET_NAME', question: 'What can I call you?', answer: _name);

        break;

      case 'PAST_6_MONTH_AVG_CYCLE':
        _menstrualCycleTyp = response?.options?.first.id ?? '';
        callApi(questionId: 'PAST_6_MONTH_AVG_CYCLE', question: 'Considering the past 6 months, what has been the average length of your menstrual cycle?', answer: _menstrualCycleTyp);

        break;

      case 'HAIR_GROWTH_CHIN_EXPERIENCING_HIRSUTISM_TYPES':
        _answer.add(HairAnswer('Chin', int.parse(response?.options?.first.id ?? '0')));
        callApi(questionId: 'HAIR_GROWTH_CHIN_EXPERIENCING_HIRSUTISM_TYPES', question: 'Rate the hair growth on your chin', answer:response?.options?.first.id ?? 'EMPTY');


        break;

      case 'HAIR_GROWTH_LOWER_ABDOMEN_EXPERIENCING_HIRSUTISM_TYPES':
        _answer.add(HairAnswer('Lower Abdomen', int.parse(response?.options?.first.id ?? '0')));
        callApi(questionId: 'HAIR_GROWTH_LOWER_ABDOMEN_EXPERIENCING_HIRSUTISM_TYPES', question: 'Rate the hair growth on your lower abdomen', answer: response?.options?.first.id ?? 'EMPTY');

        break;

      case 'HAIR_GROWTH_THIGHS_EXPERIENCING_HIRSUTISM_TYPES':
        _answer.add(HairAnswer('Thighs', int.parse(response?.options?.first.id ?? '0')));
        callApi(questionId: 'HAIR_GROWTH_THIGHS_EXPERIENCING_HIRSUTISM_TYPES', question: 'Rate the hair growth on your thighs', answer: response?.options?.first.id ?? 'EMPTY');

        break;

      case 'HAIR_GROWTH_UPPER_LIP_EXPERIENCING_HIRSUTISM_TYPES':
        _answer.add(HairAnswer('Upper Lip', int.parse(response?.options?.first.id ?? '0')));
        callApi(questionId: 'HAIR_GROWTH_UPPER_LIP_EXPERIENCING_HIRSUTISM_TYPES', question: 'Rate the hair growth on your upper lip', answer: response?.options?.first.id ?? 'EMPTY');

        break;
      case 'HOW_MANY_PIMPLES':
        _pimplesStatus = response?.options?.first.id ?? '';
        callApi(questionId: 'HOW_MANY_PIMPLES', question: 'How many pimples do you have on any areas, such as your forehead, cheeks, chin, or nose?', answer: response?.options?.first.id ?? '');

        break;

      case 'TO_CALCULATE_BMI_TELL_WEIGHT':
        _weight = double.tryParse(response?.userResponse ?? '0.0') ?? int.tryParse(response?.userResponse ?? '0')?.toDouble() ?? 0.0;
        callApi(questionId: 'TO_CALCULATE_BMI_TELL_WEIGHT', question: 'To calculate your BMI, tell me your weight', answer: response?.userResponse ?? 'EMPTY');

        break;

      case 'TO_CALCULATE_BMI_TELL_HEIGHT':
        _height = double.tryParse(response?.userResponse ?? '0.0') ?? int.tryParse(response?.userResponse ?? '0')?.toDouble() ?? 0.0;
        callApi(questionId: 'TO_CALCULATE_BMI_TELL_HEIGHT', question: 'and your height', answer: response?.userResponse ?? 'EMPTY');

        break;

      case 'HAVE_CLOSE_RELATIVES_HAVE_PCOS':
        _userAnswer = ((response?.userResponse ?? '').toUpperCase() == 'YES')
            ? true
            : ((response?.userResponse ?? '').toUpperCase()) == 'NO'
                ? false
                : null;
        callApi(questionId: 'HAVE_CLOSE_RELATIVES_HAVE_PCOS', question: 'Have any of your close relatives, like your mother, sister, or children, been diagnosed with PCOS?', answer: (response?.userResponse ?? 'EMPTY').toUpperCase());

        break;

      case 'EMAIL_ADDRESS':
        _email = response?.userResponse ?? '';
        callApi(questionId: 'EMAIL_ADDRESS', question: 'Before viewing your personalized results, share your preferred email address to access your full results.', answer: _email);

        break;

      default:
        break;
    }

    // Locate the index of the question message
    int questionIndex = _messages.indexWhere((msg) => msg.id == questionId);
    _targetQuestionIndex = questionIndex;
    if (questionIndex != -1) {
      _messages[questionIndex] = _messages[questionIndex].copyWith(
        isAnswered: true,
        userResponse: response?.userResponse,
        options: response?.options,
      );

      // Remove duplicates
      _messages.removeWhere((msg) => msg.id == 'user_$questionId');

      // Insert response after question
      if (response != null) {
        _messages.insert(
          questionIndex + 1,
          Message(
            id: 'user_$questionId',
            isSystem: false,
            options: response.options,
            questionType: response.questionType,
            widgetContentBuilder: (_) => widgetBuilder(response.questionType ?? QuestionType.none, response),
          ),
        );
      }
    }

    print("After update: ${_messages.map((msg) => msg.id).toList()}");

    notifyListeners();
    if (!_editing)
      nextQuestion();
    else {
      _editing = false;
    }
  }

  void addTarget() {
    _targetQuestionIndex = _targetQuestionIndex + 1;
  }

  int get targetQuestionIndex => _targetQuestionIndex;

  set targetQuestionIndex(int value) {
    _targetQuestionIndex = value;
    notifyListeners();
  }



// Method in your ChatProvider class to handle editing a response
  void editResponse(String messageId) {
    if (messageId != 'EXPERIENCING_HIRSUTISM_TYPES') {
      _editing = true;
    }
    // Find the index of the message in the list based on the message ID
    final messageIndex = messages.indexWhere((msg) => msg.id == messageId);

    // If the message is found, proceed to update it
    if (messageIndex != -1) {
      // Get the message object from the list
      Message message = messages[messageIndex];

      // Find the corresponding question from questionList using the same ID
      final questionIndex = questionList.indexWhere((q) => q.id == message.id);

      // If the corresponding question is found, proceed to update it
      if (questionIndex != -1) {
        // Get the question object from the list
        Message questionMessage = questionList[questionIndex];

        // Create the updated question message by marking it as unanswered again
        final updatedQuestionMessage = questionMessage.copyWith(
          isAnswered: false, // Mark the question as unanswered
        );

        if (questionMessage.id == 'EXPERIENCING_HIRSUTISM_TYPES') {
          _answer = [];
          _currentMessageIndexInUi = 7;
          _currentHairQuestionIndex = -1;
          _currentQuestionIndex = 7;
          int indexOfMessage = _messages.indexOf(message);
          List<Message> shouldBeRemoved = _messages.sublist(indexOfMessage + 1);
          shouldBeRemoved.forEach((data) {
            _userResponses.remove('${data.id.replaceFirst('user_', '')}');
          });
          _messages = _messages.sublist(0, indexOfMessage + 1);
        }

        // Update the question in the list
        questionList[questionIndex] = updatedQuestionMessage;

        // Now, we need to create a new list for messages, since they need to reflect the updated question state
        final updatedMessages = List<Message>.from(messages); // Create a new list from the old one

        // Replace the message in the messages list as well
        updatedMessages[messageIndex] = updatedQuestionMessage;
        _targetQuestionIndex = messageIndex;
        // Replace the old messages list with the new one
        _messages = updatedMessages;

        // Notify listeners so the UI updates accordingly
        notifyListeners();
      } else {
        // Optionally handle the case where the question isn't found
        print("Question with ID $messageId not found in questionList.");
      }
    } else {
      // Optionally handle the case where the message isn't found
      print("Message with ID $messageId not found.");
    }
  }

  Widget widgetBuilder(QuestionType type, Message response) {
    switch (type) {
      case QuestionType.multiSelection:
        return Wrap(
          children: () {
            final selectedOptions = (response.options ?? []).where((item) => item.isSelected == true).toList();

            // Sort the selected options by their text
            selectedOptions.sort((a, b) => a.text.compareTo(b.text));

            // Map the sorted items to widgets
            return selectedOptions.map((item) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: MarchSize.littleGap * 3),
                child: Column(
                  children: [
                    (item.image ?? '').isNotEmpty
                        ? Image.asset(
                            item.image ?? '',
                            height: 100,
                          )
                        : Container(),
                    Text(item.text),
                  ],
                ),
              );
            }).toList();
          }(),
        );
      case QuestionType.option:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: () {
            final selectedOptions = (response.options ?? []).toList();

            // Sort the selected options by their text
            selectedOptions.sort((a, b) => a.text.compareTo(b.text));

            // Map the sorted items to widgets
            return selectedOptions.map((item) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    (item.image ?? '').isNotEmpty
                        ? Image.asset(
                            item.image ?? '',
                            height: 100,
                          )
                        : Container(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          item.text,
                          style: GoogleFonts.arimo(fontWeight: FontWeight.w200, fontSize: 18, letterSpacing: 0.2, fontStyle: FontStyle.normal),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList();
          }(),
        );

      case QuestionType.slider:
        return Text(
          response.userResponse ?? '',
          style: GoogleFonts.arimo(fontWeight: FontWeight.w200, fontSize: 18, letterSpacing: 0.2, fontStyle: FontStyle.normal),
        );

      case QuestionType.numberSelector:
        return Text(
          response.userResponse ?? '',
          style: GoogleFonts.arimo(fontWeight: FontWeight.w200, fontSize: 18, letterSpacing: 0.2, fontStyle: FontStyle.normal),
        );

      case QuestionType.text:
        return Text(
          response.userResponse ?? '',
          style: GoogleFonts.arimo(fontWeight: FontWeight.w200, fontSize: 18, letterSpacing: 0.2, fontStyle: FontStyle.normal),
        );
      default:
        return Container();
    }
  }

  ChallengeModel getReqModel() {
    return _challengeModel;
  }

  void resetChallengeModel() {
    // Clear all messages and reset indices
    _messages.clear();
    _currentQuestionIndex = 0;
    _currentHairQuestionIndex = -1;
    _currentMessageIndexInUi = 0;
    _targetQuestionIndex = 0;
    _editing = false;

    // Reset user-provided data
    _name = '';
    _email = '';
    _menstrualCycleTyp = '';
    _pimplesStatus = '';
    _weight = 0.0;
    _height = 0.0;
    _bmi = 0.0;
    _userAnswer = null;

    // Clear responses and answers
    _userResponses.clear();
    _answer.clear();

    // Reinitialize the first question
    if (questionList.isNotEmpty) {
      addMessage(questionList[_currentQuestionIndex]);
    }

    notifyListeners(); // Notify listeners to update the UI
  }

  late ChallengeModel _challengeModel;

  Future<ChallengeResModel?> sendChallengeRequest() async {



    const String url = 'https://api.march.health/monomarch/api/v1/webhooks/on-sync-user-and-challenge';
    ChallengeModel challengeModel = ChallengeModel(email: _email, challengeId: '66937d3d4884c6fe47c633e5', fullName: name);
    challengeModel.addQuestion(ChallengeQuestion(id: '669380aa4884c6fe47c63b31', answer: {'menstrualCycleType': menstrualCycleTyp}));
    challengeModel.addQuestion(ChallengeQuestion(id: '669388884884c6fe47c64b9f', answer: _answer.map((data) {return {"area": data.area, "severity": data.severity};}).toList()));
    challengeModel.addQuestion(ChallengeQuestion(id: '669388e04884c6fe47c64c53', answer: {'pimplesStatus': _pimplesStatus}));
    challengeModel.addQuestion(ChallengeQuestion(id: '6693893c4884c6fe47c64d25', answer: {'weight': _weight, 'height': _height, 'bmi': _bmi}));
    challengeModel.addQuestion(ChallengeQuestion(id: '669389724884c6fe47c64d89', answer: (_userAnswer ?? false) ? "YES" : "NO"));

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'on-sync-user-and-challenge-api-key': 'poqd6nx7a5I8nUL7Ui28sRJn04FPxMjYAzN6a6eg64',
        },
        body: json.encode(challengeModel.toJson()),
      );

      if (response.statusCode == 200) {
        // Parse response JSON
        _challengeModel = challengeModel;

        return ChallengeResModel.fromJson(json.decode(response.body));
      } else {
        print('Failed to send request: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }



  ////send status


  void callApi({required String questionId,required String question,required String answer,}) async {
    final apiService = getIt<ApiService>();
    final userService = getIt<UserService>();

    String userId = await userService.getUserIdentifier(); // Get or create unique ID


    bool success = await apiService.submitAnswer(
      userIdentifier: userId,
      challenge: 'PCOS',
      questionId: questionId,
      question: question,
      answer: answer,
    );

    if (success) {
      print("Answer submitted successfully!");
    } else {
      print("Failed to submit answer.");
    }
  }




  String get menstrualCycleTyp => _menstrualCycleTyp;

  set menstrualCycleTyp(String value) {
    _menstrualCycleTyp = value;
    notifyListeners();
  }

  String get pimplesStatus => _pimplesStatus;

  set pimplesStatus(String value) {
    _pimplesStatus = value;
    notifyListeners();
  }

  List<HairAnswer> get answer => _answer;

  set answer(List<HairAnswer> value) {
    _answer = value;
    notifyListeners();
  }

  double get weight => _weight;

  set weight(double value) {
    _weight = value;
    notifyListeners();
  }

  double get height => _height;

  set height(double value) {
    _height = value;
    notifyListeners();
  }

  double get bmi => _bmi;

  set bmi(double value) {
    _bmi = value;
    notifyListeners();
  }

  bool? get userAnswer => _userAnswer;

  set userAnswer(bool? value) {
    _userAnswer = value;
    notifyListeners();
  }

  int get currentQuestionIndex => _currentQuestionIndex;

  set currentQuestionIndex(int value) {
    _currentQuestionIndex = value;
    notifyListeners();
  }

  int get currentHairQuestionIndex => _currentHairQuestionIndex;

  set currentHairQuestionIndex(int value) {
    _currentHairQuestionIndex = value;
    notifyListeners();
  }

  int calculateHairGrowth() {
    HairAnswer upperLip = _answer.firstWhere(
      (data) {
        return data.area == 'Upper Lip';
      },
      orElse: () => HairAnswer('Upper Lip', 0),
    );

    HairAnswer chin = _answer.firstWhere(
      (data) {
        return data.area == 'Chin';
      },
      orElse: () => HairAnswer('Chin', 0),
    );

    HairAnswer lowerAbdomen = _answer.firstWhere(
      (data) {
        return data.area == 'Lower Abdomen';
      },
      orElse: () => HairAnswer('Lower Abdomen', 0),
    );

    HairAnswer thighs = _answer.firstWhere(
      (data) {
        return data.area == 'Thighs';
      },
      orElse: () => HairAnswer('Thighs', 0),
    );
    int totalScore = {
      'Upper Lip': upperLip.severity,
      'Chin': chin.severity,
      'Lower Abdomen': lowerAbdomen.severity,
      'Thighs': thighs.severity,
    }.values.reduce((a, b) => a + b);

    // Define thresholds
    if (totalScore <= 4) {
      return -1;
    } else if (totalScore <= 8) {
      return 0;
    } else {
      return 1;
    }

    // Show result
  }
}
