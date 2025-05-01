import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
part 'failures.freezed.dart';

@freezed
abstract class ValueFailure<T> with _$ValueFailure<T> {
  const factory ValueFailure.exceedingLength({
    required T failedValue,
    required int max,
  }) = ExceedingLength<T>;
  const factory ValueFailure.empty({
    required T failedValue,
  }) = Empty<T>;
  const factory ValueFailure.multiline({
    required T failedValue,
  }) = Multiline<T>;
  const factory ValueFailure.numberTooLarge({
    required T failedValue,
    required num max,
  }) = NumberTooLarge<T>;
  const factory ValueFailure.listTooLong({
    required T failedValue,
    required int max,
  }) = ListTooLong<T>;
  const factory ValueFailure.invalidEmail({
    required T failedValue,
  }) = InvalidEmail<T>;
  const factory ValueFailure.shortPassword({
    required T failedValue,
  }) = ShortPassword<T>;
  const factory ValueFailure.invalidPhotoUrl({
    required T failedValue,
  }) = InvalidPhotoUrl<T>;
  const factory ValueFailure.invalidUserInput({
    required T failedValue,
  }) = InvalidUserInput<T>;
  const factory ValueFailure.invalidLanguage({
    required T failedValue,
  }) = InvalidLanguage<T>;
  const factory ValueFailure.invalidReferralID({
    required T failedValue,
  }) = InvalidReferralID<T>;
  const factory ValueFailure.invalidStoryPickedFromGallery({
    required T failedValue,
  }) = InvalidStoryPicked<T>;
  const factory ValueFailure.emptyValue({
    required T failedValue,
  }) = EmptyValue<T>;
  const factory ValueFailure.notValidStoryDate({
    required T failedValue,
  }) = NotValidStoryDate<T>;

  const factory ValueFailure.notValidStoryImage({
    required T failedValue,
  }) = NotValidStoryImage<T>;

  const factory ValueFailure.notValidStoryTime({
    required T failedValue,
  }) = NotValidStoryTime<T>;

  const factory ValueFailure.notValidStoryRepeat({
    required T failedValue,
  }) = NotValidStoryRepeat<T>;

  const factory ValueFailure.inValidUserId({
    required T failedValue,
  }) = InValidUserId<T>;

  const factory ValueFailure.noRecords({
    required T failedValue,
  }) = NoRecords<T>;

  const factory ValueFailure.failToDeleteRecord({
    required T failedValue,
  }) = FailToDeleteRecord<T>;
  const factory ValueFailure.failToUpdateRecord({
    required T failedValue,
  }) = FailToUpdateRecord<T>;

  const factory ValueFailure.invalidMultiLineInput({
    required T failedValue,
  }) = InvalidMultiLineInpute<T>;

  const factory ValueFailure.invalidOTP({
    required T failedValue,
  }) = InvalidOTP<T>;
}
