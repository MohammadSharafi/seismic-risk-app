import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../common/config/march_style/hexColor.dart';
import '../../../../common/config/march_style/march_icons.dart';
import '../../../../common/config/march_style/march_size.dart';
import '../controllers/Chat_notifier.dart';
import '../widgets/bubble_chat.dart';

class ChatBotScreen extends StatelessWidget {
  ChatBotScreen(this.pageController);

  final PageController pageController;

  String formatDateChat(DateTime date) {
    return DateFormat("yyyy.MM.dd", 'en_US').format(date);
  }

  String _getLabelText(double percentage) {
    if (percentage <= 33) {
      return 'Non-emergency: Stable condition, no immediate treatment needed.';
    } else if (percentage <= 66) {
      return 'Moderately urgent: See a doctor soon.';
    } else {
      return 'Highly urgent: Go to the emergency room immediately.';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double chatBubbleMaxWidth = size.width * 0.85; // Maximized width for small frame
    final double horizontalPadding = size.width * 0.05; // Minimal padding

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to blend with frame
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Consumer<ChatNotifier>(
          builder: (context, notifier, child) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: notifier.scrollController,
                    reverse: true,
                    padding: EdgeInsets.only(bottom: 60, top: 8, left: horizontalPadding, right: horizontalPadding),
                    itemCount: notifier.conversation.length,
                    itemBuilder: (context, index) {
                      final isSender = notifier.conversation[index].isSender;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: notifier.isTyping && index == 0
                            ? Column(
                          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            _buildMessageRow(
                              context,
                              notifier,
                              index,
                              chatBubbleMaxWidth,
                              isSender,
                              horizontalPadding,
                            ),
                            _buildTimeStamp(
                              context,
                              notifier.conversation[index].dateTime,
                              isSender,
                              size,
                            ),
                            _buildTypingIndicator(
                              context,
                              chatBubbleMaxWidth,
                              horizontalPadding,
                            ),
                          ],
                        )
                            : Column(
                          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (index == notifier.conversation.length - 1)
                              _buildDateDivider(
                                context,
                                notifier.dateLines.first.dateTime,
                                size,
                              ),
                            _buildMessageRow(
                              context,
                              notifier,
                              index,
                              chatBubbleMaxWidth,
                              isSender,
                              horizontalPadding,
                            ),
                            _buildTimeStamp(
                              context,
                              notifier.conversation[index].dateTime,
                              isSender,
                              size,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                notifier.hideTextField
                    ? const SizedBox.shrink()
                    : _buildInputField(
                  context,
                  notifier,
                  size,
                  horizontalPadding,
                  pageController,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateDivider(BuildContext context, DateTime date, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Expanded(child: Divider(thickness: 0.5, color: Colors.grey)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              formatDateChat(date),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.grey[600],
                fontSize: size.width > 350 ? 10 : 8,
              ),
            ),
          ),
          const Expanded(child: Divider(thickness: 0.5, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMessageRow(
      BuildContext context,
      ChatNotifier notifier,
      int index,
      double maxWidth,
      bool isSender,
      double horizontalPadding,
      ) {
    return Row(
      mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // if (!isSender)
        //   Padding(
        //     padding: EdgeInsets.only(right: 4, bottom: 4),
        //     child: Image.asset(
        //       MarchIcons.chaBot_circle,
        //       width: MarchSize.iconSize * 0.8,
        //       height: MarchSize.iconSize * 0.8,
        //     ),
        //   ),
        Flexible(
          child: BubbleChat(
            colors: isSender
                ? [Colors.blue[50]!, Colors.blue[50]!]
                : [HexColor.fromHex('#DAD3F0'), HexColor.fromHex('#DAD3F0')],
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            text: notifier.conversation[index].msg,
            textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Colors.black87,
              fontSize: MediaQuery.of(context).size.width > 350 ? 14 : 12,
            ),
            isSender: isSender,
            constraints: BoxConstraints(maxWidth: maxWidth),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStamp(
      BuildContext context,
      DateTime dateTime,
      bool isSender,
      Size size,
      ) {
    return Padding(
      padding: EdgeInsets.only(
        left: isSender ? 0 : MarchSize.iconSize * 0.8 + 4,
        right: isSender ? 4 : 0,
        top: 2,
      ),
      child: Text(
        DateFormat('h:mm a').format(dateTime),
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Colors.grey[600],
          fontSize: size.width > 350 ? 10 : 8,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(
      BuildContext context,
      double maxWidth,
      double horizontalPadding,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Padding(
        //   padding: EdgeInsets.only(right: 4, bottom: 4),
        //   child: Image.asset(
        //     MarchIcons.chaBot_circle,
        //     width: MarchSize.iconSize * 0.8,
        //     height: MarchSize.iconSize * 0.8,
        //   ),
        // ),
        Flexible(
          child: BubbleChat(
            colors: [HexColor.fromHex('#DAD3F0'), HexColor.fromHex('#DAD3F0')],
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            text: '',
            loading: true,
            isSender: false,
            constraints: BoxConstraints(maxWidth: maxWidth),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
      BuildContext context,
      ChatNotifier notifier,
      Size size,
      double horizontalPadding,
      PageController pageController,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding/2, vertical: 8),
      decoration: BoxDecoration(
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 80),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: notifier.controller,
                enabled: true,
                autofocus: true,
                maxLines: 3,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                focusNode: notifier.textFieldFocus,
                cursorColor: Colors.blue,
                textCapitalization: TextCapitalization.sentences,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.black87,
                  fontSize: size.width > 350 ? 14 : 12,
                ),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.grey[500],
                    fontSize: size.width > 350 ? 14 : 12,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: notifier.sendMsg,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: HexColor.fromHex('#6650A4'),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                MarchIcons.chat_arrow,
                width: size.width > 350 ? 16 : 12,
                height: size.width > 350 ? 16 : 12,
                color: Colors.white,
              ),
            ),
          ),
          // Uncomment to enable voice bot dialog
          // const SizedBox(width: 6),
          // GestureDetector(
          //   onTap: () {
          //     _showVoiceBotDialog(context, pageController, notifier);
          //   },
          //   child: Container(
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: HexColor.fromHex('#27A3A5'),
          //       shape: BoxShape.circle,
          //     ),
          //     child: Icon(
          //       Icons.multitrack_audio_rounded,
          //       color: Colors.white,
          //       size: size.width > 350 ? 16 : 12,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class GradientBar extends StatelessWidget {
  final double percentage;

  const GradientBar({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final barWidth = size.width * 0.9; // Maximized width for small frame

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 30,
          width: barWidth,
        ),
        Container(
          width: barWidth,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
              stops: [0.25, 0.5, 0.75, 1.0],
            ),
          ),
        ),
        Positioned(
          left: (percentage / 100) * barWidth - 1,
          child: Container(
            width: 2,
            height: 18,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

class ServiceLegend extends StatelessWidget {
  const ServiceLegend();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          LegendItem(
            color: Colors.green,
            text: 'Non-emergency: Stable condition.',
          ),
          SizedBox(height: 6),
          LegendItem(
            color: Colors.orange,
            text: 'Moderately urgent: See a doctor.',
          ),
          SizedBox(height: 6),
          LegendItem(
            color: Colors.red,
            text: 'Highly urgent: Emergency room.',
          ),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Colors.black87,
              fontSize: size.width > 350 ? 12 : 10,
            ),
          ),
        ),
      ],
    );
  }
}