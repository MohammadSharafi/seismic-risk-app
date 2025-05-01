// Answer data structure
class SurveyAnswer {
  final Map<int, Map<int, dynamic>> answers = {};

  void setAnswer(int pageIndex, int questionIndex, dynamic value) {
    answers.putIfAbsent(pageIndex, () => {});
    answers[pageIndex]![questionIndex] = value;
  }

  dynamic getAnswer(int pageIndex, int questionIndex) {
    return answers[pageIndex]?[questionIndex];
  }

  Map<String, dynamic> toJson() {
    return answers.map((page, questions) => MapEntry(page.toString(), questions));
  }
}