import 'package:dio/dio.dart';
import 'package:march_web_qa/controllers/userservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sendQuestionsResModel.dart';
import 'injection.dart';

// Define BASE URL
const String BASE_URL = "https://api.march.health/monomarch/api/v1"; // Replace with your actual base URL

// API Service Class
class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: BASE_URL));

  Future<SendQuestionsResModel> sendQuestion(Map<String, dynamic> requestModel) async {
    try {
      Response response = await _dio.post(
        "/webhooks/on-sync-website-questionary",
        data: requestModel,
        options: Options(headers: {"Content-Type": "application/json", "on-sync-website-questionary-api-key": "EUQqgx1LHVkbz8Fw4C1udf3FNZAwp87e0w1bCJaBBFmUbRsZ2a3buGQOONvRudtY"}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SendQuestionsResModel.fromJson(response.data);
      } else {
        throw Exception("Failed to send data: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Error sending request: $e");
    }
  }

  Future<SendQuestionsResModel> trackUser({required String question, required String answer, required String tag, required String number}) async {
    try {
      final userService = getIt<UserService>();
      String userId = await userService.getUserIdentifier();
      final SharedPreferences _prefs = await SharedPreferences.getInstance();
      if (tag == 'USER_NAME') {
        _prefs.setString('name', answer);
      }
      if (tag == 'USER_EMAIL') {
        _prefs.setString('email', answer);
      }

      var data = {};

      if (_prefs.getString('email') != null && _prefs.getString('name') != null) {
        data = {
          'userIdentifier': userId,
          'question': question,
          'questionId': number,
          'answer': '',
          'category': tag,
          'email': _prefs.getString('email'),
          'fullName': _prefs.getString('name'),
        };
      } else {
        data = {
          'userIdentifier': userId,
          'question': question,
          'questionId': number,
          'answer': answer,
          'category': tag,
        };
      }

      Response response = await _dio.post(
        "/webhooks/on-sync-create-user-real-time-website-questionary",
        data: data,
        options: Options(headers: {"Content-Type": "application/json", "on-sync-website-questionary-api-key": "EUQqgx1LHVkbz8Fw4C1udf3FNZAwp87e0w1bCJaBBFmUbRsZ2a3buGQOONvRudtY"}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SendQuestionsResModel.fromJson(response.data);
      } else {
        throw Exception("Failed to send data: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Error sending request: $e");
    }
  }
}
