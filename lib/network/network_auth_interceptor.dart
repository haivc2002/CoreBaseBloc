import 'dart:async';
import 'dart:developer';
import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:dio/dio.dart';

class NetworkAuthInterceptor extends Interceptor {
  final Dio dio;

  bool _refreshing = false;
  Completer<void>? _refreshCompleter;

  NetworkAuthInterceptor(this.dio);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.requestOptions.path == BaseXController.reTokenAPI) {
      return handler.next(response);
    }
    if (response.statusCode != 401 || BaseXController.reTokenAPI.isEmpty) {
      return handler.next(response);
    }
    final refreshToken = storageRead<String>(BaseXController.bodyRequest.keyStorageRefreshToken);
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
      data: {
        BaseXController.bodyRequest.nameRefreshToken: refreshToken,
        ...BaseXController.bodyRequest.bodyRequestMore
      },
      options: Options(headers: {"Authorization": null}),
    );
    if (res.statusCode != 200) BaseXController.onError();
    final data = res.data["data"];
    final accessToken = data[BaseXController.nameTokenInRes];
    final newRefreshToken = data[BaseXController.nameReTokenInRes];
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



