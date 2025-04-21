import 'package:flutter/material.dart';
import '../../../controllers/question_controller.dart';
import '../../../models/Questions.dart';
import 'package:provider/provider.dart';

import 'custom_calendar.dart';


class QuestionCard extends StatelessWidget {
  final Question question;
  final int questionIndex;

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final isCurrentQuestion = provider.currentQuestionIndex == questionIndex;

    return Visibility(
      visible: isCurrentQuestion,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              Text(
                question.question!,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                question.description??'',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w100,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              _buildQuestionContent(context, question, questionIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent(BuildContext context, Question question, int questionIndex) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return Column(
          children: question.options!.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            return _buildOption(
              context,
              entry.value,
              optionIndex,
              context.watch<QuizProvider>().selectedAnswers[questionIndex] as List<int>,
              isMultiSelect: true,
            );
          }).toList(),
        );
      case QuestionType.textField:
        return TextField(
          onChanged: (value) => context.read<QuizProvider>().selectAnswer(value),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        );
      case QuestionType.numberField:
        return TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) => context.read<QuizProvider>().selectAnswer(value),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Your Answer',
          ),
        );
      case QuestionType.periodCalendar:
        return PeriodDateSelector(onSelect: (date){
          context.read<QuizProvider>().selectAnswer(date);

        },);


      case QuestionType.slider:
        return Slider(
          value: (context.watch<QuizProvider>().selectedAnswers[questionIndex] as double?) ?? 0.0,
          min: 0,
          max: 10,
          divisions: 10,
          onChanged: (value) {
            context.read<QuizProvider>().selectAnswer(value);
          },
        );



      case QuestionType.calendar:
        return DateSelector(onSelect: (date){
          context.read<QuizProvider>().selectAnswer(date);

        },);
      case QuestionType.singleChoice:
        return Column(
          children: question.options!.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            return _buildOption(
              context,
              entry.value,
              optionIndex,
              context.watch<QuizProvider>().selectedAnswers[questionIndex],
              isMultiSelect: false,
            );
          }).toList(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOption(
      BuildContext context,
      String text,
      int optionIndex,
      dynamic selectedAnswer, {
        required bool isMultiSelect,
      }) {
    final provider = Provider.of<QuizProvider>(context, listen: false);
    final isSelected = isMultiSelect
        ? (selectedAnswer as List<int>).contains(optionIndex)
        : selectedAnswer == optionIndex;

    return Card(
      color: isSelected ? Colors.red[100] : null,
      child: ListTile(
        title: Text(text),
        leading: isMultiSelect
            ? Checkbox(
          value: isSelected,
          onChanged: (value) {
            provider.toggleMultipleChoiceAnswer(optionIndex);
          },
        )
            : Radio<int>(
          value: optionIndex,
          groupValue: selectedAnswer,
          onChanged: (value) => provider.selectAnswer(value!),
        ),
        onTap: () {
          if (isMultiSelect) {
            provider.toggleMultipleChoiceAnswer(optionIndex);
          } else {
            provider.selectAnswer(optionIndex);
          }
        },
      ),
    );
  }
}

