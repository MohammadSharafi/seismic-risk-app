class ChallengeResModel {
  String? status;
  Data? data;

  ChallengeResModel({this.status, this.data});

  ChallengeResModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Challenge? challenge;

  Data({this.challenge});

  Data.fromJson(Map<String, dynamic> json) {
    challenge = json['challenge'] != null
        ? new Challenge.fromJson(json['challenge'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.challenge != null) {
      data['challenge'] = this.challenge!.toJson();
    }
    return data;
  }
}

class Challenge {
  String? sId;
  String? userId;
  String? challengeId;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;
  Meta? mMeta;
  String? badgeId;

  Challenge(
      {this.sId,
      this.userId,
      this.challengeId,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.mMeta,
      this.badgeId});

  Challenge.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    challengeId = json['challengeId'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    mMeta = json['_meta'] != null ? new Meta.fromJson(json['_meta']) : null;
    badgeId = json['badgeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['challengeId'] = this.challengeId;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.mMeta != null) {
      data['_meta'] = this.mMeta!.toJson();
    }
    data['badgeId'] = this.badgeId;
    return data;
  }
}

class Meta {
  String? userTag;
  String? unlockedContent;
  int? totalScore;
  String? result;

  Meta({this.userTag, this.unlockedContent, this.totalScore, this.result});

  Meta.fromJson(Map<String, dynamic> json) {
    userTag = json['userTag'];
    unlockedContent = json['unlockedContent'];
    totalScore = json['totalScore'];
    result = json['result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userTag'] = this.userTag;
    data['unlockedContent'] = this.unlockedContent;
    data['totalScore'] = this.totalScore;
    data['result'] = this.result;
    return data;
  }
}
