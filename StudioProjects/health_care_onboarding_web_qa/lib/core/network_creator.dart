import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';
import 'base_client_generator.dart';
import 'network_options.dart';

class NetworkCreator {

  NetworkCreator._internal() {
    _initializeInterceptors();
  }
  static final NetworkCreator shared = NetworkCreator._internal();
  final Dio _client = Dio();
  final CacheOptions _cacheOptions = CacheOptions(
    store: MemCacheStore(),
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(days: 7),
  );

  void _initializeInterceptors() {
    // Add caching interceptor
    _client.interceptors.add(DioCacheInterceptor(options: _cacheOptions));

    // Add retry interceptor
    _client.interceptors.add(RetryInterceptor(
      dio: _client,
      logPrint: print,
      retries: 5,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
        Duration(seconds: 8),
        Duration(seconds: 16),
      ],
      retryEvaluator: (error, handler) {
        // Retry only for timeout errors or network errors
        return error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.unknown;
      },
    ));

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _client.interceptors.add(TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
        ),
      ));
    }
  }

  Future<Response> request({
    required BaseClientGenerator route,
    NetworkOptions? options,
  }) async {


    return _client.fetch(RequestOptions(
      baseUrl: route.baseURL,
      method: route.method,
      path: route.path,
      queryParameters: route.queryParameters,
      data: route.body,
      sendTimeout: Duration(milliseconds: route.sendTimeout!),
      receiveTimeout: Duration(milliseconds: route.receiveTimeOut!),
      connectTimeout: Duration(milliseconds: route.connectTimeout!),
      onReceiveProgress: options?.onReceiveProgress,
      headers: {
        'Authorization': 'Bearer ',
        'x-api-version': '1.2.0',
      },
      validateStatus: (statusCode) =>
          statusCode != null &&
          statusCode >= HttpStatus.ok &&
          statusCode < HttpStatus.multipleChoices,
    ));
  }


}
