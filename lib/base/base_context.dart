import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:get_it/get_it.dart';

mixin BaseContext<B extends Bloc> {

  static final Map<String, BuildContext> contextKV = {};
  static List<String> stackType = [];

  Type get type;

  BuildContext get context => contextKV[type.toString()]!;

  double get fullHeight => MediaQuery.of(context).size.height;

  double get fullWidth => MediaQuery.of(context).size.width;

  EdgeInsets get paddingView => MediaQuery.of(context).padding;

  Brightness get platformBrightness => MediaQuery.of(context).platformBrightness;

  ThemeData get theme => Theme.of(context);

  /// ex: emitEvent(ExampleEvent());
  void emitEvent(event) {
    if (!context.mounted) return;
    context.read<B>().add(event);
  }

  /// ex: final String state = (currentState as ExampleState).state;
  Object get currentState => context.read<B>().state;

  B get bloc => context.read<B>();

  TextStyle get textStyle => (){
    final style = theme.textTheme.bodyMedium;
    return TextStyle(
      fontSize: style?.fontSize,
      color: style?.color,
      fontWeight: style?.fontWeight ?? FontWeight.w400,
      fontFamily: style?.fontFamily,
    );
  }();

}

/// ex: getCtrl<ExampleXController>().onTest();
T getCtrl<T extends BaseXController>() {
  final controller = GetIt.I<T>();
  return controller;
}
