import 'package:core_base_bloc/core_base_bloc.dart';

class CoreBaseConfigState {

  static ConfigTextStyle configTextStyle = ConfigTextStyle();

  final String keyTheme;
  final Locale locale;
  final Map<String, Map<String, Color>>? configTheme;

  CoreBaseConfigState({
    this.keyTheme = "",
    this.configTheme,
    this.locale = const Locale('vi'),
  });

  CoreBaseConfigState copyWith({
    String? keyTheme,
    Map<String, Map<String, Color>>? configTheme,
    Locale? locale,
  }) => CoreBaseConfigState(
    keyTheme: keyTheme ?? this.keyTheme,
    configTheme: configTheme ?? this.configTheme,
    locale: locale ?? this.locale,
  );
}

class ConfigTextStyle {
  final double? fontSize;
  final AppTextStyleColor? color;
  final FontWeight? fontWeight;
  final String? fontFamily;

  ConfigTextStyle({
    AppTextStyleColor? color,
    this.fontSize = 13,
    this.fontFamily,
    this.fontWeight
  }) : color = color ?? AppTextStyleColor.fixed(Colors.black);
}

class AppTextStyleColor {
  final Color? _rawColor;
  final String? _themeKey;

  const AppTextStyleColor._({
    Color? rawColor,
    String? themeKey,
  })  : _rawColor = rawColor,
        _themeKey = themeKey;

  /// 1️⃣ Màu cố định – không phụ thuộc theme
  factory AppTextStyleColor.fixed(Color color) {
    return AppTextStyleColor._(rawColor: color);
  }

  /// 2️⃣ Màu theo key theme – sẽ update khi đổi theme
  factory AppTextStyleColor.theme(String key) {
    return AppTextStyleColor._(themeKey: key);
  }

  Object get valueColor {
    if (_rawColor != null) return _rawColor;
    if (_themeKey != null) return _themeKey;
    return Colors.orange;
  }

}
