import 'package:core_base_bloc/base/base_context.dart';
import 'package:core_base_bloc/base/base_navigator.dart';
import 'package:core_base_bloc/base/base_storage.dart';
import 'package:core_base_bloc/base/base_utilities.dart';
import 'package:core_base_bloc/base/base_view_state.dart';
import 'package:core_base_bloc/core_base_bloc.dart';

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
    BaseStorage, BaseNavigator, BaseViewState, BaseUtilities {

  dynamic args;

  @override
  late Type type = runtimeType;

  void onInit() {}

  void onDispose() {}

  /// Account operations ----------------------------------------------------------

  static String reTokenAPI = "";
  static String nameTokenInRes = "";
  static String nameReTokenInRes = "";
  static Map<String, dynamic> bodyRequest = {};
  static VoidCallback onError = (){};

  void setUpAuthentication({
    required String reTokenAPI,
    required Map<String, dynamic> bodyRequest,
    required String nameTokenInRes,
    required String nameReTokenInRes,
    required VoidCallback onError
  }) {
    BaseXController.reTokenAPI = reTokenAPI;
    BaseXController.bodyRequest = bodyRequest;
    BaseXController.nameTokenInRes = nameTokenInRes;
    BaseXController.nameReTokenInRes = nameReTokenInRes;
    BaseXController.onError = onError;
  }

  String get getToken => storageRead(TOKEN_STRING);

  String? get getReToken => storageRead<String>(REFRESH_TOKEN_STRING);

  void onClearDataAuth() {
    storageRemove(TOKEN_STRING);
    storageRemove(REFRESH_TOKEN_STRING);
  }

  /// Account operations ----------------------------------------------------------

  void onGetArgument() {
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    args = arguments;
  }

  void onWidgetReady(VoidCallback fun) => WidgetsBinding.instance.addPostFrameCallback((_)=> fun());

  void setViewLoading() => setScreenState = screenStateLoading;
  void setViewError() => setScreenState = screenStateError;
  void setViewOk() => setScreenState = screenStateOk;
}