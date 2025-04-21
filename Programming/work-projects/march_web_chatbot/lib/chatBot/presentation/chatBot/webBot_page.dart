import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:march_web_chatbot/chatBot/presentation/chatBot/screens/chatBot_screen.dart';
import 'package:provider/provider.dart';
import 'controllers/Chat_notifier.dart';

class WebBotPage extends StatefulWidget {
  const WebBotPage();

  @override
  _WebBotPageState createState() => _WebBotPageState();
}

class _WebBotPageState extends State<WebBotPage> {
  _WebBotPageState();

  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale('en', 'IN')],
      title: 'March Health',
      home: Scaffold(
        body: Stack(
          children: [
            buildMainContent(context),
          ],
        ),
      ),
    );
  }

  Widget buildMainContent(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ChatNotifier(controller, scrollController),
          ),
        ],
        child: ChatBotScreen(pageController),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
