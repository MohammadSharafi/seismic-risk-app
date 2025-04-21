import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:march_web_chatbot/chatBot/presentation/chatBot/screens/start_screen.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  _ChatBotPageState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale('en', 'IN')],
      title: 'March Health',
      home: Scaffold(
        body: Stack(
          children: [
            buildDigitalTwinMainContent(context),
          ],
        ),
      ),
    );
  }

  //DIGITAL TWIN
  Widget buildDigitalTwinMainContent(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: StartScreen(),
    );
  }
}
