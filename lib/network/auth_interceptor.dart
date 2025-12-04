import 'dart:async';
import 'dart:developer';

import 'package:core_base_bloc/common/global.dart';
import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:dio/dio.dart';

// class AuthInterceptor extends Interceptor {
//   final Dio dio;
//   bool _refreshing = false;
//   Completer<void>? _refreshCompleter;
//
//   AuthInterceptor(this.dio);
//
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode != 401) {
//       return handler.next(err);
//     } else {
//       BaseXController.onError();
//       log("onError auth", name: "AUTH");
//     }
//
//     if (_refreshing) {
//       await _refreshCompleter!.future;
//       return _retry(err, handler);
//     }
//
//     _refreshing = true;
//     _refreshCompleter = Completer();
//
//     try {
//       await _refreshToken();
//       _refreshCompleter!.complete();
//       return _retry(err, handler);
//     } catch (e) {
//       _refreshCompleter!.completeError(e);
//       return handler.next(err);
//     } finally {
//       _refreshing = false;
//     }
//   }
//
//   Future<void> _refreshToken() async {
//     print("_refreshToken");
//     final res = await dio.post(BaseXController.reTokenAPI, data: BaseXController.bodyRequest);
//     if (res.statusCode == 200) {
//       final token = Global.getString(TOKEN_STRING);
//       final reToken = Global.getString(REFRESH_TOKEN_STRING);
//       final newToken = findValueInJsonString(res.data.toString(), token);
//       final newReToken = findValueInJsonString(res.data.toString(), reToken);
//       print(newToken);
//       Global.setString(TOKEN_STRING, newToken);
//       Global.setString(REFRESH_TOKEN_STRING, newReToken);
//       dio.options.headers["Authorization"] = "Bearer $newToken";
//     } else {
//       throw Exception("Refresh token failed");
//     }
//   }
//
//   dynamic findValueInJsonString(String jsonString, String key) {
//     try {
//       final data = jsonDecode(jsonString);
//       return _findValueRecursive(data, key);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   dynamic _findValueRecursive(dynamic data, String key) {
//     if (data is Map) {
//       if (data.containsKey(key)) return data[key];
//       for (var value in data.values) {
//         final found = _findValueRecursive(value, key);
//         if (found != null) return found;
//       }
//     } else if (data is List) {
//       for (var item in data) {
//         final found = _findValueRecursive(item, key);
//         if (found != null) return found;
//       }
//     }
//     return null;
//   }
//
//   Future<void> _retry(DioException err, ErrorInterceptorHandler handler) async {
//     print("_retry");
//     final requestOptions = err.requestOptions;
//     final token = Global.getString(TOKEN_STRING);
//     requestOptions.headers["Authorization"] = "Bearer $token";
//     final response = await dio.request(
//       requestOptions.path,
//       options: Options(
//         method: requestOptions.method,
//         headers: requestOptions.headers,
//       ),
//       data: requestOptions.data,
//       queryParameters: requestOptions.queryParameters,
//     );
//
//     return handler.resolve(response);
//   }
//
// }

class AuthInterceptor extends Interceptor {
  final Dio dio;

  bool _refreshing = false;
  Completer<void>? _refreshCompleter;

  AuthInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);
    if (_refreshing) {
      await _refreshCompleter!.future;
      return _retry(err, handler);
    }
    // Bắt đầu refresh
    _refreshing = true;
    _refreshCompleter = Completer();
    try {
      await _refreshToken();
      _refreshCompleter!.complete();
      return _retry(err, handler);
    } catch (e) {
      if (!_refreshCompleter!.isCompleted) _refreshCompleter!.completeError(e);
      BaseXController.onError();
      _refreshing = false;
      return handler.reject(err);
    } finally {
      _refreshing = false;
    }
  }

  /// ================================================
  /// REFRESH TOKEN
  /// ================================================
  Future<void> _refreshToken() async {
    log(">>> REFRESH TOKEN", name: "INTERCEPTOR");
    final res = await dio.post(
      BaseXController.reTokenAPI,
      data: BaseXController.bodyRequest,
      options: Options(headers: {"Authorization": null}), // không gửi token cũ
    );
    if (res.statusCode != 200) throw Exception("Refresh token failed");
    final data = res.data["data"];
    final accessToken  = data["access_token"];
    final refreshToken = data["refresh_token"];
    if (accessToken == null || refreshToken == null) throw Exception("Token parse failed");
    // SAVE
    Global.setString(TOKEN_STRING, accessToken);
    Global.setString(REFRESH_TOKEN_STRING, refreshToken);
    // UPDATE HEADER
    dio.options.headers["Authorization"] = "Bearer $accessToken";
    log(">>> NEW TOKEN SAVED", name: "INTERCEPTOR");
  }

  /// ================================================
  /// RETRY ORIGINAL REQUEST
  /// ================================================
  Future<void> _retry(DioException err, ErrorInterceptorHandler handler) async {
    log(">>> RETRY ORIGINAL REQUEST", name: "INTERCEPTOR");
    final requestOptions = err.requestOptions;
    final newToken = Global.getString(TOKEN_STRING);
    requestOptions.headers["Authorization"] = "Bearer $newToken";
    final response = await dio.request(
      requestOptions.path,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
    _refreshing = false;
    return handler.resolve(response);
  }
}


