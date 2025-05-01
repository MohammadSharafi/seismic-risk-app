import 'package:hive/hive.dart';

import 'QuestionaryReqModel.dart';


abstract class QuestionaryRepository {
  Future<QuestionaryReqModel> get();
  Future<void> reset();
  Future<void> add(QuestionaryReqModel data);
  Future<bool> hasData();

}

class QuestionaryRepositoryImpl implements QuestionaryRepository {
  static const String _initialKey = 'QuestionaryReqModelKey';
  final Box<QuestionaryReqModel> _questionaryBox;

  QuestionaryRepositoryImpl(this._questionaryBox);

  @override
  Future<QuestionaryReqModel> get() async {
    return _questionaryBox.get(_initialKey) ?? QuestionaryReqModel(userQuestionary: []);
  }

  @override
  Future<void> reset() async {
    await _questionaryBox.put(_initialKey, QuestionaryReqModel(userQuestionary: []));
  }

  @override
  Future<void> add(QuestionaryReqModel data) async {
    final current = await get();
    final currentQuestions = current.userQuestionary ?? [];
    final newQuestions = data.userQuestionary ?? [];

    final questionMap = <String, UserQuestionary>{};
    for (final question in currentQuestions) {
      if (question.questionId != null) questionMap[question.questionId!] = question;
    }
    for (final question in newQuestions) {
      if (question.questionId != null) questionMap[question.questionId!] = question;
    }

    final updatedModel = QuestionaryReqModel(
      userQuestionary: questionMap.values.toList(),
    );

    await _questionaryBox.put(_initialKey, updatedModel);
  }

  @override
  Future<bool> hasData() async {
    final data = await get();
    return data.userQuestionary != null && data.userQuestionary!.isNotEmpty;
  }
}