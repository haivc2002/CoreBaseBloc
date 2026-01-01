import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_base_app.dart';

final _contextNavigator = navigatorKey.currentContext!;

/// ----------------------------------------------------
/// [Navigator]
/// ----------------------------------------------------
Future pushNamed(String routeName, {Object? arguments}) {
  return Navigator.pushNamed(_contextNavigator, routeName, arguments: arguments);
}

Future pushReplacementNamed(String routeName, {Object? arguments}) {
  return Navigator.pushReplacementNamed(
    _contextNavigator,
    routeName,
    arguments: arguments,
  );
}

Future pushNamedAndRemoveUntil(
    String routeName, {
      Object? arguments,
      bool Function(Route<dynamic>)? predicate,
    }) => Navigator.pushNamedAndRemoveUntil(
  _contextNavigator,
  routeName,
  predicate ?? (route) => false,
  arguments: arguments,
);

void back<T>([T? result]) {
  if (Navigator.canPop(_contextNavigator)) {
    Navigator.pop(_contextNavigator, result);
  }
}

void backToFirst() {
  Navigator.popUntil(_contextNavigator, (route) => route.isFirst);
}

void popUntil(String routeName) {
  Navigator.popUntil(_contextNavigator, ModalRoute.withName(routeName));
}