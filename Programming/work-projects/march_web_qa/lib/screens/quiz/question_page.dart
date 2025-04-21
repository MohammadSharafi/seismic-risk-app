import 'package:flutter/material.dart';
import 'package:march_web_qa/screens/quiz/result_page.dart';
import 'package:provider/provider.dart';
import '../../controllers/api_handler.dart';
import '../../controllers/question_controller.dart';
import '../../models/Questions.dart';
import '../../models/sendQuestionsResModel.dart';
import 'components/quiz_progress_bar.dart';
import 'components/quiz_question_card.dart';

class QuestionPage extends StatelessWidget {
  const QuestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: ProgressBar(),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: PageView.builder(
                controller: quizProvider.pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => quizProvider.setCurrentIndex(index),
                itemCount: quizProvider.questions.length,
                itemBuilder: (context, index) => QuestionCard(
                  question: quizProvider.questions[index],
                  questionIndex: index,
                ),
              ),
            ),
            _buildNavigationControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls(BuildContext context) {
    final provider = context.watch<QuizProvider>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (provider.currentQuestionIndex > 0)
            _buildButton(
              text: 'Previous',
              onPressed: provider.previousQuestion,
              color: Colors.orangeAccent,
            ),
          const Spacer(),
          _buildButton(
            text: provider.currentQuestionIndex < provider.questions.length - 1 ? 'Next' : 'Submit',
            onPressed: provider.currentQuestionIndex < provider.questions.length - 1
                ? provider.nextQuestion
                : () async {

              final provider = context.watch<QuizProvider>();
              Map<String, dynamic> answers =  generateJsonFromAnswers(provider);

              ApiService apiService = ApiService();

              SendQuestionsResModel response = await apiService.sendQuestion(answers);
              print("Response: ${response.message}");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResultsPage()),
              );
            },
            color: provider.currentQuestionIndex < provider.questions.length - 1 ? Colors.blueAccent : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed, required Color color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Map<String, dynamic> generateJsonFromAnswers(QuizProvider provider) {
    List<Map<String, dynamic>> userQuestionary = [];
    String email = '';

    for (int i = 0; i < provider.selectedAnswers.length; i++) {
      final answer = provider.selectedAnswers[i];
      final question = provider.questions[i];

      if (answer == null) continue;
      if (question.id == '') continue;

      switch (question.type) {
        case QuestionType.multipleChoice:
          userQuestionary.add({
            "stepId": question.id,
            "answer": List<String>.from(answer.map((index) => question.options![index])),
          });
          break;

        case QuestionType.singleChoice:
          if(question.id=='67d3e82d081597b4b305724f'){
            userQuestionary.add({
              "stepId": question.id,
              "answer":(answer==0)?20:((answer==1)?22:((answer==2)?26:(answer==3)?32:36)),
            });
          }
          else if(question.id=='67d3e82d081597b4b3057251' && answer<3){
            userQuestionary.add({
              "stepId": question.id,
              "answer": answer<=1?true:false,
            });
          }




          break;

        case QuestionType.numberField:
          userQuestionary.add({
            "stepId": question.id,
            "answer": answer,
          });
          break;

        case QuestionType.textField:
        // Handle text field answers
          if(question.id=='email'){
            email = answer;
          } else{
            userQuestionary.add({
              "stepId": question.id,
              "answer": answer.toString(),
            });
          }


          break;

        case QuestionType.calendar:
        case QuestionType.periodCalendar:
          userQuestionary.add({
            "stepId": question.id,
            "answer": (answer).toString().split(' ').first, // Assuming answer is already in correct date format
          });
          break;

        case QuestionType.slider:
          break;
      }
    }

    return {
      "userQuestionary": userQuestionary,
      "email": email,
    };
  }

}
