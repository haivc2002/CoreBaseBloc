import 'dart:developer';
import 'dart:io';

import 'package:core_base_bloc/base/base_view_state.dart';
import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_app.dart';
import 'package:get_it/get_it.dart';

abstract class BaseView<T extends BaseXController, B extends Bloc<dynamic, S>, S>
    extends StatefulWidget with BaseContext<B> {
  BaseView({super.key});

  Widget zBuildView();

  final T controller = GetIt.I<T>();
  static final Map<BaseView, dynamic> _state = {};
  S get state => _state[this] as S;

  bool get viewIsError => controller.screenStateIsError;
  bool get viewIsOk => controller.screenStateIsOK;
  bool get viewIsLoading => controller.screenStateIsLoading;

  @override
  final Type type = T;

  @override
  State<BaseView<T, B, S>> createState() => _BaseViewState<T, B, S>();
}

class _BaseViewState<T extends BaseXController, B extends Bloc<dynamic, S>, S>
    extends State<BaseView<T, B, S>> with RouteAware {

  late final T _controller;

  @override
  void initState() {
    super.initState();
    _controller = GetIt.I<T>();
    BaseContext.stackType.add(T.toString());
    BaseContext.contextKV[T.toString()] = context;
    _controller.onInit();
    log("CREATE ${T.toString()}", name: "CONTROLLER");
  }

  @override
  void dispose() {
    final type = T.toString();
    _controller.onDispose();
    routeObserver.unsubscribe(this);
    log("DISPOSE $type}", name: "CONTROLLER");
    BaseView._state.remove(widget);
    BaseContext.stackType.remove(type);
    final stillExist = BaseContext.stackType.contains(type);
    if (!stillExist) BaseContext.contextKV.remove(type);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    _controller.onChangeDependencies();
  }

  @override
  void didPopNext() {
    // final keys = BaseContext.contextKV.keys.toList();
    final currentKey = T.toString();
    // final currentIndex = keys.indexOf(currentKey);
    // if (currentIndex != -1 && currentIndex < keys.length - 1) {
    //   final removeKeys = keys.sublist(currentIndex + 1);
    //   for (final k in removeKeys) {
    //     BaseContext.contextKV.remove(k);
    //     log("CLEAR CONTEXT: $k", name: "CONTEXT");
    //   }
    // }
    BaseContext.contextKV[currentKey] = context;
    log("ACTIVE CONTEXT: $currentKey", name: "CONTEXT");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      builder: (context, state) {
        BaseView._state[widget] = state;

        return ValueListenableBuilder<ScreenStateEnum>(
          valueListenable: _controller.stateNotifier,
          builder: (context, value, child) {
            if(Platform.isAndroid) {
              return SafeArea(
                  top: false,
                  bottom: false,
                  child: widget.zBuildView()
              );
            } else {
              return widget.zBuildView();
            }
          },
        );
      },
    );
  }
}

