import 'dart:async';
import 'dart:developer';
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

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.requestOptions.path == BaseXController.reTokenAPI) {
      return handler.next(response);
    }
    if (response.statusCode != 401 || BaseXController.reTokenAPI.isEmpty) {
      return handler.next(response);
    }
    final refreshToken = storageRead<String>(REFRESH_TOKEN_STRING);
    if (refreshToken == null || refreshToken.isEmpty) {
      log(">>> REFRESH TOKEN NULL - SKIP REFRESH", name: "INTERCEPTOR");
      return handler.next(response);
    }
    final err = DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
    if (_refreshing) {
      await _refreshCompleter!.future;
      return _retry(err, handler);
    }
    _refreshing = true;
    _refreshCompleter = Completer();
    try {
      await _refreshToken(refreshToken);
      _refreshCompleter!.complete();
      return _retry(err, handler);
    } catch (e) {
      if (!_refreshCompleter!.isCompleted) {
        _refreshCompleter!.completeError(e);
      }
      log(">>> REFRESH FAILED BUT NO LOGOUT", name: "INTERCEPTOR");
      return handler.next(response);
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _refreshToken(String refreshToken) async {
    log(">>> REFRESH TOKEN", name: "INTERCEPTOR");
    final res = await dio.post(
      BaseXController.reTokenAPI,
      data: {"refreshToken": refreshToken},
      options: Options(headers: {"Authorization": null}),
    );
    if (res.statusCode != 200) throw Exception("Refresh token failed");
    final data = res.data["data"];
    final accessToken = data["access_token"];
    final newRefreshToken = data["refresh_token"];
    if (accessToken == null || newRefreshToken == null) throw Exception("Token parse failed");
    storageWrite(TOKEN_STRING, accessToken);
    storageWrite(REFRESH_TOKEN_STRING, newRefreshToken);
    dio.options.headers["Authorization"] = "Bearer $accessToken";
    log(">>> NEW TOKEN SAVED", name: "INTERCEPTOR");
  }


  Future<void> _retry(DioException err, ResponseInterceptorHandler handler) async {
    log(">>> RETRY ORIGINAL REQUEST", name: "INTERCEPTOR");
    final request = err.requestOptions;
    final newToken = storageRead<String>(TOKEN_STRING);
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

    return handler.resolve(res);
  }
}



