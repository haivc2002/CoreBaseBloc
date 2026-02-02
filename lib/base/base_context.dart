import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_app.dart';
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

  ThemeData get theme => Theme.of(context);

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

  TextStyle get textStyle => (){
    final style = theme.textTheme.labelMedium;
    return TextStyle(
      fontSize: style?.fontSize,
      color: style?.color,
      fontWeight: style?.fontWeight ?? FontWeight.w400,
      fontFamily: style?.fontFamily,
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
