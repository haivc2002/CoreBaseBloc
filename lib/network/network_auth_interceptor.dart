import 'dart:async';
import 'dart:developer';
import 'package:core_base_bloc/common/global.dart';
import 'package:core_base_bloc/network/network_auth_config.dart';
import 'package:core_base_bloc/network/network_constants.dart';
import 'package:dio/dio.dart';

class NetworkAuthInterceptor extends Interceptor {
  final Dio dio;
  final NetworkAuthConfig authConfig;

  bool _refreshing = false;
  Completer<void>? _refreshCompleter;
  
  // Tracking retry count để tránh infinite loop
  final Map<String, int> _retryCountMap = {};

  NetworkAuthInterceptor(this.dio, this.authConfig);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.requestOptions.path == authConfig.refreshTokenEndpoint) {
      return handler.next(response);
    }
    if (response.statusCode != kAuthErrorUnauthorized || authConfig.refreshTokenEndpoint.isEmpty) {
      return handler.next(response);
    }
    
    final refreshToken = storageRead<String>(authConfig.refreshTokenStorageKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      log(">>> REFRESH TOKEN NULL - SKIP REFRESH", name: "INTERCEPTOR");
      return handler.next(response);
    }
    
    // Tạo unique key cho request để track retry count
    final requestKey = '${response.requestOptions.method}_${response.requestOptions.path}';
    final retryCount = _retryCountMap[requestKey] ?? 0;
    
    // Kiểm tra số lần retry, nếu vượt quá max thì logout
    if (retryCount >= authConfig.maxRetryCount) {
      log(">>> MAX RETRY REACHED ($retryCount) - LOGOUT", name: "INTERCEPTOR");
      _retryCountMap.remove(requestKey);
      authConfig.onAuthenticationError();
      return handler.next(response);
    }
    
    final err = DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
    
    if (_refreshing) {
      await _refreshCompleter!.future;
      _retryCountMap[requestKey] = retryCount + 1;
      return _retry(err, handler, requestKey);
    }
    
    _refreshing = true;
    _refreshCompleter = Completer();
    try {
      await _refreshToken(refreshToken);
      _refreshCompleter!.complete();
      _retryCountMap[requestKey] = retryCount + 1;
      return _retry(err, handler, requestKey);
    } catch (e) {
      if (!_refreshCompleter!.isCompleted) {
        _refreshCompleter!.completeError(e);
      }
      log(">>> REFRESH FAILED - LOGOUT USER", name: "INTERCEPTOR");
      _retryCountMap.remove(requestKey);
      // Gọi callback để logout user thay vì chỉ log
      authConfig.onAuthenticationError();
      return handler.next(response);
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _refreshToken(String refreshToken) async {
    log(">>> REFRESH TOKEN", name: "INTERCEPTOR");
    final requestBody = authConfig.buildRefreshTokenBody;
    final res = await dio.post(
      authConfig.refreshTokenEndpoint,
      data: requestBody,
      options: Options(headers: {"Authorization": null}),
    );
    if (res.statusCode != kHttpStatusOk) {
      authConfig.onAuthenticationError();
      throw Exception("Refresh token failed with status: ${res.statusCode}");
    }
    final data = res.data["data"];
    final accessToken = data[authConfig.tokenResponseKey];
    final newRefreshToken = data[authConfig.refreshTokenResponseKey];
    if (accessToken == null || newRefreshToken == null) {
      throw Exception("Token parse failed: accessToken=$accessToken, refreshToken=$newRefreshToken");
    }
    storageWrite(authConfig.tokenStorageKey, accessToken);
    storageWrite(authConfig.refreshTokenStorageKey, newRefreshToken);
    dio.options.headers["Authorization"] = "Bearer $accessToken";
    log(">>> NEW TOKEN SAVED", name: "INTERCEPTOR");
  }


  Future<void> _retry(DioException err, ResponseInterceptorHandler handler, String requestKey) async {
    log(">>> RETRY ORIGINAL REQUEST", name: "INTERCEPTOR");
    final request = err.requestOptions;
    final newToken = storageRead<String>(authConfig.tokenStorageKey);
    request.headers["Authorization"] = "Bearer $newToken";
    final res = await dio.request(
      request.path,
      options: Options(
        method: request.method,
        headers: request.headers,
      ),
      data: request.data,
      queryParameters: request.queryParameters,
    );

    // Nếu request thành công, xóa retry count
    if (res.statusCode == kHttpStatusOk) {
      _retryCountMap.remove(requestKey);
      log(">>> RETRY SUCCESS - CLEARED RETRY COUNT", name: "INTERCEPTOR");
    }

    return handler.resolve(res);
  }
}



