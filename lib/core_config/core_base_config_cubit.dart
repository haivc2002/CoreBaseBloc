import 'package:core_base_bloc/core_base_bloc.dart';

class CoreBaseConfigCubit extends Cubit<CoreBaseConfigState> {
  CoreBaseConfigCubit() : super(CoreBaseConfigState());

  void setThemeUI(String newTheme) {
    emit(state.copyWith(keyTheme: newTheme));
  }

  void setLanguage(Locale locale) {
    emit(state.copyWith(locale: locale));
  }

  void setUpColorTheme(Map<String, Map<String, Color>>? configTheme) {
    emit(state.copyWith(configTheme: configTheme));
  }
}