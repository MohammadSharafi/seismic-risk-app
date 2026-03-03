import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import '../models/Questions.dart';
import 'dart:async';

class QuestionController extends GetxController {
  final RxDouble progress = 0.0.obs;
  final RxInt questionNumber = 1.obs;
  final RxInt numOfCorrectAnswers = 0.obs;
  final RxList<QuestionAnswer> questionAnswers = <QuestionAnswer>[].obs;
  late List<Question> questions;
  final int _questionDuration = 10;

  @override
  void onClose() {
    super.onClose();
  }

  void initialize(List<Question> questionList) {
    questions = questionList;
    _initQuestionAnswers();
  }

  void _initQuestionAnswers() {
    questionAnswers.assignAll(List.generate(questions.length, (index) => QuestionAnswer()));
  }

  void checkAnswer(int questionIndex) {
    final selected = questionAnswers[questionIndex].selectedAnswers;
    final correctAnswer = questions[questionIndex].answerIndex;

    if (selected.contains(correctAnswer)) {
      numOfCorrectAnswers.value++;
    }
    questionAnswers[questionIndex].isAnswered.value = true;
  }

  void toggleAnswerSelection(int questionIndex, int selectedIndex, bool isMultiSelect) {
    final qa = questionAnswers[questionIndex];
    if (qa.isAnswered.value) return;

    if (isMultiSelect) {
      qa.selectedAnswers.contains(selectedIndex) ? qa.selectedAnswers.remove(selectedIndex) : qa.selectedAnswers.add(selectedIndex);
    } else {
      qa.selectedAnswers.value = [selectedIndex];
    }
  }
}

class QuestionAnswer {
  final RxList<int> selectedAnswers = <int>[].obs;
  final RxBool isAnswered = false.obs;
}

class QuizProvider with ChangeNotifier {
  late PageController _pageController;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  List<Question> _questions = [];
  List<dynamic> _selectedAnswers = [];

  QuizProvider() {
    _pageController = PageController();
  }

  PageController get pageController => _pageController;

  int get currentQuestionIndex => _currentQuestionIndex;

  List<Question> get questions => _questions;

  List<dynamic> get selectedAnswers => _selectedAnswers;

  Question currentQuestion() {
    return _questions[_currentQuestionIndex];
  }

  Map<String, dynamic> currentAnswer() {
    final answer = _selectedAnswers[_currentQuestionIndex];
    Question question = currentQuestion();

    switch (question.type) {
      case QuestionType.multipleChoice:
        return {'ans': (answer as List<int>).map((index){ return question.options![index];   }).toList().join(", "), 'question': question.question, 'tag': question.tag, 'number': _currentQuestionIndex + 1,'id':question.id};
      case QuestionType.numberField:
      case QuestionType.slider:
        return {'ans': answer.toString(), 'question': question.question, 'tag': question.tag, 'number': _currentQuestionIndex + 1,'id':question.id};

      case QuestionType.singleChoice:
        return {'ans': question.options![answer], 'question': question.question, 'tag': question.tag, 'number': _currentQuestionIndex + 1,'id':question.id};

      case QuestionType.textField:
        return {'ans': answer as String, 'question': question.question, 'tag': question.tag, 'number': _currentQuestionIndex + 1,'id':question.id};
      case QuestionType.periodCalendar:
      case QuestionType.calendar:
        return {'ans': (answer as DateTime).toIso8601String(), 'question': question.question, 'tag': question.tag, 'number': _currentQuestionIndex + 1,'id':question.id};
      default:
        return {'ans': '', 'question': '', 'tag': '', 'number': 0,'id':''}; // Handle unexpected cases
    }
  }

  void initialize(List<Question> questions) {
    _questions = questions;
    _selectedAnswers = List.generate(questions.length, (index) {
      switch (questions[index].type) {
        case QuestionType.multipleChoice:
          return <int>[];
        case QuestionType.singleChoice:
          return -1;
        case QuestionType.textField:
        case QuestionType.numberField:
        case QuestionType.calendar:
          return '';
        default:
          return null;
      }
    });
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentQuestionIndex = index;
    notifyListeners();
  }

  void selectAnswer(dynamic answer) {
    _selectedAnswers[_currentQuestionIndex] = answer;
    notifyListeners();
  }

  void toggleMultipleChoiceAnswer(int optionIndex) {
    List<int> selected = _selectedAnswers[_currentQuestionIndex] as List<int>;
    if (selected.contains(optionIndex)) {
      selected.remove(optionIndex);
    } else {
      selected.add(optionIndex);
    }
    _selectedAnswers[_currentQuestionIndex] = selected;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {}
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
