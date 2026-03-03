enum QuestionType { multipleChoice, textField, numberField, periodCalendar, singleChoice, calendar, slider }

class Question {
  final String? id;
  final int? answerIndex;
  final String? question;
  final String? hint;
  final String? tag;
  final String? description;
  final List<String>? options;
  final QuestionType type;

  Question( {this.id, this.question, this.hint, this.answerIndex, this.options, required this.type, required this.description,this.tag});
}

const List<Map<String, dynamic>> sample_data = [
  {
    "id": '67d3e82d081597b4b305724b',
    "question": "💬 What can I call you?",
    "description": "✏️ Your first name helps us personalize your experience!",
    "type": "textField",
    "hint": "Your Name",
    "tag": "USER_NAME"
  },

  {
    "id": '67d3e82d081597b4b305724c',
    "question": "Great! Let’s do a quick check-in. 🩸 How is everything going on today?",
    "description": "💡 Select any symptoms you're experiencing right now.",
    "options": [
      'Pelvic pain',
      'Stressed',
      'Bloating',
      'Acne',
      'Pain during intercourse',
      'Difficulty getting pregnant',
      'Tired',
      'Depressed',
      'Mood swings',
      'Trouble focusing',
    ],
    "type": "multipleChoice",
    "tag": "SYMPTOMS_TODAY"

  },

  {
    "id": '',
    "question": "Let’s go a bit deeper!🩸 Do you currently track your menstrual cycle, symptoms, or lifestyle habits?",
    "options": ['Yes', 'No', 'I used to but stopped'],
    "type": "singleChoice",
    "tag":"TRACKING_CYCLE"

  },
  {
    "id": '67d3e82d081597b4b305724e',
    "question": "📆 To personalize your plan, when did your last period start?",
    "description": "🩸 Select the first day of your last period. If you're unsure, choose the closest approximate date.",
    "type": "periodCalendar",
    "tag":"LAST_PERIOD_START"

  },
  {
    "id": '67d3e82d081597b4b305724f',
    "question": "📏How long does your menstrual cycle typically last?",
    "description": "",
    "options": ['Less than 21 days', '21-24 days', '25-28 days', '29-35 days', 'More than 35 days'],
    "type": "singleChoice",
    "tag":"CYCLE_LENGTH"

  },

  {
    "id": '67d3e82d081597b4b3057250',
    "question": "How many days does your period usually last?",
    "description": "",
    "type": "numberField",
    "tag":"PERIOD_LENGTH"

  },
  {
    "id": '67d3e82d081597b4b3057251',
    "question": "📊 Is your cycle regular?",
    "description": " 📌 If you're unsure, no worries! We'll help you track it better. ",
    "options": ['Yes, my cycle is regular', 'Mostly regular, but sometimes varies', 'No, my cycle is irregular', 'I’m not sure'],
    "type": "singleChoice",
    "tag":"CYCLE_REGULARITY"

  },
  {
    "id": '',
    "question": "⚡ How severe is your period pain usually? (Scale: 1-10)",
    "description": "😌 1 - Barely noticeable | 10 - Extremely painful",
    "type": "slider",
    "tag":"PERIOD_PAIN_LEVEL"

  },

  {
    "id": '',
    "question": "😣 Do you experience cramps even when you're not on your period?",
    "options": ['Yes', 'No', 'Sometimes'],
    "type": "singleChoice",
    "tag":"CRAMPS_OUTSIDE_PERIOD"

  },

  {
    "id": '67d3e82d081597b4b3057254',
    "question": "🩺 Let’s get beyond periods, have you been diagnosed with any of the following?",
    "description": "",
    "options": ['Endometriosis', 'PCOS', 'Chronic pelvic pain', 'Infertility', 'Premature ovarian insufficiency', 'Adenomyosis', 'Prefer not to say'],
    "type": "multipleChoice",
    "tag":"DIAGNOSED_CONDITIONS"

  },
  {
    "id": '67d3e82d081597b4b3057255',
    "question": "🎂 When were you born?",
    "description": "📍 Knowing your age helps us tailor recommendations to your unique needs.",
    "type": "calendar",
    "tag":"DATE_OF_BIRTH"

  },
  {
    "id": '',
    "question": "🤰 What about your current life stage? Are you pregnant?",
    "description": " Your journey matters. Whether you’re planning, expecting, or just tracking.",
    "options": ['Yes, I’m pregnant', 'No, I’m not pregnant', 'I’m trying to conceive', 'I’m not sure'],
    "type": "singleChoice",
    "tag":"PREGNANCY_STATUS"

  },

  {
    "id": 'marketing',
    "question": "🏆 What are your main health goals?",
    "options": [
      'Find relief from pain and manage symptoms',
      'Balance hormones and regulate my cycle',
      'Improve fertility and reproductive health',
      'Manage weight and boost energy levels',
      'Support gut health and reduce bloating',
      'Lower stress and improve mental well-being',
      'Get a science-backed diagnosis and expert recommendations',
      'Track my cycle and symptoms more effectively',
      'Personalized supplement & lifestyle guidance'
    ],
    "type": "multipleChoice",
    "tag":"HEALTH_GOALS"

  },
  {
    "id": 'marketing',
    "question": "✨ Almost there! We're generating your personalized plan. Just one more thing. Have you used March Health before? ",
    "options": ['Yes', 'No'],
    "type": "singleChoice",
    "tag":"USED_MARCH_HEALTH"

  },

  {
    "id": 'marketing',
    "question": "🔎 Where did you hear about March Health?",
    "options": [
      'Friend or family recommendation',
      'Social media (Instagram, Facebook, TikTok, etc.)',
      'Online search (Google, Bing, etc.)',
      'Doctor or healthcare provider',
      'Blog or article',
      'Podcast or interview',
      'Advertisement (online or offline)',
      'Event or conference',
      'Influencer or celebrity endorsement',
      'News or media coverage',
      'Website referral (from another website)',
      'Online forum or community',
      'Other'
    ],
    "type": "multipleChoice",
    "tag":"HEARD_ABOUT_MARCH_HEALTH"

  },


  {
    "id": 'marketing',
    "question": "📣 How do you want March Health to support you?",
    "options": [
      'Personalized health recommendations',
      'Symptom tracking and cycle insights',
      'Nutrition & fitness guidance',
      'Stress management & mental well-being',
      'Expert-led support & community'
    ],
    "type": "multipleChoice",
    "tag":"SUPPORT_PREFERENCES"

  },

  {
    "id": '',
    "question": "📧 Your personalized health plan is ready! 🎉 Enter your email to create your March Health account and access your customized insights.",
    "description": "🔒 Your account will be securely created with this email, make sure it's correct!",

    "type": "textField",
    "tag":"USER_EMAIL"

  },



];

List<Question> parseQuestions(List<Map<String, dynamic>> data) {
  return data.map((question) {
    return Question(
      id: question['id'],
      question: question['question'],
      hint: question['hint'],
      tag: question['tag'],
      answerIndex: question['answer_index'],
      options: question['options'] != null ? List<String>.from(question['options']) : null,
      type: QuestionType.values.firstWhere((e) => e.toString() == 'QuestionType.${question['type']}'),
      description: question['description'] ?? '',
    );
  }).toList();
}
