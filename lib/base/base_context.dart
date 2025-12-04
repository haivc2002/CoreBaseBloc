import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/overlay_ui/overlay_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

mixin BaseContext<B extends Bloc> {

  static final Map<String, BuildContext> contextKV = {};

  Type get type;

  BuildContext get context => contextKV[type.toString()]!;

  /// ex: doHelp<ExampleXController>().onTest();
  T doHelp<T extends BaseXController>() {
    final controller = GetIt.I<T>();
    return controller;
  }

  double get fullHeight => MediaQuery.of(context).size.height;

  double get fullWidth => MediaQuery.of(context).size.width;

  EdgeInsets get paddingView => MediaQuery.of(context).padding;

  /// ex: emitEvent(ExampleEvent());
  void emitEvent(event) {
    if(!context.mounted) return;
    context.read<B>().add(event);
  }

  /// ex: final String state = (currentState as ExampleState).state;
  Object get currentState => context.read<B>().state;

  B get bloc => context.read<B>();

  /// ----------------------------------------------------
  /// [Overlay]
  /// ----------------------------------------------------

  ConfigLoading get d => CoreBaseConfig.instance.configLoading ?? ConfigLoading();

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

  Future<void> dialogConfirm(Widget body, {
    String title = "Thông báo",
    VoidCallback? onTap,
    List<Color> yesColors = const []
  }) => showCupertinoDialog(context: context, builder: (_) {
    return OverlayDialog(
      title: title,
      content: body,
      bottom: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 100, child: WidgetButton(
          title: "Đồng ý",
          contentStyle: CoreStyle.def.sColor(Colors.white),
          vertical: 7,
          colors: yesColors,
          onTap: onTap,
        )),
        const SizedBox(width: 15),
        SizedBox(width: 100, child: WidgetButton(
          title: "Đóng",
          contentStyle: CoreStyle.def.sColor(Colors.white),
          vertical: 7,
          colors: [?ConfigButton().dismissColor],
          onTap: ()=> Navigator.pop(context),
        ))
      ]),
    );
  });

  Future<void> bottomSheet() => showModalBottomSheet(context: context, builder: (context) {
    return Text("data");
  });

  Future<void> openLoading() => showCupertinoDialog(
    barrierColor: d.barrierColor,
    context: context,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Material(
          color: Colors.transparent,
          child: Center(child: d.child ?? DecoratedBox(
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

  void closeLoading() => Navigator.pop(context);
}

