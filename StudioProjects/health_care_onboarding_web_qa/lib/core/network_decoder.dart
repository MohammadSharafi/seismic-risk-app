import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'base_network_model.dart';

class NetworkDecoder {
  static var shared = NetworkDecoder();

  K decode<T extends BaseNetworkModel, K>(
      {required Response<dynamic> response, required T responseType}) {
    try {
      dynamic RData;
      if (response.data is Map) {
        RData = response.data; // response is already a JSON map
      } else {
        Uint8List compressedBytes = base64.decode(response.data);
        String sData = utf8.decode(zlib.decode(compressedBytes));
        RData = jsonDecode(sData);
      }
      print(RData);

      // parse the JSON data
      if (RData is List) {
        var list = response.data as List;
        var dataList = List<T>.from(
            list.map((item) => responseType.fromJson(item)).toList()) as K;
        return dataList;
      } else {
        var data = responseType.fromJson(RData) as K;
        return data;
      }
    } on TypeError {
      rethrow;
    }
  }
}
