abstract class BaseClientGenerator {
  const BaseClientGenerator();
  String get path;
  String get method;
  String get baseURL;
  bool get isOneTimeToken;
  bool get isRefreshToken;
  dynamic get body;
  Map<String, dynamic>? get queryParameters;
  Map<String, dynamic> get header;
  int? get sendTimeout => 5000;
  int? get connectTimeout => 5000;
  int? get receiveTimeOut => 45000;
}
