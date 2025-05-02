import 'package:hive/hive.dart';
part 'QuestionaryReqModel.g.dart';

@HiveType(typeId: 50)
class QuestionaryReqModel extends HiveObject {
  @HiveField(0)
  List<UserQuestionary>? userQuestionary;

  @HiveField(1)
  String ?sessionId;
  String ?userIdentifier;

  QuestionaryReqModel({this.userQuestionary,this.sessionId, this.userIdentifier});

  QuestionaryReqModel.fromJson(Map<String, dynamic> json) {
    if (json['userQuestionary'] != null) {
      userQuestionary = <UserQuestionary>[];
      json['userQuestionary'].forEach((v) {
        userQuestionary!.add(UserQuestionary.fromJson(v));
      });
    }
    sessionId = json['sessionId'];
    userIdentifier = json['userIdentifier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (userQuestionary != null) {
      data['userQuestionary'] = userQuestionary!.map((v) => v.toJson()).toList();
    }
    data['sessionId'] = sessionId;
    data['userIdentifier'] = userIdentifier;

    return data;
  }
}

@HiveType(typeId: 1)
class UserQuestionary extends HiveObject {
  @HiveField(0)
  String? questionId;

  @HiveField(1)
  dynamic answer; // Hive supports dynamic types, but you might want to specify concrete types

  UserQuestionary({this.questionId, this.answer});

  UserQuestionary.fromJson(Map<String, dynamic> json) {
    questionId = json['questionId'];
    answer = json['answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['questionId'] = questionId;
    data['answer'] = answer;
    return data;
  }
}