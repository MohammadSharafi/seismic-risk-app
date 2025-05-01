abstract class HiveClientGenerator {
  const HiveClientGenerator();
  String get path;
  String get name;
  String get method;
  dynamic get body;
  int? get sendTimeout => 10000;
  int? get receiveTimeOut => 10000;
}
