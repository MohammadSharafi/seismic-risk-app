import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssessmentNotifier {
  static final AssessmentNotifier _instance = AssessmentNotifier._internal();
  late final OpenAIClient _openAI;
  late SharedPreferences _prefs;

  factory AssessmentNotifier() => _instance;
  final Completer<void> _threadIdCompleter = Completer<void>();

  AssessmentNotifier._internal() {
    _init();
  }

  Future<void> _init() async {
    await _initSharedPreferences();

    _openAI = OpenAIClient(
      baseUrl: 'https://marchv1.openai.azure.com/openai',
      headers: {'api-key': 'b12a39b621964269a0da06699f814f01'},
      queryParams: {'api-version': '2024-08-01-preview'},
    );


    await _initializeChat();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //String get _mentalThreadId => _prefs.getString('thread_id') ?? '';
  String threadId = '';

  Future<void> _initializeChat() async {


    var mentalThreadResponse = await _openAI.createThread(
      request: CreateThreadRequest(),
    );
    threadId = mentalThreadResponse.id;
    await _prefs.setString('thread_id', mentalThreadResponse.id);

    // Complete the completer so that other functions know threadId is ready
    _threadIdCompleter.complete();
  }

  Future<HealthData> sendData(dynamic data) async {
    // Wait until threadId is initialized
    await _threadIdCompleter.future;

    try {
      await _sendMentalMessage(data);
      var runId = await _createMentalRun();
      await _waitForMentalRunCompletion(runId);
      HealthData healthData = await _getMentalMessages();
      return healthData;
    } catch (e) {
      print('Error while sending data: $e');
      throw Exception('Failed to send data.');
    }
  }

  String encodeJsonToBase64(Map<String, dynamic> jsonMap) {
    String jsonString = json.encode(jsonMap);
    String base64String = base64.encode(utf8.encode(jsonString));
    return base64String;
  }

  String _addDateToJson(dynamic data) {
    DateTime now = DateTime.now();
    String formattedDate = now.toIso8601String();
    data = _removeEmptyListsAndNull(data);
    return json.encode({'date': formattedDate, 'data': data});
  }

  dynamic _removeEmptyListsAndNull(dynamic data) {
    if (data is List) {
      return data.where((e) => e != null && (e is! List || e.isNotEmpty)).map((e) => _removeEmptyListsAndNull(e)).toList();
    } else if (data is Map) {
      Map<String, dynamic> newData = {};
      data.forEach((key, value) {
        if (value != null) {
          newData[key] = _removeEmptyListsAndNull(value);
        }
      });
      return newData;
    } else {
      return data;
    }
  }

  Future<void> _sendMentalMessage(String dataJson) async {

    await _openAI.createThreadMessage(
      threadId: threadId,
      request: CreateMessageRequest(
        role: MessageRole.user,
        content: CreateMessageRequestContent.text(
          dataJson,
        ),
      ),
    );

  }

  Future<String> _createMentalRun() async {
    var runResponse = await _openAI.createThreadRun(
      threadId: threadId,
      request: CreateRunRequest(assistantId: 'asst_MCS5QnJi4P8mp6QQJVPujAaW'),
    );

    return runResponse.id;
  }

  Future<void> _waitForMentalRunCompletion(String runId) async {
    while (true) {
      var runStatus = await _openAI.getThreadRun(
        threadId: threadId,
        runId: runId,
      );
      if (runStatus.status.toString().contains('completed')) {
        break;
      } else if (runStatus.status.toString().contains('failed')) {
        throw Exception('Assistant run failed');
      }
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<HealthData> _getMentalMessages() async {
    var messagesResponse = await _openAI.listThreadMessages(
      threadId: threadId,
    );
    var assistantMessages = messagesResponse.data.toList().reversed;
    print(assistantMessages);

    _prefs.setString('recommendation', assistantMessages.last.content[0].text);

    Map<String, dynamic> jsonMap = json.decode(assistantMessages.last.content[0].text);
    HealthData healthData = HealthData.fromJson(jsonMap);

    return healthData;
  }
}

class HealthData {
  final int painLvl;
  final int energyLvl;
  final List<List<double>> cycleRegularity;
  final int moodFluctuations;
  final String painRecommendation;
  final String healthAgentSuggestion;
  final String pain_recommendation_flag;
  final num cycle_regularity_current_position;

  HealthData({
    required this.painLvl,
    required this.energyLvl,
    required this.cycleRegularity,
    required this.moodFluctuations,
    required this.painRecommendation,
    required this.healthAgentSuggestion,
    required this.pain_recommendation_flag,
    required this.cycle_regularity_current_position,
  });

  // Convert JSON to Dart object
  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      painLvl: json['pain_lvl'],
      energyLvl: json['energy_lvl'],
      cycleRegularity: (json['cycle_regularity'] as List).map((item) => List<double>.from(item)).toList(),
      moodFluctuations: json['mood_fluctuations'],
      painRecommendation: json['pain_recommendation'],
      healthAgentSuggestion: json['health_agent_suggestion'],
      pain_recommendation_flag: json['pain_recommendation_flag'] ?? '',
      cycle_regularity_current_position: json['cycle_regularity_current_position'],
    );
  }
}

class ChartUpdateNotifier with ChangeNotifier {
  Map<String, int> _symptoms = {};
  HealthData _healthData;

  Map<String, int> get symptoms => _symptoms;

  HealthData get healthData => _healthData;

  set healthData(HealthData value) {
    _healthData = value;
    notifyListeners();
  }

  set symptoms(Map<String, int> value) {
    _symptoms = value;
    notifyListeners();
  }

  ChartUpdateNotifier(this._healthData);
}
