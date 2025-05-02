import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'chat_bot_entity.dart';



abstract class ChatBotRepository {
  Future<List<MessageChatBot>> getMessages();
  Future<void> reset();
  Future<void> updateMessages(List<MessageChatBot> data);
}

class ChatBotRepositoryImpl implements ChatBotRepository {
  final SharedPreferences _prefs;

  ChatBotRepositoryImpl(this._prefs);

  @override
  Future<List<MessageChatBot>> getMessages() async {
    String? messagesJson = _prefs.getString('ChatBotMessagesDta');

    if (messagesJson != null) {
      // Convert JSON string to List<MessageChatBot>
      List<dynamic> decodedList = json.decode(messagesJson);
      List<MessageChatBot> messages = decodedList
          .map((messageJson) => MessageChatBot.fromJson(messageJson))
          .toList();
      return messages;
    } else {
      return [];
    }
  }

  @override
  Future<void> updateMessages(List<MessageChatBot> data) async {
    // Convert List<MessageChatBot> to JSON string
    String messagesJson = json.encode(data.map((e) => e.toJson()).toList());

    // Save JSON string to SharedPreferences
    await _prefs.setString('ChatBotMessagesDta', messagesJson);
  }

  @override
  Future<void> reset() async {
    // Remove ChatBotMessages key from SharedPreferences
    await _prefs.remove('ChatBotMessagesDta');
  }
}