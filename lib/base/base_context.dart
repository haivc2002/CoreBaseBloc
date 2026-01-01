import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_base_app.dart';
import 'package:core_base_bloc/core_config/core_base_cubit.dart';
import 'package:core_base_bloc/overlay_ui/overlay_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

mixin BaseContext<B extends Bloc> {

  static final Map<String, BuildContext> contextKV = {};
  static List<String> stackType = [];

  Type get type;

  BuildContext get context => contextKV[type.toString()]!;

  /// ex: getCtrl<ExampleXController>().onTest();
  T getCtrl<T extends BaseXController>() {
    final controller = GetIt.I<T>();
    return controller;
  }

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

  Future<void> dialog(Widget body, {
    String title = "Thông báo",
    bool showTitle = true,
    bool showBottom = true,
    TextStyle? styleTitle,
    Widget? bottom
  }) => showCupertinoDialog(context: context, builder: (_) {
    return BlocProvider<B>.value(
      value: context.read<B>(),
      child: OverlayDialog(
        title: title,
        bottom: bottom,
        content: body,
        showBottom: showBottom,
        styleTitle: styleTitle,
        showTitle: showTitle,
      ),
    );
  });

  Future<void> bottomSheet() => showModalBottomSheet(context: context, builder: (context) {
    return Text("data");
  });

  Future<void> openLoading() {
    final context = navigatorKey.currentContext!;
    final sys = context.read<CoreBaseCubit>().state.initBaseWidget?.configLoading;
    return showCupertinoDialog(
      barrierColor: sys?.barrierColor?.getColor,
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Material(
            color: Colors.transparent,
            child: Center(child: sys?.child ?? DecoratedBox(
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

  /// Use the function with the color key as the Map type (color decoding).
  /// Map<String, Map<String, Color>>
  /// EXU: deColor("RED") --> red color (color type)
  Color deColor(String key) {
    final context = contextKV[type.toString()] ?? navigatorKey.currentContext!;
    final theme = context.read<CoreBaseCubit>().state.configTheme;
    if (theme == null) throw Exception("ConfigTheme not configure");
    final keyTheme = context.read<CoreBaseCubit>().state.keyTheme;
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
    final theme = context.read<CoreBaseCubit>().state.configTheme;
    if (theme == null) throw Exception("ConfigTheme not configure");
    final first = theme.entries.first.value;
    if (first.containsKey(key)) return first[key]!;
    throw Exception("Color key '$key' not found in first theme");
  }

  TextStyle get textStyle => (){
    ConfigTextStyle t = context.read<CoreBaseCubit>()
        .state.initBaseWidget
        ?.configTextStyle ?? ConfigTextStyle(
          fontSize: 13,
          color: AppColor.fixed(Colors.black),
          fontWeight: FontWeight.w400,
        );

    return TextStyle(
      fontSize: t.fontSize ?? 13,
      color: deColor(t.color?.getTheme ?? "black"),
      fontWeight: t.fontWeight ?? FontWeight.w400,
      fontFamily: t.fontFamily,
    );
  }();
}

TextStyle textStyleWithCtx(BuildContext context) {
  ConfigTextStyle t = context
      .watch<CoreBaseCubit>()
      .state.initBaseWidget
      ?.configTextStyle ?? ConfigTextStyle(
    fontSize: 13,
    color: AppColor.fixed(Colors.black),
    fontWeight: FontWeight.w400,
  );

  return TextStyle(
    fontSize: t.fontSize ?? 13,
    color: deColorWithCtx(context, t.color?.getTheme ?? "black"),
    fontWeight: t.fontWeight ?? FontWeight.w400,
    fontFamily: t.fontFamily,
  );
}

Color deColorWithCtx(BuildContext context, String key) {
  final theme = context.read<CoreBaseCubit>().state.configTheme;
  if (theme == null) throw Exception("ConfigTheme not configure");
  final keyTheme = context.read<CoreBaseCubit>().state.keyTheme;
  if (theme.containsKey(keyTheme)) {
    final data = theme[keyTheme]!;
    if (data.containsKey(key)) return data[key]!;
  }
  /// fallback về theme đầu tiên
  final first = theme.entries.first.value;
  if (first.containsKey(key)) return first[key]!;
  throw Exception("Color key '$key' not found");
}
