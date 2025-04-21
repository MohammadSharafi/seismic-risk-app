import 'package:flutter/cupertino.dart';
import 'package:openai_dart/openai_dart.dart';
import '../../../../../injection.dart';
import '../model/chat_bot_entity.dart';
import '../model/chat_bot_repo.dart';

class ChatNotifier with ChangeNotifier {
  ChatBotRepository chatBotRepository = getIt.get<ChatBotRepository>();

  bool _canUserSelect = true;

  bool get canUserSelect => _canUserSelect;

  set canUserSelect(bool value) {
    _canUserSelect = value;
    notifyListeners();
  }

  final TextEditingController _controller;
  final ScrollController _scrollController;

  TextEditingController get controller => _controller;

  List<MessageChatBot> _conversation = [];
  List<DateLineChatBot> dateLines = [DateLineChatBot(DateTime.now())];

  void addMessage(MessageChatBot message) {
    _conversation.insert(0, message);
    chatBotRepository.updateMessages(_conversation);
    notifyListeners();
  }

  FocusNode textFieldFocus = FocusNode();
  bool isTyping = false;
  bool _hideTextField = false;
  late final OpenAIClient _openAI;
  String? threadId;

  bool get hideTextField => _hideTextField;

  set hideTextField(bool value) {
    _hideTextField = value;
    notifyListeners();
  }

  ChatNotifier(this._controller, this._scrollController) {
    initializeChat();
  }

  Future<void> initializeChat() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    // threadId = prefs.getString('thread_id');

    _openAI = OpenAIClient(
      baseUrl: 'https://marchv2.openai.azure.com/openai',
      headers: {'api-key': 'CYbkKYpabAX1nkzkv3jf242N1J6SUthe3NBMzR8bacs2CEci88TWJQQJ99BDACHYHv6XJ3w3AAABACOGgd9Y'},
      queryParams: {'api-version': '2024-12-01-preview'},
    );
    _conversation = await chatBotRepository.getMessages();

    //if (threadId == null) {
    var threadResponse = await _openAI.createThread(
      request: CreateThreadRequest(),
    );
    threadId = threadResponse.id;
    //await prefs.setString('thread_id', threadId!);
    // }

    if (_conversation.isEmpty) {

      _conversation.add(MessageChatBot(
          false,
          'Greetings! I am the March Health Assistant, committed to delivering expert information. How can I support you today?',
          DateTime.now()));
      chatBotRepository.updateMessages(_conversation);
    }
    initTextFieldState();
  }

  List<MessageChatBot> get conversation => _conversation;

  Future<bool> waitForRunCompletion(String threadId, String runId) async {
    while (true) {
      var runStatus = await _openAI.getThreadRun(
        threadId: threadId,
        runId: runId,
      );
      if (runStatus.status.toString().contains('completed')) {
        return true;
      } else if (runStatus.status.toString().contains('failed')) {
        throw Exception('Assistant run failed');
      }
      await Future.delayed(Duration(seconds: 1)); // Poll every second or adjust as needed
    }
  }

  String formatOptions(List<String> options) {
    String result = '';
    for (int i = 0; i < options.length; i++) {
      String option = options[i];
      // Extract the option letter from the string
      String optionLetter = option.substring(option.indexOf('(') + 1, option.indexOf(')'));

      // Concatenate the index and option letter
      result += '${i + 1}.$optionLetter ';

      // Optionally, you can add space after each option for better readability
      // result += '${i + 1}.$optionLetter ';
    }
    return result;
  }

  String extractOptionText(String option) {
    int startIndex = option.indexOf(')') + 1; // Find the index right after ')'
    if (startIndex > 0 && startIndex < option.length) {
      String result = option.substring(startIndex).trim(); // Extract substring from that point
      if (result.startsWith('.')) {
        result = result.substring(1).trim(); // Remove the dot if it starts with it
      }
      return result;
    }
    return ""; // Return an empty string if the format is incorrect
  }

  void initTextFieldState() {
    if (_conversation.isEmpty) {
      return;
    }

    notifyListeners();
  }

  String sex = '';
  String pregnant = '';
  String age = '';

  void sendMsg({String? selectedOption}) async {
    DateTime dateTime = DateTime.now();
    String text = (selectedOption ?? _controller.text);
    if (text.isEmpty) {
      return;
    }
    _controller.text = '';

    addMessage(MessageChatBot(true, text, dateTime));
    isTyping = true;
   /// _hideTextField = true;
    _controller.text = '';

    await _openAI.createThreadMessage(
      threadId: threadId!,
      request: CreateMessageRequest(
        role: MessageRole.user,
        content: CreateMessageRequestContent.text(
          text,
        ),
      ),
    );

    var runResponse = await _openAI.createThreadRun(
      threadId: threadId!,
      request: CreateRunRequest(assistantId: 'asst_Pnb4INgFtbDAkRHjUQMAqPwe'),
    );

    await waitForRunCompletion(threadId!, runResponse.id);
    var messagesResponse = await _openAI.listThreadMessages(
      threadId: threadId!,
    );
    var assistantMessages = messagesResponse.data.toList().reversed;

    isTyping = false;

    addMessage(MessageChatBot(
      false,
      assistantMessages.last.content[0].text,
      dateTime,
    ));

    initTextFieldState();
  }



  ScrollController get scrollController => _scrollController;

}
