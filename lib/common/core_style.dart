import 'package:core_base_bloc/core_base_bloc.dart';

class CoreStyle {

  static TextStyle get d => CoreBaseConfig.instance.configTextStyle ?? TextStyle(
    fontSize: 13,
    color: Colors.black,
    fontWeight: FontWeight.w400,
  );

  static TextStyle def = TextStyle(
    fontSize: d.fontSize ?? 13,
    color: d.color ?? Colors.black,
    fontWeight: d.fontWeight ?? FontWeight.w400,
    fontFamily: d.fontFamily,
  );
}

class StyleAutoSizeText extends CoreStyle {

  static TextStyle def = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
  );
}

extension ExtendedTextStyle on TextStyle {
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  TextStyle get italic {
    return copyWith(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
    );
  }

  TextStyle sColor([Color? c1, Color? c2]) {
    if(c1 == null) return copyWith(color: Colors.black.withValues(alpha: 0.8));
    if (c2 == null) return copyWith(color: c1);
    return copyWith(
      foreground: Paint()
        ..shader = LinearGradient(colors: [c1, c2]).createShader(
          const Rect.fromLTWH(0, 0, 200, 70),
        ),
    );
  }

  TextStyle sSize(double size) => copyWith(fontSize: size);

  TextStyle underline({Color color = Colors.black, double thickness = 1}) {
    return copyWith(
      decoration: TextDecoration.underline,
      decorationColor: color,
      decorationThickness: thickness,
    );
  }

  TextStyle lineThrough({Color color = Colors.black, double thickness = 0.5}) {
    return copyWith(
      decoration: TextDecoration.lineThrough,
      decorationColor: color,
      decorationThickness: thickness,
    );
  }

  TextStyle boldItalic({
    Color? color,
    double? fontSize,
  }) {
    return copyWith(
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: color,
      fontSize: fontSize,
    );
  }

  TextStyle shadow({
    Color color = Colors.black54,
    Offset offset = const Offset(0, 0),
    double blur = 3,
  }) {
    return copyWith(
      shadows: [
        Shadow(
          color: color,
          offset: offset,
          blurRadius: blur,
        ),
      ],
    );
  }
}