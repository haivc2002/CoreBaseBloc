import 'package:core_base_bloc/core_base_bloc.dart';

class CoreBaseObserver extends NavigatorObserver {
  final List<Route<dynamic>> stack = [];

  // void printStack(String from) {
  //   log('==== STACK FROM $from ====', name: 'NAV');
  //   for (var i = 0; i < stack.length; i++) {
  //     final r = stack[i];
  //     log(
  //       '$i -> ${r.settings.name ?? r.runtimeType}',
  //       name: 'NAV',
  //     );
  //   }
  // }

  @override
  void didPush(Route route, Route? previousRoute) {
    stack.add(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    stack.remove(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    stack.remove(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) stack.remove(oldRoute);
    if (newRoute != null) stack.add(newRoute);
  }
}
