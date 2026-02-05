import 'dart:developer';

import 'package:core_base_bloc/base/base_view_state.dart';
import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_config_bloc.dart';

/// A base controller providing shared utilities and behaviors for all feature controllers.
///
/// This class centralizes common logic such as:
/// - lifecycle hooks (onInit, onDispose)
/// - token and refresh-token persistence
/// - navigation helpers
/// - view-state management
/// - access to route arguments
/// - post-frame callbacks
///
/// It is intended to be extended by controllers that work with a specific [Bloc] type.
abstract class BaseXController<B extends Bloc> with BaseContext<B>,
    BaseViewState {

  dynamic args;

  @override
  late Type type = runtimeType;

  /// This variable is used to determine whether or not a "load more" request is being processed.
  bool _isLoadMore = false;
  /// This variable determines whether to allow the "loadmore" function and display the loading screen.
  bool isMoreEnable = true;
  bool withScrollController = false;
  /// To enable the overall screen scroll controller, set [setEnableScrollController] = true in the [onInit] function.
  set setEnableScrollController(bool value) => withScrollController = value;
  late ScrollController scrollController;

  void onInit() {
    _isLoadMore = false;
    isMoreEnable = true;
    withScrollController = false;
    if (withScrollController) {
      scrollController = ScrollController();
      scrollController.addListener(_scrollListener);
    }
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      if (!_isLoadMore && isMoreEnable) {
        _isLoadMore = true;
        onLoadMore();
      }
    }
  }

  /// Ex: @override
  ///   void onLoadMore() {
  ///     _page ++;
  ///     onFetchData(page: _page);
  ///     super.onLoadMore();
  ///   }
  void onLoadMore() {
    log("ENABLE LOAD MORE");
    _isLoadMore = false;
  }

  void onDispose() {}

  void onChangeDependencies() {
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    args = arguments;
  }


  /// Get access token from storage using custom key.
  /// Prefer this over deprecated [getToken] for flexibility.
  String getTokenBy(String storageKey) => storageRead(storageKey) ?? '';

  /// Get refresh token from storage using custom key.
  /// Prefer this over deprecated [getReToken] for flexibility.
  String? getRefreshTokenBy(String storageKey) => storageRead<String>(storageKey);

  /// **DEPRECATED**: Use [getTokenBy] with custom storage key instead.
  @Deprecated('Use getTokenBy(storageKey) instead. Will be removed in future versions.')
  String get getToken => storageRead(kDefaultTokenStorageKey) ?? '';

  /// **DEPRECATED**: Use [getRefreshTokenBy] with custom storage key instead.
  @Deprecated('Use getRefreshTokenBy(storageKey) instead. Will be removed in future versions.')
  String? get getReToken => storageRead<String>(kDefaultRefreshTokenStorageKey);

  /// Clear authentication data from storage.
  /// 
  /// By default, this clears the deprecated TOKEN_STRING and REFRESH_TOKEN_STRING.
  /// If you use custom storage keys, call [storageClear] or [storageRemove] directly.
  void onClearDataAuth() {
    storageRemove(kDefaultTokenStorageKey);
    storageRemove(kDefaultRefreshTokenStorageKey);
  }

  /// Account operations ----------------------------------------------------------

  void onWidgetReady(VoidCallback f) => WidgetsBinding.instance.addPostFrameCallback((_)=> f());

  void setViewLoading() => setScreenState = screenStateLoading;

  void setViewError() => setScreenState = screenStateError;

  void setViewOk() => setScreenState = screenStateOk;

  void onChangeTheme(String theme) {
    context.read<CoreConfigBloc>().add(CoreConfigThemeEvent(theme));
  }

  void onChangeLanguage(Locale local) {
    context.read<CoreConfigBloc>().add(CoreConfigLanguageEvent(local));
  }

  /// Ex: @override
  ///   void onRefresh() {
  ///     super.onLoadMore();
  ///     onFetchData();
  ///   }
  ///   #####################
  ///   Gọi hàm [onFetchData] sau super.onLoadMore() để thực hiện [_isLoadMore] & [isMoreEnable] trước
  Future<void> onRefresh() async {
    _isLoadMore = false;
    isMoreEnable = true;
    log("ENABLE REFRESH");
  }

}

class BodyRequestRefreshToken {
  final String nameRefreshToken;
  final String keyStorageRefreshToken;
  final Map<String, dynamic> bodyRequestMore;

  const BodyRequestRefreshToken({
    this.bodyRequestMore = const {},
    this.keyStorageRefreshToken = "",
    this.nameRefreshToken = ""
  });
}