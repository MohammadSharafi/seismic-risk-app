import '../../../core/base_network_model.dart';

class QuestionaryResModel extends BaseNetworkModel<QuestionaryResModel> {

  QuestionaryResModel({this.status});

  QuestionaryResModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
  }
  String? status;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;

    return data;
  }

  @override
  QuestionaryResModel fromJson(Map<String, dynamic> json) {
    return QuestionaryResModel.fromJson(json);
  }
}
