class SendQuestionsResModel {
  String? status;

  SendQuestionsResModel({this.status});

  SendQuestionsResModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
  }

  get message => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    return data;
  }
}
