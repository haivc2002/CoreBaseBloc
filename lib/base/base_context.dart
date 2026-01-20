import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_base_app.dart';
import 'package:core_base_bloc/core_config/core_base_config_cubit.dart';
import 'package:core_base_bloc/overlay_ui/overlay_snackbar.dart';
import 'package:flutter/cupertino.dart';
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

  /// ex: emitEvent(ExampleEvent());
  void emitEvent(event) {
    if (!context.mounted) return;
    context.read<B>().add(event);
  }

  /// ex: final String state = (currentState as ExampleState).state;
  Object get currentState => context.read<B>().state;

  B get bloc => context.read<B>();

  /// ----------------------------------------------------
  /// [Overlay]
  /// ----------------------------------------------------

  Future<void> dialog({
    bool showTitle = true,
    bool showBottom = true,
    OverlayDialogTitle? dialogTitle,
    OverlayDialogBody? dialogBody,
    OverlayDialogBottom? dialogBottom,
  }) => showCupertinoDialog(context: context, builder: (_) {
    return BlocProvider<B>.value(
      value: context.read<B>(),
      child: OverlayDialog(
        showBottom: showBottom,
        showTitle: showTitle,
        dialogTitle: dialogTitle,
        dialogBody: dialogBody,
        dialogBottom: dialogBottom,
      ),
    );
  });

  Future<void> bottomSheet() => showModalBottomSheet(context: context, builder: (context) {
    return Text("data");
  });

  void successSnackBar({String? message, String? title}) => snackBar(
      status: StatusSnackBar.SUCCESS,
      title: title,
      message: message ?? ""
  );

  void errorSnackBar({String? message, String? title}) => snackBar(
      status: StatusSnackBar.FAILURE,
      title: title,
      message: message ?? ""
  );

  void warningSnackBar({String? message, String? title}) => snackBar(
      status: StatusSnackBar.WARNING,
      title: title,
      message: message ?? ""
  );

  /// ----------------------------------------------------
  /// [Overlay]
  /// ----------------------------------------------------

  /// Use the function with the color key as the Map type (color decoding).
  /// Map<String, Map<String, Color>>
  /// EXU: deColor("RED") --> red color (color type)
  Color deColor(String key) {
    final context = contextKV[type.toString()] ?? navigatorKey.currentContext!;
    final theme = context.read<CoreBaseConfigCubit>().state.configTheme;
    if (theme == null) throw Exception("ConfigTheme not configure");
    final keyTheme = context.read<CoreBaseConfigCubit>().state.keyTheme;
    if (theme.containsKey(keyTheme)) {
      final data = theme[keyTheme]!;
      if (data.containsKey(key)) return data[key]!;
    }
    /// fallback về theme đầu tiên
    final first = theme.entries.first.value;
    if (first.containsKey(key)) return first[key]!;
    throw Exception("Color key '$key' not found");
  }

  TextStyle get textStyle => (){
    ConfigTextStyle t = CoreBaseConfigState.configTextStyle;
    Color resolveColor(Object value) {
      return value is String
          ? deColor(value)
          : value as Color;
    }
    return TextStyle(
      fontSize: t.fontSize ?? 13,
      color: resolveColor(t.color!.valueColor),
      fontWeight: t.fontWeight ?? FontWeight.w400,
      fontFamily: t.fontFamily,
    );
  }();

}

Future<void> openLoading() {
  final context = navigatorKey.currentContext!;
  return showCupertinoDialog(
    barrierColor: Colors.black26,
    context: context,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Material(
          color: Colors.transparent,
          child: Center(child: DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: WidgetWait(color: Colors.white),
            ),
          )),
        ),
      );
    },
  );
}

void closeLoading() => back();

/// ex: getCtrl<ExampleXController>().onTest();
T getCtrl<T extends BaseXController>() {
  final controller = GetIt.I<T>();
  return controller;
}

TextStyle textStyleWithCtx(BuildContext context) {
  ConfigTextStyle t = CoreBaseConfigState.configTextStyle;
  Color resolveColor(Object value) {
    return value is String
        ? deColorWithCtx(context, value)
        : value as Color;
  }

  return TextStyle(
    fontSize: t.fontSize ?? 13,
    color: resolveColor(t.color!.valueColor),
    fontWeight: t.fontWeight ?? FontWeight.w400,
    fontFamily: t.fontFamily,
  );
}

Color deColorWithCtx(BuildContext context, String key) {
  final theme = context.read<CoreBaseConfigCubit>().state.configTheme;
  if (theme == null) throw Exception("ConfigTheme not configure");
  final keyTheme = context.read<CoreBaseConfigCubit>().state.keyTheme;
  if (theme.containsKey(keyTheme)) {
    final data = theme[keyTheme]!;
    if (data.containsKey(key)) return data[key]!;
  }
  /// fallback về theme đầu tiên
  final first = theme.entries.first.value;
  if (first.containsKey(key)) return first[key]!;
  throw Exception("Color key '$key' not found");
}

/// Use with defined color codes (which are constant and always use the first mode of the color).
/// [dFColor] stands for default color
/// Map<String, Map<String, Color>>
/// "LIGHT": {
///   "RED": Colors.red ---> Always use [dFColor] the first value, which is [LIGHT].
/// },
/// "DARK": {
///   "RED": Colors.green
/// }
/// EXU: dFColor("RED") --> red color (color type),
Color dFColor(String key) {
  final theme = navigatorKey.currentContext?.read<CoreBaseConfigCubit>().state.configTheme;
  if (theme == null) throw Exception("ConfigTheme not configure");
  final first = theme.entries.first.value;
  if (first.containsKey(key)) return first[key]!;
  throw Exception("Color key '$key' not found in first theme");
}
