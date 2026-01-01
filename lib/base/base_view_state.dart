import 'package:flutter/material.dart';

enum ScreenStateEnum {
  ERROR,
  LOADING,
  OK
}

/// State of screen wait screen [Loading], success screen [OK], error screen [Error]
/// Ex: setScreenState = screenStateError;
/// Ex: setScreenState = screenStateLoading;
/// Ex: setScreenState = screenStateOk;
mixin class BaseViewState {
  final ValueNotifier<ScreenStateEnum> _screenState = ValueNotifier(ScreenStateEnum.LOADING);
  ScreenStateEnum screenStateLoading = ScreenStateEnum.LOADING;
  ScreenStateEnum screenStateOk = ScreenStateEnum.OK;
  ScreenStateEnum screenStateError = ScreenStateEnum.ERROR;

  ScreenStateEnum get getScreenState => _screenState.value;

  set setScreenState(ScreenStateEnum event) => _screenState.value = event;

  bool get screenStateIsLoading => _screenState.value == screenStateLoading;

  bool get screenStateIsOK => _screenState.value == screenStateOk;

  bool get screenStateIsError => _screenState.value == screenStateError;

  ValueNotifier<ScreenStateEnum> get stateNotifier => _screenState;

  void disposeScreenState() => _screenState.dispose();
}

