import 'package:flutter/foundation.dart';
import '../injection.dart';
import '../routes/router.dart';
import 'base_client_generator.dart';
import 'base_network_model.dart';
import 'freezed_network/network_error.dart';
import 'network_decoder.dart';
import 'package:dio/dio.dart';
import 'network_creator.dart';
import 'network_options.dart';
import 'network_result.dart';
import 'dart:convert';
import 'dart:io';

mixin NetworkExecuter {
  static Future<NetworkResult<K, NetworkError>>
      execute<T extends BaseNetworkModel, K>({
    required BaseClientGenerator route,
    required T? responseType,
    NetworkOptions? options,
    bool returnJson = false,
  }) async {
    if (kDebugMode) {
      print(route.toString());
    }

      // Check Network Connectivity
      try {
        var response = await NetworkCreator.shared.request(
          route: route,
          options: options,
        );
        if (returnJson) {
          return NetworkResult.success(response as K);
        }
        var data = NetworkDecoder.shared.decode<T, K>(
          response: response,
          responseType: responseType!,
        );
        return NetworkResult.success(data);
      } on DioException catch (dioException) {
        //DioException [bad response]: The request returned an invalid status code of 502.
        // NETWORK ERROR
        dynamic RData;
        final router = getIt<AppRouter>();
        if (dioException.type == DioExceptionType.unknown) {
         // router.push(UnderMaintenanceRoute());
        } else if (dioException.type == DioExceptionType.receiveTimeout ||
            dioException.type == DioExceptionType.connectionTimeout) {
          //router.push(UnderMaintenanceRoute());
        } else if (dioException.response!.statusCode == 502 ||
            dioException.response!.statusCode == 500 ||
            dioException.response!.statusCode == 503 ||
            dioException.response!.statusCode == 504 ||
            dioException.response!.statusCode == 505) {
         // router.push(UnderMaintenanceRoute());
        } else if (dioException.response!.data is Map) {
          RData = dioException.response!.data; // response is already a JSON map
        } else {
          Uint8List compressedBytes =
              base64.decode(dioException.response!.data);
          String sData = utf8.decode(zlib.decode(compressedBytes));
          RData = jsonDecode(sData);
        }
        DioException dioError = DioException(
          requestOptions: dioException.requestOptions,
          response: dioException.response!..data = RData ?? '',
          type: dioException.type,
          error: dioException.error,
        );
        if (kDebugMode) {
          print(
           '$route => ${NetworkError.request(error: dioError)}',
          );
        }
        return NetworkResult.failure(
          NetworkError.request(error: dioException),
        );
      } on TypeError catch (e) {
        // TYPE ERROR
        if (kDebugMode) {
          print(
          '$route => ${NetworkError.type(error: e.toString())}',
          );
        }
        return NetworkResult.failure(
          NetworkError.type(error: e.toString()),
        );
      }

  }
}
