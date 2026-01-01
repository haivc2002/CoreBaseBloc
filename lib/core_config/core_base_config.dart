import 'package:core_base_bloc/base/base_context.dart';
import 'package:core_base_bloc/core_base_bloc.dart';

class CoreBaseConfig {
  final String keyTheme;
  final Locale locale;
  final CoreBaseWidget? initBaseWidget;
  final Map<String, Map<String, Color>>? configTheme;

  CoreBaseConfig({
    this.keyTheme = "",
    this.initBaseWidget,
    this.configTheme,
    this.locale = const Locale('vi'),
  });

  CoreBaseConfig copyWith({
    String? keyTheme,
    CoreBaseWidget? coreBaseInit,
    Map<String, Map<String, Color>>? configTheme,
    Locale? locale,
  }) => CoreBaseConfig(
    keyTheme: keyTheme ?? this.keyTheme,
    initBaseWidget: coreBaseInit ?? initBaseWidget,
    configTheme: configTheme ?? this.configTheme,
    locale: locale ?? this.locale,
  );
}

class CoreBaseWidget {

  final ConfigButton? configButton;
  final ConfigTextStyle? configTextStyle;
  final ConfigImage? configImage;
  final ConfigInput? configInput;
  final ConfigLoading? configLoading;
  /// Example for [initTheme] use
  /// configTheme: {
  ///   "LIGHT_MODE": {
  ///     "RED": Colors.red,
  ///     "GREEN": Colors.green,
  ///     "BLUE": Colors.blue,
  ///   },
  ///   "DARK_MODE": {
  ///     "RED": Colors.red.shade700,
  ///     "GREEN": Colors.green.shade700,
  ///     "BLUE": Colors.blue.shade700,
  ///   },
  /// };

  CoreBaseWidget({
    this.configButton,
    this.configTextStyle,
    this.configImage,
    this.configInput,
    this.configLoading,
  });
}

class ConfigButton {
  final Object title;
  final AppColor? borderColor, dismissColor;
  final List<AppColor> colors;
  final Function()? onTap;
  final double vertical, horizontal, radius;
  final TextStyle? contentStyle;
  final Object? iconLeading;
  final Object? iconTrailing;

  ConfigButton({
    this.title = "",
    this.onTap,
    this.vertical = 16,
    this.horizontal = 0,
    List<AppColor>? colors,
    this.contentStyle,
    this.borderColor,
    this.radius = 100,
    this.iconLeading,
    this.iconTrailing,
    AppColor? dismissColor
  }) : colors = colors ?? [AppColor.fixed(Colors.orange), AppColor.fixed(Colors.orange)],
       dismissColor = dismissColor ?? AppColor.fixed(Color(0xFFD9D9D9));
}

class ConfigImage {
  final Widget? errorImage;
  final Widget? loadingImage;
  final double radius;

  const ConfigImage({
    this.errorImage,
    this.loadingImage,
    this.radius = 10
  });
}

class ConfigInput {
  AppColor cursorColor,
      alertColor,
      fillColor,
      focusBorderColor,
      hintColor,
      enableBorderColor;
  double radius;

  ConfigInput({
    AppColor? cursorColor,
    AppColor? alertColor,
    AppColor? fillColor,
    this.radius = 10,
    AppColor? enableBorderColor,
    AppColor? focusBorderColor,
    AppColor? hintColor,
  }) : cursorColor = cursorColor ?? AppColor.fixed(Colors.orange),
       fillColor = fillColor ?? AppColor.fixed(Colors.white),
       enableBorderColor = enableBorderColor ?? AppColor.fixed(Colors.white),
       focusBorderColor = focusBorderColor ?? AppColor.fixed(Colors.white70),
       hintColor = hintColor ?? AppColor.fixed(Colors.white70),
       alertColor = cursorColor ?? AppColor.fixed(Colors.red);
}

class ConfigLoading {
  final AppColor? barrierColor;
  final Widget? child;

  const ConfigLoading({
    this.barrierColor,
    this.child
  });
}

class ConfigTextStyle {
  final double? fontSize;
  final AppColor? color;
  final FontWeight? fontWeight;
  final String? fontFamily;

  ConfigTextStyle({
    AppColor? color,
    this.fontSize = 13,
    this.fontFamily,
    this.fontWeight
  }) : color = color ?? AppColor.fixed(Colors.black);
}

class AppColor {
  final Color? _rawColor;
  final String? _themeKey;

  const AppColor._({
    Color? rawColor,
    String? themeKey,
  }) : _rawColor = rawColor,
        _themeKey = themeKey;

  /// 1️⃣ Màu cố định – không phụ thuộc theme
  factory AppColor.fixed(Color color) {
    return AppColor._(rawColor: color);
  }

  /// 2️⃣ Màu theo key theme – sẽ update khi đổi theme
  factory AppColor.theme(String key) {
    return AppColor._(themeKey: key);
  }

  Color? get getColor => _rawColor;

  String get getTheme {
    if(_themeKey != null) return _themeKey;
    throw Exception("Key theme not config");
  }

  Color resolve(BuildContext context) {
    if (_rawColor != null) return _rawColor;
    if (_themeKey != null) {
      return deColorWithCtx(context, _themeKey);
    }
    return Colors.orange;
  }

}
