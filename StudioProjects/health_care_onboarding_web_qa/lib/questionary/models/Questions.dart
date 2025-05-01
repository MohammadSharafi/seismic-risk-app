// Enum for question types
import '../components/grid_avatar_widget.dart';

enum QuestionType {
  multipleChoice,
  textField,
  bigTextField,
  numberField,
  periodCalendar,
  phoneNumberField,
  singleChoice,
  calendar,
  slider,
  info,
  gridView,
  dropDown,
  datePicker,
  singleChoiceWithNone,
  multipleChoiceWithNone,
  dropDownWithData,
}

// Data model for a survey page
class SurveyPageData {
  final List<String> questionList;
  final List<QuestionType> questionTypeList;
  final List<String?> descriptionList;
  final List<Map<String, String>?> listOfOptions;
  final List<Map<String, GridItemModel>?> GridItemLists;
  final List<String> listOfTags;
  final List<String?> hintList;
  final List<String?> image;

  SurveyPageData( {
    required this.questionList,
    required this.questionTypeList,
    required this.descriptionList,
    required this.listOfOptions,
    required this.listOfTags,
    required this.hintList,
    required this.GridItemLists,
    required this.image,
  });
}
