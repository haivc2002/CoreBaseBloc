import 'package:core_base_bloc/core_base_bloc.dart';

class CoreBaseConfig {
  static CoreBaseConfig instance = CoreBaseConfig();

  static void defInit(CoreBaseConfig config) => instance = config;

  final ConfigButton? configButton;
  final TextStyle? configTextStyle;
  final ConfigImage? configImage;
  final ConfigInput? configInput;
  final ConfigLoading? configLoading;

  CoreBaseConfig({
    this.configButton,
    this.configTextStyle,
    this.configImage,
    this.configInput,
    this.configLoading,
  });
}

class ConfigButton {
  final Object title;
  final Color? borderColor, dismissColor;
  final List<Color> colors;
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
    this.colors = const [Colors.orange, Colors.orange],
    this.contentStyle,
    this.borderColor,
    this.radius = 100,
    this.iconLeading,
    this.iconTrailing,
    this.dismissColor = const Color(0xFFD9D9D9),
  });
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
  Color cursorColor,
      alertColor,
      fillColor,
      focusBorderColor,
      hintColor,
      enableBorderColor;
  double radius;

  ConfigInput({
    this.cursorColor = Colors.orange,
    this.alertColor = Colors.red,
    this.fillColor = Colors.white,
    this.radius = 10,
    this.enableBorderColor = Colors.white,
    this.focusBorderColor = Colors.white70,
    this.hintColor = Colors.white70
  });
}

class ConfigLoading {
  final Color? barrierColor;
  final Widget? child;

  const ConfigLoading({
    this.barrierColor,
    this.child
  });
}