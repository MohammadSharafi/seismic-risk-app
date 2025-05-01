import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/small_loader.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/step_Indicator.dart';
import 'package:intl/intl.dart';
import '../../march_style/march_icons.dart';
import '../../march_style/march_icons_font.dart';
import '../../march_style/march_size.dart';
import '../../march_style/march_theme.dart';
import '../controllers/custom_text_form_field/custom_text_form_field.dart';
import '../controllers/question_controller.dart';
import '../models/Questions.dart';
import 'PhoneNumberField.dart';
import 'custom_calendar.dart';
import 'dropdown/src/drop_down.dart';
import 'grid_avatar_widget.dart';
import 'package:provider/provider.dart';

import 'march_check_box.dart';
import 'march_drop_down.dart';
import 'march_radio_item.dart';

class QuestionWidget extends StatelessWidget {
  final int pageIndex;
  final int questionIndex;
  final String title;
  final QuestionType type;
  final String? description;
  final String? hint;
  final Map<String, String>? options;
  final String? image;
  final Map<String, GridItemModel> gridItems;

  const QuestionWidget({
    Key? key,
    required this.pageIndex,
    required this.questionIndex,
    required this.title,
    required this.type,
    this.description,
    this.hint,
    this.options,
    required this.gridItems,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final surveyState = Provider.of<SurveyState>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: MarchSize.littleGap * 4),
          Text(
            title,
            style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black),
            textAlign: TextAlign.start,
          ),
          if (description != null && description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                description!,
                textAlign: TextAlign.start,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                  color: Colors.black,
                ),
              ),
            ),
          SizedBox(height: MarchSize.littleGap * 4),
          _buildQuestionInput(context, surveyState),
        ],
      ),
    );
  }

  Widget _buildQuestionInput(BuildContext context, SurveyState surveyState) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Column(
          children: options?.entries.map((entry) {
                final currentAnswer = surveyState.getAnswer(
                        pageIndex, questionIndex) as Set<String>? ??
                    {};
                return Column(
                  children: [
                    Row(
                      children: [
                        MarchCheckBox(
                          value: currentAnswer.contains(entry.key),
                          shouldShowBorder: true,
                          borderColor:
                              marchColorData[MarchColor.purpleExtraDark],
                          uncheckedFillColor: Colors.transparent,
                          checkedFillColor:
                              marchColorData[MarchColor.purpleExtraDark]!,
                          uncheckedIconColor: Colors.transparent,
                          borderRadius: 4,
                          borderWidth: 1,
                          checkBoxSize: 22,
                          onChanged: (val) {
                            final newAnswer = Set<String>.from(currentAnswer);
                            if (val == true) {
                              newAnswer.add(entry.key);
                            } else {
                              newAnswer.remove(entry.key);
                            }
                            surveyState.saveAnswer(
                                pageIndex, questionIndex, newAnswer);
                          },
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.76,
                          child: Text(
                            entry.value,
                            overflow: TextOverflow.clip,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                    color:
                                        marchColorData[MarchColor.mainBlack]),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList() ??
              [],
        );

      case QuestionType.singleChoice:
        return Column(
          children: options?.entries.map((entry) {
                final currentAnswer =
                    surveyState.getAnswer(pageIndex, questionIndex) as String?;
                return MarchRadioItemV2(
                  value: currentAnswer == entry.key,
                  label: entry.value,
                  fontSize: 13,
                  onChanged: (bool newValue) {
                    if (newValue) {
                      surveyState.saveAnswer(
                          pageIndex, questionIndex, entry.key);
                    }
                  },
                );
              }).toList() ??
              [],
        );



      case QuestionType.textField:
        final controller = surveyState.getController(pageIndex, questionIndex);
        return _buildFormField(
            controller: controller,
            onChange: (value) =>
                surveyState.saveAnswer(pageIndex, questionIndex, value),
            isLoading: false,
            inputFormatter: null,
            hintText: hint ?? '');

      case QuestionType.numberField:
        final controller = surveyState.getController(pageIndex, questionIndex);

        return _buildFormField(
            keyboardType: TextInputType.number,
            inputFormatter: [FilteringTextInputFormatter.digitsOnly],
            onChange: (value) =>
                surveyState.saveAnswer(pageIndex, questionIndex, value),
            controller: controller,
            isLoading: false,
            hintText: hint ?? '');

      case QuestionType.slider:
        return QuestionaryStepIndicator(
          onTap: (val) {
            surveyState.saveAnswer(pageIndex, questionIndex, val);
          },
          selectedIndex: surveyState.getAnswer(pageIndex, questionIndex),
        );

      case QuestionType.calendar:
      case QuestionType.periodCalendar:
        return Container(
            decoration: BoxDecoration(
              color: marchColorData[MarchColor.white],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.transparent, width: 1),
            ),
            child: PeriodDateSelector(
              onSelect: (date) {
                surveyState.saveAnswer(pageIndex, questionIndex, date);
              },
              selectedDate: (surveyState.getAnswer(pageIndex, questionIndex) ??
                      DateTime.now()) as DateTime? ??
                  DateTime.now(),
            ));

      case QuestionType.info:
        return Center(
          child: Column(
            children: [
              Text(
                options?['text'] ?? 'No information provided',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (image != null)
                Image.asset(
                  image!,
                  height: 100,
                  width: 100,
                ),
            ],
          ),
        );

      case QuestionType.gridView:
        return GridAvatarWidget<GridItemModel>(
          isMultiTapped: false,
          showGuide: true,
          isLocalImage: true,
          avatarList: gridItems,
          onThreeTap: (index) {},
          onTwoTap: (index) {},
          onTap: (value) {
            final newAnswer = Set<String>.from(value['currentAnswer']);
            if (value['isSelected'] == true) {
              newAnswer.add(value['key']);
            } else {
              newAnswer.remove(value['key']);
            }
            surveyState.saveAnswer(pageIndex, questionIndex, newAnswer);
          },
          surveyState: surveyState,
          pageIndex: pageIndex,
          questionIndex: questionIndex,
        );
      case QuestionType.dropDown:
        return SizedBox(
          height: 50,
          child: MarchDropDown(
            textEditingController: TextEditingController(
                text: surveyState
                    .getAnswer(pageIndex, questionIndex)
                    ?.toString()),
            hint: 'Choose from here',
            context: context,
            showButton: false,
            heightW: 0.35,
            canSearch: false,
            initialIndex:
                surveyState.getAnswer(pageIndex, questionIndex) != null
                    ? int.tryParse(surveyState
                            .getAnswer(pageIndex, questionIndex)
                            .toString()) ??
                        int.tryParse(hint ?? '20')
                    : int.tryParse(hint ?? '20'),
            dropType: DropType.scrollItems,
            items: [for (var i = 1; i <= 99; i += 1) i]
                .map((e) => SelectedListItem(false, '$e', null))
                .toList(),
            searchBackgroundColor: marchColorData[MarchColor.white]!,
            submitButtonText: '',
            searchHintText: '',
            bottomSheetTitle: '',
            suffixIconSvg: MarchIcons.angleSmallDownIcon,
            enableMultipleSelection: false,
            onChange: (value) {
              // Add onChange handler
              surveyState.saveAnswer(pageIndex, questionIndex, value);
            },
          ),
        );
      case QuestionType.datePicker:
        DateTime now = DateTime.now();
        return MarchDropDown(
          heightW: 0.27,
          onChange: (a) {
            if (a.isNotEmpty) {
              try {
                final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
                DateTime date = dateFormat.parse(a);
                print('Parsed Date: $date'); // Output: Parsed Date: 2007-04-29 00:00:00.000
                surveyState.saveAnswer(pageIndex, questionIndex, date);
              } catch (e) {
                print('Error parsing date: $e');
              }
            }
          },
          textEditingController: TextEditingController(
              text: surveyState
                  .getAnswer(pageIndex, questionIndex)
                  ?.toString()
                  .split(' ')[0]),
          hint: 'Date of Birth',
          context: context,
          maxDate: DateTime(now.year - 16, now.month, now.day),
          items: const [],
          showButton: false,
          dropType: DropType.date,
          haveMax: true,
          initialDate: surveyState.getAnswer(pageIndex, questionIndex) ?? DateTime(now.year - 16, now.month, now.day),
          searchBackgroundColor: marchColorData[MarchColor.white]!,
          submitButtonText: '',
          searchHintText: '',
          bottomSheetTitle: '',
          enableMultipleSelection: false,
          suffixIconSvg: MarchIcons.calendarIcon,
          fillColor: Colors.white,
          suffixIcon: Icon(
           Icons.edit_calendar_rounded,
            color: marchColorData[MarchColor.grey],
            size: 14,
          ),
        );
      case QuestionType.singleChoiceWithNone:
        // TODO: Handle this case.
      case QuestionType.multipleChoiceWithNone:
        // TODO: Handle this case.
      case QuestionType.dropDownWithData:
      return SizedBox(
        height: 50,
        child: MarchDropDown(
          textEditingController: TextEditingController(
              text: surveyState
                  .getAnswer(pageIndex, questionIndex)
                  ?.toString()),
          hint: 'Choose from here',
          context: context,
          showButton: false,
          heightW: 0.35,
          canSearch: false,
          initialIndex:0,// surveyState.getAnswer(pageIndex, questionIndex) ?? '',
          dropType: DropType.scrollItems,
          items: options?.keys
              .map((e) => SelectedListItem(false, '$e', null))
              .toList(),
          searchBackgroundColor: marchColorData[MarchColor.white]!,
          submitButtonText: '',
          searchHintText: '',
          bottomSheetTitle: '',
          suffixIconSvg: MarchIcons.angleSmallDownIcon,
          enableMultipleSelection: false,

          onChange: (value) {
            // Add onChange handler
            surveyState.saveAnswer(pageIndex, questionIndex, value);
          },
        ),
      );

      case QuestionType.bigTextField:
        final controller = surveyState.getController(pageIndex, questionIndex);
        return _buildFormFieldMulti(
            controller: controller..addListener((){
              surveyState.saveAnswer(pageIndex, questionIndex, controller.text??'');
            }),
            hintText: hint ?? '');

      case QuestionType.phoneNumberField:
        final controller = surveyState.getController(pageIndex, questionIndex);
        return PhoneNumberInputWidget(
            onPhoneNumberChanged: (phoneNumber) {
              if (phoneNumber.isNotEmpty) {
                controller.text=phoneNumber;
                surveyState.saveAnswer(pageIndex, questionIndex, phoneNumber);

              }
            },
            initialCountry: 'United States', // Optional: set initial country
            initialPhoneNumber: '' //optional set initial phone number
        );
    }
  }

  Widget _buildFormField(
      {required TextEditingController controller,
      List<TextInputFormatter>? inputFormatter,
      TextInputType? keyboardType,
      String? error,
      int? maxLine,
      String? helperText,
      Color? errorColor,
      String? hintText,
      required bool isLoading,
      Function(String a)? onChange}) {
    return CustomTextFormField(
      fillColor: Colors.white,
      helperText: helperText,
      keyboardType: keyboardType,
      onChanged: (a) {
        if (onChange != null) onChange(a);
      },
      errorColor: errorColor,
      maxLine: maxLine??1,
      suffixIconWidget: isLoading
          ? Padding(
              padding: EdgeInsetsDirectional.only(
                  end: MarchSize.smallPaddingAll * 2),
              child: smallLoading(),
            )
          : error == null
              ? null
              : Padding(
                  padding: EdgeInsetsDirectional.only(
                      end: MarchSize.smallPaddingAll * 2+(maxLine??0)),
                  child: Icon(
                    errorColor == marchColorData[MarchColor.redDark]
                        ? Icons.error
                        : Icons.check_circle,
                    color: errorColor,
                  ),
                ),
      controller: controller,
      contentPadding:
          EdgeInsets.symmetric(horizontal: MarchSize.smallPaddingAll+(maxLine??0)),
      labelColorText: marchColorData[MarchColor.extraLightBlack],
      textColor: marchColorData[MarchColor.textLightGray],
      error: error,
      titleColor: marchColorData[MarchColor.primary],
      floatingLabelBehavior: FloatingLabelBehavior.never,
      hintText: hintText,
      inputFormatters: inputFormatter,
    );
  }




  Widget _buildFormFieldMulti(
      {required TextEditingController controller,
        String? hintText}) {
    return CustomTextFormField.multiLine(
      labelText:hintText??'',
      controller:controller,
      lengthOfInput: 150,
    );
  }
}
