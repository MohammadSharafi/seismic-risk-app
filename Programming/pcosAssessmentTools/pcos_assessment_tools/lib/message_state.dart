import 'package:flutter/material.dart';

// Example message model
class Message {
  final String id;
  final bool isSystem;
  final bool isQuestion;
  final bool isAnswered;
  final QuestionType questionType;
  final String? userResponse;
  final List<Option>? options;
  final Widget Function(BuildContext context)? widgetContentBuilder;


  Message({
    required this.id,
    this.isSystem = false,
    this.isQuestion = false,
    this.isAnswered = false,
    this.questionType = QuestionType.none,
    this.userResponse,
    this.options,
    this.widgetContentBuilder,
  });

  // Helper for immutability
  Message copyWith({
    bool? isSystem,
    bool? isQuestion,
    bool? isAnswered,
    QuestionType? questionType,
    String? userResponse,
    List<Option>? options,
    Widget Function(BuildContext context)? widgetContentBuilder,
  }) {
    return Message(
      id: id,
      isSystem: isSystem ?? this.isSystem,
      isQuestion: isQuestion ?? this.isQuestion,
      isAnswered: isAnswered ?? this.isAnswered,
      questionType: questionType ?? this.questionType,
      userResponse: userResponse ?? this.userResponse,
      options: options ?? this.options,
      widgetContentBuilder: widgetContentBuilder ?? this.widgetContentBuilder,
    );
  }
}

class Option {
  final String text;
  final String? image;
  final bool isSelected;
  final String ?id;

  Option( {required this.text, this.image, this.isSelected = false,this.id});

  Option copyWith({bool? isSelected}) {
    return Option(
      text: text,
      image: image,
      id:id,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

enum QuestionType {
  none,
  text,
  option,
  multiSelection,
  numberSelector,
  slider,
  nextStep,
}


class MessageState with ChangeNotifier {
  final List<Message> _messages = [];

  // Getter for messages
  List<Message> get messages => _messages;

  // Update user response for a specific message
  void updateUserResponse(String messageId, String response) {
    final message = _messages.firstWhere((msg) => msg.id == messageId, orElse: () => throw Exception('Message not found'));
    final updatedMessage = Message(
      id: message.id,
      isSystem: message.isSystem,
      isQuestion: message.isQuestion,
      isAnswered: true,
      questionType: message.questionType,
      userResponse: response,
      options: message.options,
      widgetContentBuilder: message.widgetContentBuilder,
    );
    _updateMessage(messageId, updatedMessage);
    notifyListeners();
  }

  // Helper to update a message
  void _updateMessage(String messageId, Message updatedMessage) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      _messages[index] = updatedMessage;
    }
  }

  // Check if an option is selected
  bool isOptionSelected(String messageId, String optionText) {
    final message = _messages.firstWhere((msg) => msg.id == messageId, orElse: () => throw Exception('Message not found'));
    return message.options?.any((option) => option.text == optionText && option.isSelected) ?? false;
  }

  // Toggle option selection
  void toggleOptionSelection(String messageId, String optionText) {
    final message = _messages.firstWhere((msg) => msg.id == messageId, orElse: () => throw Exception('Message not found'));
    final options = message.options?.map((option) {
      if (option.text == optionText) {
        return Option(
          text: option.text,
          image: option.image,
          isSelected: !option.isSelected,
        );
      }
      return option;
    }).toList();

    final updatedMessage = Message(
      id: message.id,
      isSystem: message.isSystem,
      isQuestion: message.isQuestion,
      isAnswered: message.isAnswered,
      questionType: message.questionType,
      userResponse: message.userResponse,
      options: options,
      widgetContentBuilder: message.widgetContentBuilder,
    );
    _updateMessage(messageId, updatedMessage);
    notifyListeners();
  }

  // Navigate to the next question
  void nextQuestion() {
    // Logic to go to the next question
    // Example: Notify listeners
    notifyListeners();
  }
}
