class ChallengeModel {
  String email;
  String fullName;
  String challengeId;
  List<ChallengeQuestion> challengeQuestions = [];

  ChallengeModel({
    required this.email,
    required this.fullName,
    required this.challengeId,
  });

  void addQuestion(ChallengeQuestion question) {
    challengeQuestions.add(question);
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      email: json['email'],
      fullName: json['fullName'],
      challengeId: json['challengeId'],
    )..challengeQuestions = (json['challengeQuestions'] as List)
        .map((item) => ChallengeQuestion.fromJson(item))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'challengeId': challengeId,
      'challengeQuestions': challengeQuestions.map((item) => item.toJson()).toList(),
    };
  }
}

class ChallengeQuestion {
  String id;
  dynamic answer;

  ChallengeQuestion({
    required this.id,
    required this.answer,
  });

  factory ChallengeQuestion.fromJson(Map<String, dynamic> json) {
    return ChallengeQuestion(
      id: json['_id'],
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'answer': answer,
    };
  }
}
