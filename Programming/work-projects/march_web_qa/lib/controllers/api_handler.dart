
import 'package:dio/dio.dart';

import '../models/sendQuestionsResModel.dart';

// Define BASE URL
const String BASE_URL = "https://api.march.health/monomarch/api/v1"; // Replace with your actual base URL


// API Service Class
class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: BASE_URL));

  Future<SendQuestionsResModel> sendQuestion(Map<String, dynamic> requestModel) async {
    try {
      Response response = await _dio.post(
        "/webhooks/on-sync-create-user-real-time-assessment-question-answer",
        data: requestModel,
        options: Options(headers: {
          "Content-Type": "application/json",
          "ON_SYNC_WEBSITE_QUESTIONARY_API_KEY":"EUQqgx1LHVkbz8Fw4C1udf3FNZAwp87e0w1bCJaBBFmUbRsZ2a3buGQOONvRudtY"
        }),
      );

      if (response.statusCode == 200) {
        return SendQuestionsResModel.fromJson(response.data);
      } else {
        throw Exception("Failed to send data: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Error sending request: $e");
    }
  }
}

