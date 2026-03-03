import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pcos_assessment_tools/march_style/march_size.dart';
import 'package:pcos_assessment_tools/question_list.dart';
import 'package:pcos_assessment_tools/result_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'bubble_chat.dart';
import 'challenge_res_model.dart';
import 'chat_btn.dart';
import 'march_style/hexColor.dart';
import 'march_style/march_icons.dart';
import 'message_provider.dart';
import 'message_state.dart';

class ChatPage extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();

  late Size size;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: MarchSize.littleGap * 3, horizontal: MarchSize.littleGap * 8),
                    decoration: BoxDecoration(color: HexColor.fromHex('#F6CEEC'), borderRadius: const BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'March PCOS Self-Assessment',
                              style: GoogleFonts.arimo(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(height: MarchSize.littleGap),
                            Text(
                              'Take the Quiz. Empower Yourself.',
                              style: GoogleFonts.arimo(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        CircularPercentIndicator(
                          radius: 22.0,
                          // Size of the circle
                          lineWidth: 4.0,
                          // Width of the progress bar line
                          percent: (chatProvider.currentQuestionIndex / questionList.length),
                          // The progress percentage (0.0 to 1.0)
                          center: Text(
                            "${((chatProvider.currentQuestionIndex / questionList.length) * 100).round()}%", // Text to display in the center
                            style: GoogleFonts.arimo(fontSize: 14.0, fontWeight: FontWeight.w500),
                          ),
                          progressColor: HexColor.fromHex('#141313'),
                          // Color of the progress line
                          backgroundColor: HexColor.fromHex('#9C8294'),
                          circularStrokeCap: CircularStrokeCap.round,
                          // Rounded edges of the progress bar
                          animation: true, // Enable animation for progress
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        // Scroll to the end when a new message is added
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              0,
                              duration: Duration(milliseconds: 1300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(vertical: MarchSize.littleGap * 3, horizontal: MarchSize.littleGap * 4),
                          decoration: BoxDecoration(color: HexColor.fromHex('#FCF6F9'), borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8), bottomLeft: Radius.circular(16))),
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: (chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].isQuestion && chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].questionType == QuestionType.text) ? 160 : 10),
                                child: ListView.builder(
                                  itemCount: chatProvider.messages.length,
                                  controller: _scrollController,
                                  reverse: true, // This ensures messages start from the bottom.
                                  itemBuilder: (context, index) {
                                    // Reverse the index to maintain logical message order
                                    final reverseIndex = chatProvider.messages.length - 1 - index;
                                    final message = chatProvider.messages[reverseIndex];

                                    return _buildMessageItem(context, chatProvider, message);
                                  },
                                ),
                              ),
                              if (chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].isQuestion && chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].questionType == QuestionType.text) Positioned(bottom: 45, left: 0, right: 0, child: _buildTextQuestion(context, chatProvider)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: ElTooltip(
                  content: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black), // Default text style
                      children: [
                        const TextSpan(
                          text:
                          'Your data is completely secure with us.\n Your privacy is our priority.\n Want to learn more? Check out our privacy policy.',
                        ),
                        TextSpan(
                          text: 'HERE.',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              html.window.open("https://march.health/privacy-policy/", "_blank");

                            },
                        ),
                      ],
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      MarchIcons.shield,
                      width: 40, // Adjust size as needed
                      height: 40,
                    ),
                  ),
                ),
              )

            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, ChatProvider chatProvider, Message message) {
    final isUserMessage = !message.isSystem;
    final isLastMessage = chatProvider.messages.indexOf(message) == chatProvider.messages.length - 1;
    final isActive = chatProvider.messages.where((data) => data.isQuestion).toList().indexOf(chatProvider.messages.firstWhere((data) => data == message)) == chatProvider.targetQuestionIndex;


    if(message.questionType==QuestionType.loading) {
      return BubbleChat(
        colors: [
          HexColor.fromHex('#E5E0E3'),
          HexColor.fromHex('#E5E0E3'),
        ],
        widget: Container(//assets/Animation - 1733929380411.json
          child: Lottie.asset('assets/Animation - 1733929380411.json',height: 40),
        ),
        answer: (message.isQuestion && !message.isAnswered) ? _buildQuestionContent(context, chatProvider, message) : Container(),
        showEdit: message.questionType!=QuestionType.text,
        onTap: (){
        },
        isSender: false,
      );
    }


    if (message.id == 'SEE_RESULT') {
      message=  message.copyWith(
        widgetContentBuilder:(context)=> Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Submit your responses to view your assessment results and receive additional assistance.\n",
              style: GoogleFonts.arimo(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 0.2),
            ),
            MarchSize.smallVerticalSpacer,
            MarchSize.smallVerticalSpacer,
            Text(
              "Remember:\n",
              style:GoogleFonts.arimo(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 0.2),
            ),
            MarchSize.smallVerticalSpacer,

            Text(
              "This questionnaire is a screening tool, not a substitute for professional medical advice, diagnosis, or treatment. Taking proactive steps towards your health is important, and communicating openly with healthcare providers is key to addressing any health concerns. If you have more questions or require help, feel free to discuss the results with your doctor.",
              style: GoogleFonts.arimo(fontWeight: FontWeight.w200, fontSize: 18, letterSpacing: 0.2,fontStyle: FontStyle.italic),
            ),

          ],
        ),
      );


    }
    if (message.id == 'ANNOUNCE_BMI') {
      message = message.copyWith(
        widgetContentBuilder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Based on your height and weight, your BMI is: ${chatProvider.calculateBMI()} \nDid you know that weight challenges are a common issue among individuals with PCOS?",
              style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2),
            ),
            Image.asset(
                chatProvider.bmi < 25
                    ? MarchIcons.weightBmi1
                    : chatProvider.bmi >= 30
                        ? MarchIcons.weightBmi3
                        : MarchIcons.weightBmi2,
                width: 190),
          ],
        ),
      );
    }
    if (message.id == 'ANSWERED_ALL_QUESTIONS') {
      message = message.copyWith(
        widgetContentBuilder: (context) => Text(
          "Well done ${chatProvider.name}! You have successfully answered all the questions!",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2),
        ),
      );
    }
    if (message.id == 'YOU_APPEAR_HAVE_SIGNIFICANT_HAIR_GROWTH') {
      message = message.copyWith(
        widgetContentBuilder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              chatProvider.calculateHairGrowth()==-1?'You appear to have low hair growth':chatProvider.calculateHairGrowth()==0?'You appear to have moderate hair growth':'You appear to have significant hair growth'+
              "\n\nDid you know that hirsutism, or unexpected extra hair growth, is quite common in PCOS?",
              style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2),
            ),
            const SizedBox(height: 15),
            Image.asset(chatProvider.calculateHairGrowth()==1?MarchIcons.icon55:MarchIcons.iconWebp6634711, width: 150),
          ],
        ),
      );
    }
    return Column(
      children: [
        BubbleChat(
          colors: isUserMessage
              ? [
                  HexColor.fromHex('#F6CEEC'),
                  HexColor.fromHex('#F6CEEC'),
                ]
              : [
                  HexColor.fromHex('#E5E0E3'),
                  HexColor.fromHex('#E5E0E3'),
                ],
          showEdit: !hairGrowthQuestions.map((data) {
                return data.id;
              }).contains(message.id.replaceFirst('user_', '')) &&
              message.questionType != QuestionType.text,
          widget: Container(
            padding: EdgeInsets.all(MarchSize.littleGap * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                message.widgetContentBuilder?.call(context) ?? SizedBox.shrink(),
              ],
            ),
          ),
          answer: (message.isQuestion && !message.isAnswered) ? _buildQuestionContent(context, chatProvider, message) : Container(),
          onTap: () {
            if (isUserMessage) {
              chatProvider.editResponse(message.id.replaceFirst('user_', ''));
            }
          },
          isSender: isUserMessage,
        ),
        if ((isLastMessage || isActive) && (message.questionType == QuestionType.nextStep || message.questionType == QuestionType.multiSelection))
          Row(
            children: [
              // Only show the Next button if message.options is not empty (for multiSelection questions)
              if (message.questionType == QuestionType.multiSelection &&
                      (message.options ?? [])
                          .where((data) {
                            return data.isSelected;
                          })
                          .toList()
                          .isNotEmpty ??
                  false)
                Container(
                  margin: EdgeInsets.only(left: MarchSize.littleGap * 5 + 35),
                  child: marchButton(
                    onPressed: () {
                      if ((message.options ?? [])
                          .where((data) {
                            return data.isSelected;
                          })
                          .toList()
                          .isNotEmpty) {
                        chatProvider.updateUserResponse(message.id, message.copyWith(options: message.options));
                      }
                    },
                    text: 'Next',
                  ),
                ),
              // Handle nextStep question type
              if (message.questionType == QuestionType.nextStep)
                Container(
                  margin: EdgeInsets.only(left: MarchSize.littleGap * 5 + 35),
                  child: marchButton(
                    onPressed: () {
                      chatProvider.addTarget();

                      chatProvider.nextQuestion();
                    },
                    text: 'Next',
                  ),
                ),
              Spacer(),
            ],
          ),
        if(message.id == 'SEE_RESULT')
          Column(
            children: [
              SizedBox(height:MarchSize.littleGap*3 ,),
              Row(
                children: [
                  Spacer(),
                  chatProvider.isLoading
                      ? CircularProgressIndicator() // Show loading indicator while waiting
                      : marchButton(
                    onPressed: () async {
                        chatProvider.isLoading = true;

                      try {
                        ChallengeResModel? response =
                        await chatProvider.sendChallengeRequest();
                        if (response != null) {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ResultPage(
                                response: response,
                                email:chatProvider.email,
                                challengeModel: chatProvider.getReqModel(),
                              ),
                            ),
                          );

                          chatProvider.resetChallengeModel();

                        }
                      } catch (e) {
                        // Handle error (e.g., show a snackbar or alert)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to send challenge request')),
                        );
                      } finally {

                        chatProvider.isLoading = false;

                      }
                    },
                    text: 'Submit',
                  ),
                  Spacer(),
                ],
              ),
            ],
          )

      ],
    );
  }

  Widget _buildQuestionContent(BuildContext context, ChatProvider chatProvider, Message message) {
    switch (message.questionType) {
      case QuestionType.text:
        return SizedBox.shrink();
      case QuestionType.option:
        return _buildOptionQuestion(context, chatProvider, message);
      case QuestionType.multiSelection:
        return _buildMultiSelectionQuestion(context, chatProvider, message);
      case QuestionType.numberSelector:
        return _buildNumberSelector(context, chatProvider, message);
      case QuestionType.slider:
        return _buildSliderQuestion(context, chatProvider, message);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildTextQuestion(BuildContext context, ChatProvider chatProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent, // Background color of the text field
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: HexColor.fromHex('#C75A77'), // Border color
                  width: 1.0, // Thin border thickness
                ),
              ),
              child: TextField(
                controller: _textController,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    if(chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].id=='EMAIL_ADDRESS'){
                      final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if(regex.hasMatch(_textController.text)){
                        chatProvider.updateUserResponse(
                          chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].id,
                          chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].copyWith(userResponse: _textController.text),
                        );
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a valid email address.'),
                            backgroundColor: Colors.red.shade300,
                          ),
                        );
                      }

                    }
                    else {
                      chatProvider.updateUserResponse(
                        chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].id,
                        chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].copyWith(userResponse: _textController.text),
                      );
                    }
                    _textController.clear();
                  }
                },
                keyboardType: (chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].id == 'TO_CALCULATE_BMI_TELL_HEIGHT' || chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].id == 'TO_CALCULATE_BMI_TELL_WEIGHT')
                    ? TextInputType.number
                    : (chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].id == 'EMAIL_ADDRESS')
                        ? TextInputType.emailAddress
                        : TextInputType.name,
                inputFormatters: (chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].id == 'TO_CALCULATE_BMI_TELL_HEIGHT' || chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].id == 'TO_CALCULATE_BMI_TELL_WEIGHT') ? [FilteringTextInputFormatter.digitsOnly] : [],
                decoration: InputDecoration(
                  hintText: 'Please enter your response',
                  hintStyle: GoogleFonts.arimo(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0), // Radius of 4 for border
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 15.0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: HexColor.fromHex('#F6CEEC'),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.black), // Send icon
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  if(chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].id=='EMAIL_ADDRESS'){
                    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if(regex.hasMatch(_textController.text)){
                      chatProvider.updateUserResponse(
                        chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].id,
                        chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].copyWith(userResponse: _textController.text),
                      );
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a valid email address.'),
                          backgroundColor: Colors.red.shade300,
                        ),
                      );
                    }

                  }
                  else {
                    chatProvider.updateUserResponse(
                      chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].id,
                      chatProvider.messages[chatProvider.currentMessageIndexInUi + chatProvider.userResponses.length].copyWith(userResponse: _textController.text),
                    );
                  }
                  _textController.clear();
                }

              },
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              iconSize: 24, // Adjust size as needed
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionQuestion(BuildContext context, ChatProvider chatProvider, Message message) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: MarchSize.littleGap * 3),
          child: Column(
            children: [
              Row(
                children: (message.options ?? []).map((option) {
                  bool isSelected = chatProvider.userResponses[message.id]?.userResponse == option.text;
                  int index = (message.options?.indexOf(option)??0)+1;

                  return Container(
                    margin: EdgeInsets.only(right: MarchSize.littleGap * 3, top: MarchSize.littleGap * 3),
                    child: GestureDetector(
                      onTap: () => chatProvider.updateUserResponse(message.id, message.copyWith(userResponse: option.text, options: [option])),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              //color: isSelected ? HexColor.fromHex('#C75A77') : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: HexColor.fromHex('#C75A77'), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                (option.image ?? '').isNotEmpty
                                    ? Image.asset(
                                        option.image ?? '',
                                        height: size.height * 0.15,
                                      )
                                    : Container(),
                                Container(
                                  width: 200,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        activeColor: HexColor.fromHex('#C75A77'),
                                        value: isSelected,
                                        onChanged: (bool? newValue) {
                                          chatProvider.updateUserResponse(
                                            message.id,
                                            message.copyWith(userResponse: option.text, options: [option]),
                                          );
                                        },
                                      ),
                                      Text(
                                        option.text,
                                        style: GoogleFonts.arimo(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: MarchSize.littleGap*2,),
                          (hairGrowthQuestions.any((data) => data.id == message.id))? Container(
                            padding: EdgeInsets.symmetric(horizontal: MarchSize.littleGap * 2),
                            child: Text(
                              '$index',
                              style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2),
                            ),
                          ):Container(),
                          SizedBox(height: MarchSize.littleGap*1,),
                          (hairGrowthQuestions.any((data) => data.id == message.id))? Container(
                            padding: EdgeInsets.symmetric(horizontal: MarchSize.littleGap * 2),
                            child: Text(
                              index==1? 'No Excess Hair Growth':index==4?'Severe Hair Growth':'',
                              style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2),
                            ),
                          ):Container(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectionQuestion(BuildContext context, ChatProvider chatProvider, Message message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: MarchSize.littleGap * 3),
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: true,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 8.0,
          children: (message.options ?? []).map((option) {
            int index = (message.options ?? []).indexOf(option);
            return GestureDetector(
              onTap: () {
                if ((option.id ?? '').contains("NONE")) {
                  // If the selected option's ID contains "NONE", unselect all other options
                  for (int i = 0; i < message.options!.length; i++) {
                    message.options![i] = message.options![i].copyWith(isSelected: false);
                  }
                  // Select only the "NONE" option
                  message.options?[index] = option.copyWith(isSelected: true);
                } else {
                  // Unselect the "NONE" option if any other option is selected
                  for (int i = 0; i < message.options!.length; i++) {
                    if ((message.options![i].id ?? "").contains("NONE")) {
                      message.options![i] = message.options![i].copyWith(isSelected: false);
                    }
                  }
                  // Toggle the selected state of the clicked option
                  message.options?[index] = option.copyWith(isSelected: !option.isSelected);
                }

                chatProvider.update();
              },
              child: Container(
                decoration: BoxDecoration(
                  //color: (message.options?[index]?.isSelected ?? false) ? HexColor.fromHex('#C75A77') : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: HexColor.fromHex('#C75A77'), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (option.image ?? '').isNotEmpty
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Image.asset(
                              option.image ?? '',
                              height: size.height * 0.1,
                            ),
                          )
                        : Container(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: message.options?[index]?.isSelected ?? false,
                          onChanged: (bool? value) {
                            if (value != null) {
                              if ((option.id ?? '').contains("NONE")) {
                                for (int i = 0; i < message.options!.length; i++) {
                                  message.options![i] = message.options![i].copyWith(isSelected: false);
                                }
                                message.options?[index] = option.copyWith(isSelected: value);
                              } else {
                                for (int i = 0; i < message.options!.length; i++) {
                                  if ((message.options![i].id ?? "").contains("NONE")) {
                                    message.options![i] = message.options![i].copyWith(isSelected: false);
                                  }
                                }
                                message.options?[index] = option.copyWith(isSelected: value);
                              }
                              chatProvider.update();
                            }
                          },
                          activeColor: HexColor.fromHex('#C75A77'),
                        ),
                        Text(
                          message.options?[index].text ?? '',
                          style: GoogleFonts.arimo(
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            color: //(message.options?[index]?.isSelected ?? false) ? Colors.white :
                                Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNumberSelector(BuildContext context, ChatProvider chatProvider, Message message) {
    return Wrap(
      spacing: 8.0,
      children: List.generate(10, (index) {
        int number = index + 1;
        bool isSelected = chatProvider.userResponses[message.id]?.userResponse == number.toString();

        return GestureDetector(
          onTap: () => chatProvider.updateUserResponse(message.id, message.copyWith(userResponse: number.toString())),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.blueAccent : Colors.grey[200],
              border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: Text(
              '$number',
              style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSliderQuestion(BuildContext context, ChatProvider chatProvider, Message message) {
    double sliderValue = double.tryParse(chatProvider.userResponses[message.id]?.userResponse ?? '0') ?? 0;

    return Column(
      children: [
        Slider(
          value: sliderValue,
          min: 0,
          max: 100,
          divisions: 10,
          onChanged: (value) {
            chatProvider.updateUserResponse(message.id, message.copyWith(userResponse: value.toStringAsFixed(1)));
          },
        ),
        Text(
          'Value: ${sliderValue.toStringAsFixed(1)}',
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2),
        ),
      ],
    );
  }

  Widget _buildAnsweredContent(BuildContext context, ChatProvider chatProvider, Message message) {
    String? userResponse = chatProvider.userResponses[message.id]?.userResponse;

    if (userResponse == null) {
      // Return an empty container or any placeholder if no answer is provided yet
      return Container();
    }

    switch (message.questionType) {
      case QuestionType.text:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            userResponse,
            style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2),
          ),
        );
      case QuestionType.option:
        // Handle displaying the selected option
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'You selected: $userResponse',
            style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2),
          ),
        );
      case QuestionType.multiSelection:
        // Handle multiple selections (assuming it's stored as comma-separated values)
        // List<String> selectedOptions = userResponse.split(',');
        return Container();
      case QuestionType.slider:
        // Display the selected value from a slider
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'You selected value: $userResponse',
            style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2),
          ),
        );
      case QuestionType.numberSelector:
        // Display the selected number (from a number selector)
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'You selected: $userResponse',
            style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2),
          ),
        );
      default:
        // Handle any unknown type, you can show a fallback or an error message
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Answer not available',
            style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 0.2, color: Colors.red),
          ),
        );
    }
  }
}
