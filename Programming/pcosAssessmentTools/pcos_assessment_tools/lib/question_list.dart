import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcos_assessment_tools/march_style/march_size.dart';

import 'march_style/march_icons.dart';
import 'message_state.dart';

List<Message> questionList = [
  Message(
    id: 'INTRO_ONE',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Text(
      "Hello, I'm here to assist you in completing an assessment for PCOS.\nYour input will aid us in offering better support and recommendations for you and millions of women worldwide.❤️",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
  Message(
    id: 'GET_NAME',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.text,
    widgetContentBuilder: (context) => Text(
      "What can I call you?",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
  Message(
    id: 'IS_HAVE_PCOS',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.option,
    options: [
      Option(text: 'Yes', image: MarchIcons.yes),
      Option(text: 'No', image: MarchIcons.no),
    ],
    widgetContentBuilder: (context) => Text(
      "To start, let me know if you have been diagnosed with PCOS or not.",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
  Message(
    id: 'LET_DIV_MENSTRUAL_CYCLE_PATTERN',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "First, let’s dive into the fascinating world of your menstrual cycle patterns! 🌸",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.icon5, width: 150),
      ],
    ),
  ),
  Message(
    id: 'PAST_6_MONTH_AVG_CYCLE',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.option,
    options: [
      Option(text: 'Between 25 to 35 days', image: MarchIcons.menstrualIrregularities1, id: 'BETWEEN_25_TO_35_DAYS'),
      Option(text: 'Between 36 to 45 days', image: MarchIcons.menstrualIrregularities2, id: 'BETWEEN_36_TO_45_DAYS'),
      Option(text: 'More than 45 days',     image: MarchIcons.menstrualIrregularities3, id: 'MORE_THAN_45_DAYS'),
    ],
    widgetContentBuilder: (context) => Text(
      "Considering the past 6 months, what has been the average length of your menstrual cycle?",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
  Message(
    id: 'PCOS_VARIES_FOR_EVERYONE',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You should know that PCOS varies for everyone; cycles can be 28 days, 30-40 days, or not occur at all!",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.pcos_icon_period_calendar, width: 150),
      ],
    ),
  ),
  Message(
    id: 'IF_EXPERIENCING_HIRSUTISM',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Now, let’s explore if you might be experiencing hirsutism!",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.skinHair, width: 150),
      ],
    ),
  ),
  Message(
    id: 'EXPERIENCING_HIRSUTISM_TYPES',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.multiSelection,
    options: [
      Option(text: 'Upper Lip', image: MarchIcons.hirsutismUpperLips, id: 'HAIR_GROWTH_UPPER_LIP_EXPERIENCING_HIRSUTISM_TYPES'),
      Option(text: 'Chin', image: MarchIcons.hirsutismChin, id: 'HAIR_GROWTH_CHIN_EXPERIENCING_HIRSUTISM_TYPES'),
      Option(text: 'Lower Abdomen', image: MarchIcons.hirsutismUpperAbdomen, id: 'HAIR_GROWTH_LOWER_ABDOMEN_EXPERIENCING_HIRSUTISM_TYPES'),
      Option(text: 'Thighs', image: MarchIcons.hirsutismThighs, id: 'HAIR_GROWTH_THIGHS_EXPERIENCING_HIRSUTISM_TYPES'),
      Option(text: 'None of them', image: MarchIcons.iconWebp5059785, id: 'NONE_EXPERIENCING_HIRSUTISM_TYPES'),
    ],
    widgetContentBuilder: (context) => Text(
      "Check all areas where you’ve observed hair growth. In the next step, you’ll rate the intensity of hair growth in these selected areas.",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
  Message(
    id: 'YOU_APPEAR_HAVE_SIGNIFICANT_HAIR_GROWTH',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.option,
    options: [
      Option(text: 'Yes, I was aware.', image: ''),
      Option(text: 'Tell me more.', image: ''),
    ],
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You appear to have significant hair growth.\n\nDid you know that hirsutism, or unexpected extra hair growth, is quite common in PCOS?",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.iconWebp6634711, width: 150),
      ],
    ),
  ),
  Message(
    id: 'MORE_ABOUT_PCOS_HIRSUTISM',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Approximately 70% to 80% of individuals with PCOS experience hirsutism.",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.pcos_icon_80, width: 150),
      ],
    ),
  ),
  Message(
    id: 'IF_EXPERIENCING_SKIN',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Now, it’s time for a skin and acne check! 🌟",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.icon555, width: 150),
      ],
    ),
  ),
  Message(
    id: 'HOW_MANY_PIMPLES',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.option,
    options: [
      Option(text: '4 or less pimples', image: MarchIcons.acneNoPimple, id: 'FOUR_OR_LESS_PIMPLES'),
      Option(text: '5 or more pimples', image: MarchIcons.acnePimpleDetected, id: 'FIVE_OR_MORE_PIMPLES'),
    ],
    widgetContentBuilder: (context) => Text(
      "How many pimples do you have on any areas, such as your forehead, cheeks, chin, or nose?",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
  Message(
    id: 'DEEPER_ACNE_ON_BODY_PARTS',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Deeper acne on the chin and jawline, flaring up around menstrual cycles, is often linked to PCOS.",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.pcos_icon_acne, width: 150),
      ],
    ),
  ),
  Message(
    id: 'LETS_DIVE_METABOLIC_FACTORS',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let’s dive into your metabolic factors!🎚",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 3),
        Image.asset(MarchIcons.iconWebp9770411, width: 150),
      ],
    ),
  ),
  Message(
    id: 'TO_CALCULATE_BMI_TELL_WEIGHT',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.text,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "To calculate your BMI, tell me your weight",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 10),
        Text(
          "NOTE: Input your weight in kg.",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w300, fontSize: 14, letterSpacing: 0.2,fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 3),
        Image.asset(MarchIcons.icon6, width: 150),
      ],
    ),
  ),
  Message(
    id: 'TO_CALCULATE_BMI_TELL_HEIGHT',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.text,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "and your height",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 10),

        Text(
          "NOTE: Input your height in cm.",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w300, fontSize: 14, letterSpacing: 0.2,fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.height, width: 80),
      ],
    ),
  ),
  Message(
    id: 'ANNOUNCE_BMI',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.option,
    options: [
      Option(text: 'I’ve heard about that.', image: ''),
      Option(text: 'Interesting, I didn’t know!', image: ''),
    ],
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Based on your height and weight, your BMI is: ${'BMI'} \nDid you know that weight challenges are a common issue among individuals with PCOS?",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.weightBmi1, width: 150),
      ],
    ),
  ),
  Message(
    id: 'INFO_ABOUT_BMI',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "In fact, between 38% to 88% of people with PCOS also struggle with maintaining a healthy weight.",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.pcos_icon_up_bmi, width: 150),
      ],
    ),
  ),
  Message(
    id: 'LETS_FIND_OUT_ABOUT_FAMILY_HIS',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "And lastly, let’s find out about your family history!📜",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.iconWebp9056979, width: 150),
      ],
    ),
  ),
  Message(
    id: 'HAVE_CLOSE_RELATIVES_HAVE_PCOS',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.option,
    options: [
      Option(text: 'Yes', image: MarchIcons.yes),
      Option(text: 'No', image: MarchIcons.no),
    ],
    widgetContentBuilder: (context) => Text(
      "Have any of your close relatives, like your mother, sister, or children, been diagnosed with PCOS?",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
  Message(
    id: 'PCOS_MIGHT_RUN_IN_THE_FAMILY',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PCOS might run in the family! If your mom, sister, or aunt has it, your chances of joining the club go up!",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 15),
        Image.asset(MarchIcons.pcos_icon_family_tree, width: 150),
      ],
    ),
  ),
  Message(
    id: 'ANSWERED_ALL_QUESTIONS',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Text(
      "Well done! You have successfully answered all the questions!",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
  Message(
    id: 'EMAIL_ADDRESS',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.text,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Before viewing your personalized results, share your preferred email address to access your full results. We’ll use this email to create your March app account, where you can sign in anytime to view your results, access personalized health suggestions, and stay connected with tools to support your well-being.",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        const SizedBox(height: 10),
        Text(
          "Your Privacy Matters. Your data is 100% secure and used only for sharing valuable resources with you. ",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w200, fontSize: 14, letterSpacing: 0.2,fontStyle: FontStyle.italic),
        ),
      ],
    ),
  ),
  Message(
    id: 'SEE_RESULT',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.nextStep,
    widgetContentBuilder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Submit your responses to view your assessment results and receive additional assistance.",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        MarchSize.smallVerticalSpacer,
        MarchSize.smallVerticalSpacer,
        Text(
          "Remember:",
          style:GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
        ),
        MarchSize.smallVerticalSpacer,

        Text(
          "This questionnaire is a screening tool, not a substitute for professional medical advice, diagnosis, or treatment. Taking proactive steps towards your health is important, and communicating openly with healthcare providers is key to addressing any health concerns. If you have more questions or require help, feel free to discuss the results with your doctor.",
          style: GoogleFonts.arimo(fontWeight: FontWeight.w200, fontSize: 14, letterSpacing: 0.2,fontStyle: FontStyle.italic),
        ),
      ],
    ),
  ),
  Message(id: 'SUBMIT', isSystem: true, isQuestion: true, questionType: QuestionType.none, widgetContentBuilder: (context) => Container()),
];

Message getHairGrowthQuestionById(String id) {
  // List of hair growth questions

  // Find and return the message with the matching id
  return hairGrowthQuestions.firstWhere(
    (message) => message.id == id,
  );
}

List<Message> hairGrowthQuestions = [
  Message(
    id: 'HAIR_GROWTH_CHIN_EXPERIENCING_HIRSUTISM_TYPES',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.option,
    options: [
      Option(text: '', image: MarchIcons.hirsutismArtboard4, id: '1'),
      Option(text: '', image: MarchIcons.hirsutismArtboard5, id: '2'),
      Option(text: '', image: MarchIcons.hirsutismArtboard6, id: '3'),
      Option(text: '', image: MarchIcons.hirsutismArtboard7, id: '4'),
    ],
    widgetContentBuilder: (context) => Text(
      "Rate the hair growth on your chin",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
  Message(
    id: 'HAIR_GROWTH_LOWER_ABDOMEN_EXPERIENCING_HIRSUTISM_TYPES',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.option,
    options: [
      Option(text: '', image: MarchIcons.hirsutismArtboard12, id: '1'),
      Option(text: '', image: MarchIcons.hirsutismArtboard13, id: '2'),
      Option(text: '', image: MarchIcons.hirsutismArtboard14, id: '3'),
      Option(text: '', image: MarchIcons.hirsutismArtboard15, id: '4'),
    ],
    widgetContentBuilder: (context) => Text(
      "Rate the hair growth on your lower abdomen",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
  Message(
    id: 'HAIR_GROWTH_THIGHS_EXPERIENCING_HIRSUTISM_TYPES',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.option,
    options: [
      Option(text: '', image: MarchIcons.hirsutismArtboard8, id: '1'),
      Option(text: '', image: MarchIcons.hirsutismArtboard9, id: '2'),
      Option(text: '', image: MarchIcons.hirsutismArtboard10, id: '3'),
      Option(text: '', image: MarchIcons.hirsutismArtboard11, id: '4'),
    ],
    widgetContentBuilder: (context) => Text(
      "Rate the hair growth on your thighs",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
  Message(
    id: 'HAIR_GROWTH_UPPER_LIP_EXPERIENCING_HIRSUTISM_TYPES',
    isSystem: true,
    isQuestion: true,
    questionType: QuestionType.option,
    options: [
      Option(text: '', image: MarchIcons.hirsutismArtboardOriginal, id: '1'),
      Option(text: '', image: MarchIcons.hirsutismArtboardCopy, id: '2'),
      Option(text: '', image: MarchIcons.hirsutismArtboard2, id: '3'),
      Option(text: '', image: MarchIcons.hirsutismArtboard3, id: '4'),
    ],
    widgetContentBuilder: (context) => Text(
      "Rate the hair growth on your upper lip",
      style: GoogleFonts.arimo(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.2),
    ),
  ),
];
