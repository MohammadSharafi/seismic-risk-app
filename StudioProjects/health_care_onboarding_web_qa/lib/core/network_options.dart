class NetworkOptions {

  NetworkOptions({this.onReceiveProgress});
  void Function(int, int)? onReceiveProgress;
}
