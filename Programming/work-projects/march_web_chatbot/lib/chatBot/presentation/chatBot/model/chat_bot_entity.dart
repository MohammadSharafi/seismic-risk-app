

class ChatBotEntry {
  List<MessageChatBot>? messages; // Changed initialization for nullable type

  ChatBotEntry({this.messages});
}

class QuestionChatBot {
  String text;
  List<String> options;

  QuestionChatBot(this.text, this.options);
}

class MessageChatBot {
  bool isSender;
  String msg;
  bool isThumbsUpClicked;
  DateTime dateTime;

  MessageChatBot(
      this.isSender,
      this.msg,
      this.dateTime, {
        this.isThumbsUpClicked = false,
      });

  // Method to convert MessageChatBot instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'isSender': isSender,
      'msg': msg,
      'isThumbsUpClicked': isThumbsUpClicked,
      'dateTime': dateTime.toString(),
    };
  }

  // Factory method to create MessageChatBot instance from JSON
  factory MessageChatBot.fromJson(Map<String, dynamic> json) {
    return MessageChatBot(
      json['isSender'] ?? false,
      json['msg'] ?? '',
      DateTime.parse(json['dateTime'] ?? ''),
      isThumbsUpClicked: json['isThumbsUpClicked'] ?? false,
    );
  }
}

class DateLineChatBot {
  DateTime dateTime;

  DateLineChatBot(this.dateTime);
}
