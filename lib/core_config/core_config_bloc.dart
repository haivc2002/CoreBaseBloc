import 'package:core_base_bloc/core_base_bloc.dart';

part 'core_config_event.dart';
part 'core_config_state.dart';

class CoreConfigBloc extends Bloc<CoreConfigEvent, CoreConfigState> {
  CoreConfigBloc() : super(CoreConfigState()) {
    on<CoreConfigLanguageEvent>((event, emit) {
      emit(state.copyWith(locale: event.locale));
    });
    on<CoreConfigThemeEvent>((event, emit) {
      emit(state.copyWith(keyTheme: event.newTheme));
    });
  }
}