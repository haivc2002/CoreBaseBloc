
part of 'core_config_bloc.dart';

class CoreConfigEvent {}

class CoreConfigLanguageEvent extends CoreConfigEvent {
  Locale locale;
  CoreConfigLanguageEvent(this.locale);
}

class CoreConfigThemeEvent extends CoreConfigEvent {
  String newTheme;
  CoreConfigThemeEvent(this.newTheme);
}