// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'QuestionaryReqModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionaryReqModelAdapter extends TypeAdapter<QuestionaryReqModel> {
  @override
  final int typeId = 50;

  @override
  QuestionaryReqModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionaryReqModel(
      userQuestionary: (fields[0] as List?)?.cast<UserQuestionary>(),
      sessionId: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionaryReqModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.userQuestionary)
      ..writeByte(1)
      ..write(obj.sessionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionaryReqModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserQuestionaryAdapter extends TypeAdapter<UserQuestionary> {
  @override
  final int typeId = 1;

  @override
  UserQuestionary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserQuestionary(
      questionId: fields[0] as String?,
      answer: fields[1] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, UserQuestionary obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.answer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserQuestionaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
