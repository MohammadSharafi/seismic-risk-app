class SendQuestionsReqModel {
  List<UserQuestionary>? userQuestionary;
  String? email;

  SendQuestionsReqModel({this.userQuestionary, this.email});

  SendQuestionsReqModel.fromJson(Map<String, dynamic> json) {
    if (json['userQuestionary'] != null) {
      userQuestionary = <UserQuestionary>[];
      json['userQuestionary'].forEach((v) {
        userQuestionary!.add(new UserQuestionary.fromJson(v));
      });
    }
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userQuestionary != null) {
      data['userQuestionary'] =
          this.userQuestionary!.map((v) => v.toJson()).toList();
    }
    data['email'] = this.email;
    return data;
  }
}

class UserQuestionary {
  String? stepId;
  String? answer;

  UserQuestionary({this.stepId, this.answer});

  UserQuestionary.fromJson(Map<String, dynamic> json) {
    stepId = json['stepId'];
    answer = json['answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stepId'] = this.stepId;
    data['answer'] = this.answer;
    return data;
  }
}
