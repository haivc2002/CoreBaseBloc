import 'dart:async';
import 'dart:developer' as dev;

import 'package:core_base_bloc/common/global.dart';
import 'package:core_base_bloc/network/network_auth_config.dart';
import 'package:core_base_bloc/network/network_auth_interceptor.dart';
import 'package:dio/dio.dart';

import 'network_dev_logger.dart';
import 'network_exception.dart';

// // Deprecated: Use AuthConfig.tokenStorageKey instead
// @Deprecated('Use AuthConfig.tokenStorageKey instead. Will be removed in future versions.')
// String TOKEN_STRING = kDefaultTokenStorageKey;
//
// // Deprecated: Use AuthConfig.refreshTokenStorageKey instead
// @Deprecated('Use AuthConfig.refreshTokenStorageKey instead. Will be removed in future versions.')
// String REFRESH_TOKEN_STRING = kDefaultRefreshTokenStorageKey;

class NetworkService {
  final Dio _dio;
  final String baseUrl;
  final NetworkAuthConfig authConfig;

  NetworkService({
    required this.baseUrl,
    required this.authConfig,
  }) : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(DevLogger());
    _dio.interceptors.add(NetworkAuthInterceptor(_dio, authConfig));
    _dio.options.validateStatus = (status) => true;
  }

  final Duration _duration = const Duration(seconds: 10);

  Future<Result<T>> _request<T>({
    String endpoint = "",
    required String method,
    Object? data,
    Map<String, dynamic>? query,
    bool withToken = false,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final String token = storageRead<String>(authConfig.tokenStorageKey) ?? '';
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
    Object? data,
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
    Object? data,
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
    Object? data,
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