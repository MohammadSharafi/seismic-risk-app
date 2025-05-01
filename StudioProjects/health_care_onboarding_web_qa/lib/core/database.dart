import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'failures.dart';

@immutable
abstract class Database<T> {
  const Database();
  Box get box;
  Either<ValueFailure<T>, T> get(String id);
  Either<ValueFailure<String>, List<T>> getAll<T>();
  Future delete(String id);
  Future deleteAll(List<String> keys);
  Future addUpdate<T>(String id, T item);
}
