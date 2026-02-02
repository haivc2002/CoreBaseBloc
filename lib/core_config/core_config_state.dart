part of 'core_config_bloc.dart';

class CoreConfigState {

  static Map<String, ThemeData> configTheme = const {};

  final String keyTheme;
  final Locale locale;

  CoreConfigState({
    this.keyTheme = "",
    this.locale = const Locale('vi'),
  });

  CoreConfigState copyWith({
    String? keyTheme,
    Locale? locale,
  }) {
    return CoreConfigState(
      keyTheme: keyTheme ?? this.keyTheme,
      locale: locale ?? this.locale,
    );
  }
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
