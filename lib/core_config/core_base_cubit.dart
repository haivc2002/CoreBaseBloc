import 'package:core_base_bloc/core_base_bloc.dart';

class CoreBaseCubit extends Cubit<CoreBaseConfig> {
  CoreBaseCubit() : super(CoreBaseConfig());

  void setThemeUI(String newTheme) {
    emit(state.copyWith(keyTheme: newTheme));
  }

  void setLanguage(Locale locale) {
    emit(state.copyWith(locale: locale));
  }

  void setUpCoreWidgetInit(CoreBaseWidget? initWidget) {
    emit(state.copyWith(coreBaseInit: initWidget));
  }

  void setUpColorTheme(Map<String, Map<String, Color>>? configTheme) {
    emit(state.copyWith(configTheme: configTheme));
  }
}