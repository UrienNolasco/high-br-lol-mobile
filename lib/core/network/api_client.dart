import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import 'api_exception.dart';

@lazySingleton
class ApiClient {
  ApiClient() : _dio = Dio(_baseOptions) {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        logPrint: (msg) => developer.log(msg.toString(), name: 'HTTP'),
      ));
    }
    _dio.interceptors.add(_errorInterceptor);
  }

  final Dio _dio;

  Dio get dio => _dio;

  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    headers: {'Content-Type': 'application/json'},
  );

  static final InterceptorsWrapper _errorInterceptor = InterceptorsWrapper(
    onError: (DioException error, ErrorInterceptorHandler handler) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw const TimeoutException();
        case DioExceptionType.connectionError:
          throw const NetworkException();
        case DioExceptionType.badResponse:
          _handleBadResponse(error.response!.statusCode!);
        default:
          throw UnknownApiException(error.message ?? 'Erro desconhecido.');
      }
    },
  );

  static Never _handleBadResponse(int statusCode) {
    switch (statusCode) {
      case 404:
        throw const NotFoundException();
      case 429:
        throw const RateLimitedException();
      case >= 500:
        throw const ServerException();
      default:
        throw UnknownApiException('Erro HTTP $statusCode');
    }
  }
}
