import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import '../../march_style/march_icons.dart';
import '../../march_style/march_size.dart';
import 'Questions.dart';
import 'info.dart';

final surveyData = [


  SurveyPageData(
    questionList: ['Let’s start with your full name.'],
    questionTypeList: [
      QuestionType.textField,
    ],
    descriptionList: [null],
    listOfOptions: [null],
    listOfTags: ['STEP_1'],
    hintList: ['Name'],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: ['When were you born?'],
    descriptionList: [
      'Knowing your age helps us tailor suggestions to where you are in your life. Every journey is unique.'
    ],
    questionTypeList: [
      QuestionType.datePicker,
    ],
    listOfOptions: [null],
    listOfTags: ['STEP_2'],
    hintList: ['Date of Birth'],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: ['Have you been officially diagnosed with endometriosis?'],
    descriptionList: [
      'It’s okay if you’re still figuring things out. We’re here to meet you wherever you are.'
    ],
    questionTypeList: [
      QuestionType.singleChoice,
    ],
    listOfOptions: [
      {'Yes': 'Yes', 'No': 'No'}
    ],
    listOfTags: ['STEP_3'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  ///////////////////
  InfoPage(
      buttonTitle: 'Yes, that’s fine',
      secondButtonTitle: 'No, thank you',
      secondButtonCallBack: () async {
        SharedPreferences prefs =await  SharedPreferences.getInstance();
        prefs.setBool('allow_collect_data',false);
      },
      buttonCallBack: () async {
        SharedPreferences prefs =await  SharedPreferences.getInstance();
        prefs.setBool('allow_collect_data',false);
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: MarchSize.littleGap * 4),
            child: Column(
              children: [
                const Spacer(),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                        fontWeight: FontWeight.w400),
                    children: [
                      const TextSpan(
                          text: 'We want your care plan to truly reflect you.\n'),
                      const TextSpan(
                          text:
                              'We’ll ask a few quick questions, and with your permission, we’ll use your answers to personalize your journey.\n'),
                      const TextSpan(
                          text:
                              'Your trust means everything to us. You can find more details in our '),
                      TextSpan(
                        text: 'Privacy Policy.',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                        // Add gesture recognizer for interactivity
                        recognizer: TapGestureRecognizer()..onTap = () {
                          launchUrl(
                            Uri.parse('https://march.health/privacy-policy/'),
                          );

                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 160),
              ],
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: Image.asset(MarchIcons.doctor_bg,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ],
      )),


  ///////////////////
  SurveyPageData(
    questionList: ['How long have you been diagnosed with endometriosis?'],
    descriptionList: ['This helps us understand your journey better.'],
    questionTypeList: [
      QuestionType.singleChoice,
    ],
    listOfOptions: [
      {
        'Less than 6 months': 'Less than 6 months',
        '6 months–1 year': '6 months–1 year',
        '1–5 years': '1–5 years',
        'More than 5 years': 'More than 5 years'
      }
    ],
    listOfTags: ['STEP_4'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: ['How long have you been experiencing symptoms like pelvic pain or fatigue?'],
    descriptionList: ['Your story matters, and understanding its timeline helps us support you better..'],
    questionTypeList: [
      QuestionType.singleChoice,
    ],
    listOfOptions: [
      {
        'Less than 6 months': 'Less than 6 months',
        '6 months–1 year': '6 months–1 year',
        '1–5 years': '1–5 years',
        'More than 5 years': 'More than 5 years'
      }
    ],
    listOfTags: ['STEP_5'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: ['Which symptoms are weighing on you most right now?'],
    descriptionList: [
      'Select all that apply. It’s okay to share what’s hard, we’re here to help lighten the load.'
    ],
    questionTypeList: [
      QuestionType.multipleChoice,
    ],
    listOfOptions: [
      {
        'Pelvic Pain': 'Pelvic Pain',
        'Heavy or painful periods': 'Heavy or painful periods',
        'Fatigue': 'Fatigue',
        'Bloating': 'Bloating',
        'Pain During Intercourse': 'Pain During Intercourse',
        'Digestive Issues': 'Digestive Issues',
        'Mood swings or depression': 'Mood swings or depression'
      }
    ],
    listOfTags: ['STEP_6'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: [
      'On a scale of 1–10, how intense is your pain on an average day?'
    ],
    descriptionList: [null],
    questionTypeList: [
      QuestionType.slider,
    ],
    listOfOptions: [null],
    listOfTags: ['STEP_7'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: ['How often do these symptoms show up?'],
    descriptionList: [
      'We know symptoms can ebb and flow. This helps us understand your experience.'
    ],
    questionTypeList: [
      QuestionType.singleChoice,
    ],
    listOfOptions: [
      {
        'Daily': 'Daily',
        'Weekly': 'Weekly',
        'Monthly': 'Monthly',
        'Only during my period': 'Only during my period'
      }
    ],
    listOfTags: ['STEP_8'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: [
      'Are you working with a healthcare provider for your endometriosis?'
    ],
    descriptionList: [
      'Whether you are or aren’t, we’re here to complement your care with personalized support.'
    ],
    questionTypeList: [
      QuestionType.singleChoice,
    ],
    listOfOptions: [
      {'Yes': 'Yes', 'No': 'No'}
    ],
    listOfTags: ['STEP_9'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: ['What have you tried to manage your symptoms?'],
    descriptionList: [
      'Select all that apply. Every step you’ve taken counts, and we’ll build on what works for you.'
    ],
    questionTypeList: [
      QuestionType.multipleChoice,
    ],
    listOfOptions: [
      {
        'Hormonal Therapy': 'Hormonal Therapy',
        'Pain medication': 'Pain medication',
        'Surgery': 'Surgery',
        'Physical Therapy': 'Physical Therapy',
        'Dietary Changes': 'Dietary Changes',
        'Acupuncture': 'Acupuncture',
        'None': 'None',
      }
    ],
    listOfTags: ['STEP_10'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: [
      'Are there other health conditions or past surgeries we should know about?'
    ],
    questionTypeList: [
      QuestionType.bigTextField,
    ],
    descriptionList: [null],
    listOfOptions: [null],
    listOfTags: ['STEP_11'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: ['How much do your symptoms affect your daily life?'],
    descriptionList: [
      'It’s okay if some days feel harder. We’re here to help you navigate this.'
    ],
    questionTypeList: [
      QuestionType.singleChoice,
    ],
    listOfOptions: [
      {
        'Not at all': 'Not at all',
        'Slightly': 'Slightly',
        'Moderately': 'Moderately',
        'Severely': 'Severely',
      }
    ],
    listOfTags: ['STEP_12'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: [
      'Do you feel mood changes, anxiety, or depression tied to your symptoms?'
    ],
    descriptionList: [
      'Your emotional well-being matters just as much. We’re here to support all of you.'
    ],
    questionTypeList: [
      QuestionType.singleChoice,
    ],
    listOfOptions: [
      {
        'Never': 'Never',
        'Sometimes': 'Sometimes',
        'Often': 'Often',
        'Always': 'Always',
      }
    ],
    listOfTags: ['STEP_13'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: ['Do you have any dietary preferences or restrictions?'],
    descriptionList: [
      'This helps us suggest nutrition ideas that feel doable and supportive.'
    ],
    questionTypeList: [
      QuestionType.multipleChoice,
    ],
    listOfOptions: [
      {
        'Never': 'Never',
        'Vegan': 'Vegan',
        'Vegetarian': 'Vegetarian',
        'Gluten-Free': 'Gluten-Free',
        'Low-Carb': 'Low-Carb',
      }
    ],
    listOfTags: ['STEP_14'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: ['What are your biggest hopes for this care plan?'],
    descriptionList: [
      'Select up to 3. Your goals guide us to make this journey meaningful for you.'
    ],
    questionTypeList: [
      QuestionType.multipleChoice,
    ],
    listOfOptions: [
      {
        'Ease my pain': 'Ease my pain',
        'Boost My Energy': 'Boost My Energy',
        'Lift My Mood And Mental Well-Being':
            'Lift My Mood And Mental Well-Being',
        'Understand My Symptoms Better': 'Understand My Symptoms Better',
        'Find Non-Invasive Care Options': 'Find Non-Invasive Care Options',
        'Connect With Others Who Get It': 'Connect With Others Who Get It',
      }
    ],
    listOfTags: ['STEP_15'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: ['Where are you located?'],
    descriptionList: [
      'Knowing your country helps us provide resources and support that are most relevant to your region.\n\nPlease note: All online sessions are held in English and follow U.S. time zones, but we will do our best to help you find a time that works for you.'
    ],
    questionTypeList: [
      QuestionType.dropDownWithData,
    ],
    listOfOptions: [
      {
        for (var country in countryNames) country: country,
      },
    ],
    listOfTags: ['STEP_16'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),
  SurveyPageData(
    questionList: ['What is your preferred email address?'],
    descriptionList: [
      'We will use it to securely create your March Health account and guide you through a care journey built just for you. Your trust means everything to us, and your information will always stay safe and protected.'
    ],
    questionTypeList: [
      QuestionType.textField,
    ],
    listOfOptions: [
      null,
    ],
    listOfTags: ['STEP_17'],
    hintList: ['Email'],
    GridItemLists: [null],
    image: [null],
  ),

  ///////////////////
  LoadingPage(
      timer: 5,
      child: Stack(
        children: [
          Column(
            children: [
              const Spacer(),
              Text(
                'We’re analyzing your information to create the best care plan for you.\nThis might take a moment, thank you for your patience.',
                style:
                GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

                Lottie.asset(
                  'assets/plan_page_animation.json',
                  height: 400,
                ),

              const Spacer(),
            ],
          ),
          IgnorePointer(
            ignoring: true,
            child: Image.asset(MarchIcons.doctor_init,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,),
          ),
        ],
      )),
  InfoPage(
      buttonTitle: 'Let’s Get Started',
      buttonCallBack: () {},
      canBack: false,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: MarchSize.littleGap * 4),
            child:  Column(
              children: [
                const Spacer(),
                Text(
                  'Good news!\nYou are eligible for our 30-Day Endometriosis Care Plan.\nWe’re honored to support you with personalized insights and a community that truly understands your journey.',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                      fontWeight: FontWeight.w500), ),
                SizedBox(height: 160),
              ],
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: Image.asset(MarchIcons.hands,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ],
      )),
  ///////////////////
  SurveyPageData(
    questionList: ['What’s your phone number?'],
    descriptionList: [
      'We’ll use it to send important updates about your care plan, like upcoming sessions and check-ins. This step helps us make sure you stay connected and supported throughout your journey.'
    ],
    questionTypeList: [
      QuestionType.phoneNumberField,
    ],
    listOfOptions: [null],
    listOfTags: ['STEP_18'],
    hintList: [''],
    GridItemLists: [null],
    image: [null],
  ),

];

List<String> countryNames =
[
  "Afghanistan",
  "Åland Islands",
  "Albania",
  "Algeria",
  "American Samoa",
  "Andorra",
  "Angola",
  "Anguilla",
  "Antarctica",
  "Antigua and Barbuda",
  "Argentina",
  "Armenia",
  "Aruba",
  "Australia",
  "Austria",
  "Azerbaijan",
  "Bahamas",
  "Bahrain",
  "Bangladesh",
  "Barbados",
  "Belarus",
  "Belgium",
  "Belize",
  "Benin",
  "Bermuda",
  "Bhutan",
  "Bolivia",
  "Bosnia and Herzegovina",
  "Botswana",
  "Bouvet Island",
  "Brazil",
  "British Indian Ocean Territory",
  "Brunei Darussalam",
  "Bulgaria",
  "Burkina Faso",
  "Burundi",
  "Cambodia",
  "Cameroon",
  "Canada",
  "Cape Verde",
  "Cayman Islands",
  "Central African Republic",
  "Chad",
  "Chile",
  "China",
  "Christmas Island",
  "Cocos (Keeling) Islands",
  "Colombia",
  "Comoros",
  "Congo",
  "Congo, The Democratic Republic of the",
  "Cook Islands",
  "Costa Rica",
  "Croatia",
  "Cyprus",
  "Czech Republic",
  "Denmark",
  "Djibouti",
  "Dominica",
  "Dominican Republic",
  "Ecuador",
  "Egypt",
  "El Salvador",
  "Equatorial Guinea",
  "Eritrea",
  "Estonia",
  "Ethiopia",
  "Falkland Islands (Malvinas)",
  "Faroe Islands",
  "Fiji",
  "Finland",
  "France",
  "French Guiana",
  "French Polynesia",
  "French Southern Territories",
  "Gabon",
  "Gambia",
  "Georgia",
  "Germany",
  "Ghana",
  "Gibraltar",
  "Greece",
  "Greenland",
  "Grenada",
  "Guadeloupe",
  "Guam",
  "Guatemala",
  "Guernsey",
  "Guinea",
  "Guinea-Bissau",
  "Guyana",
  "Haiti",
  "Heard Island and Mcdonald Islands",
  "Holy See (Vatican City State)",
  "Honduras",
  "Hong Kong",
  "Hungary",
  "Iceland",
  "India",
  "Indonesia",
  "Iraq",
  "Ireland",
  "Isle of Man",
  "Israel",
  "Italy",
  "Jamaica",
  "Japan",
  "Jerseyanol",
  "Jordan",
  "Kazakhstan",
  "Kenya",
  "Kiribati",
  "Korea, Republic of",
  "Kuwait",
  "Kyrgyzstan",
  "Latvia",
  "Lebanon",
  "Lesotho",
  "Liberia",
  "Libyan Arab Jamahiriya",
  "Liechtenstein",
  "Lithuania",
  "Luxembourg",
  "Macao",
  "Macedonia, The Former Yugoslav Republic of",
  "Madagascar",
  "Malawi",
  "Malaysia",
  "Maldives",
  "Mali",
  "Malta",
  "Marshall Islands",
  "Martinique",
  "Mauritania",
  "Mauritius",
  "Mayotte",
  "Mexico",
  "Micronesia, Federated States of",
  "Moldova, Republic of",
  "Monaco",
  "Mongolia",
  "Montenegro",
  "Montserrat",
  "Morocco",
  "Mozambique",
  "Myanmar",
  "Namibia",
  "Nauru",
  "Nepal",
  "Netherlands",
  "New Caledonia",
  "New Zealand",
  "Nicaragua",
  "Niger",
  "Nigeria",
  "Niue",
  "Norfolk Island",
  "Northern Mariana Islands",
  "Norway",
  "Oman",
  "Pakistan",
  "Palau",
  "Palestinian Territory, Occupied",
  "Panama",
  "Papua New Guinea",
  "Paraguay",
  "Peru",
  "Philippines",
  "Pitcairn",
  "Poland",
  "Portugal",
  "Puerto Rico",
  "Qatar",
  "Reunion",
  "Romania",
  "Russian Federation",
  "Rwanda",
  "Saint Helena",
  "Saint Kitts and Nevis",
  "Saint Lucia",
  "Saint Pierre and Miquelon",
  "Saint Vincent and the Grenadines",
  "Samoa",
  "San Marino",
  "Sao Tome and Principe",
  "Saudi Arabia",
  "Senegal",
  "Serbia",
  "Seychelles",
  "Sierra Leone",
  "Singapore",
  "Slovakia",
  "Slovenia",
  "Solomon Islands",
  "Somalia",
  "South Africa",
  "South Georgia and the South Sandwich Islands",
  "Spain",
  "Sri Lanka",
  "Sudan",
  "Suriname",
  "Svalbard and Jan Mayen",
  "Swaziland",
  "Sweden",
  "Switzerland",
  "Taiwan, Province of China",
  "Tajikistan",
  "Tanzania, United Republic of",
  "Thailand",
  "Timor-Leste",
  "Togo",
  "Tokelau",
  "Tonga",
  "Trinidad and Tobago",
  "Tunisia",
  "Turkey",
  "Turkmenistan",
  "Turks and Caicos Islands",
  "Tuvalu",
  "Uganda",
  "Ukraine",
  "United Arab Emirates",
  "United Kingdom",
  "United States",
  "United States Minor Outlying Islands",
  "Uruguay",
  "Uzbekistan",
  "Vanuatu",
  "Viet Nam",
  "Virgin Islands, British",
  "Virgin Islands, U.S.",
  "Wallis and Futuna",
  "Western Sahara",
  "Yemen",
  "Zambia",
  "Zimbabwe"
];
