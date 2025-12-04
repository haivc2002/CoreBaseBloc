import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_base_app.dart';

mixin class BaseNavigator {
  final contextNavigator = navigatorKey.currentContext!;

  /// ----------------------------------------------------
  /// [Navigator]
  /// ----------------------------------------------------
  Future pushNamed(String routeName, {Object? arguments}) {
    return Navigator.pushNamed(contextNavigator, routeName, arguments: arguments);
  }

  Future pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed(
      contextNavigator,
      routeName,
      arguments: arguments,
    );
  }

  Future pushNamedAndRemoveUntil(
      String routeName, {
        Object? arguments,
        bool Function(Route<dynamic>)? predicate,
      }) => Navigator.pushNamedAndRemoveUntil(
    contextNavigator,
    routeName,
    predicate ?? (route) => false,
    arguments: arguments,
  );

  void back<T>([T? result]) {
    if (Navigator.canPop(contextNavigator)) {
      Navigator.pop(contextNavigator, result);
    }
  }

  void backToFirst() {
    Navigator.popUntil(contextNavigator, (route) => route.isFirst);
  }

  void popUntil(String routeName) {
    Navigator.popUntil(contextNavigator, ModalRoute.withName(routeName));
  }
}