import 'dart:async';
import 'dart:developer' as dev;

import 'package:core_base_bloc/common/global.dart';
import 'package:core_base_bloc/network/auth_interceptor.dart';
import 'package:dio/dio.dart';

import 'dev_logger.dart';
import 'exception.dart';

String TOKEN_STRING = "TOKEN_STRING";
String REFRESH_TOKEN_STRING = "REFRESH_TOKEN_STRING";

class ServiceNetwork {
  final Dio _dio;
  final String baseUrl;
  ServiceNetwork({required this.baseUrl}) : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(DevLogger());
    _dio.interceptors.add(AuthInterceptor(_dio));
    _dio.options.validateStatus = (status) => true;
  }

  final Duration _duration = const Duration(seconds: 10);

  Future<Result<T>> _request<T>({
    String endpoint = "",
    required String method,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    bool withToken = false,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final String token = storageRead<String>(TOKEN_STRING) ?? '';
      if(withToken) dev.log(token, name: "WITH TOKEN");

      final response = await _dio.request(
        endpoint,
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          headers: withToken ? { "Authorization": "Bearer $token" } : {},
        ),
      ).timeout(_duration);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (dioException) {
      if(dioException.type == DioExceptionType.connectionError) {
        return Failure<T>(Result.isNotConnect);
        } else {
          return Failure<T>(dioException.response?.statusCode ?? Result.isDueServer);
        }
    } on TimeoutException {
      return Failure<T>(Result.isTimeOut);
    } catch (e, stackTrace) {
      dev.log(e.toString(), name: "isError", error: e, stackTrace: stackTrace);
      return Failure<T>(Result.isError);
    }
  }

  Future<Result<T>> get<T>({
    String endpoint = "",
    Map<String, dynamic>? query,
    required T Function(dynamic) fromJson,
    bool withToken = false,
  }) {
    return _request<T>(
      endpoint: endpoint,
      method: 'GET',
      query: query,
      fromJson: fromJson,
      withToken: withToken,
    );
  }

  Future<Result<T>> post<T>({
    String endpoint = "",
    Map<String, dynamic>? data,
    required T Function(dynamic) fromJson,
    bool withToken = false,
  }) {
    return _request<T>(
      endpoint: endpoint,
      method: 'POST',
      data: data,
      fromJson: fromJson,
      withToken: withToken,
    );
  }

  Future<Result<T>> put<T>({
    String endpoint = "",
    Map<String, dynamic>? data,
    required T Function(dynamic) fromJson,
    bool withToken = false,
  }) {
    return _request<T>(
      endpoint: endpoint,
      method: 'PUT',
      data: data,
      fromJson: fromJson,
      withToken: withToken,
    );
  }

  Future<Result<T>> delete<T>({
    String endpoint = "",
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
    required T Function(dynamic) fromJson,
    bool withToken = false,
  }) {
    return _request<T>(
      endpoint: endpoint,
      method: 'DELETE',
      query: query,
      data: data,
      fromJson: fromJson,
      withToken: withToken,
    );
  }

  Result<T> _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    if (response.statusCode == 200) {
      if (fromJson == null) return Success<T>(null as T);
      final data = response.data;
      return Success(fromJson(data));
    } else {
      return Failure<T>(response.statusCode ?? Result.isHttp);
    }
  }
}