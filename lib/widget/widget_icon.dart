import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WidgetIcon extends StatelessWidget {
  final Object icon;
  final double size;
  final List<Color> colors;

  const WidgetIcon({
    super.key,
    required this.icon,
    this.colors = const [],
    this.size = 24,
  })  : assert(
  icon is IconData || icon is String,
  'icon phải là kiểu String hoặc IconData',
  ), assert(
  colors.length <= 2,
  'colors chỉ được chứa tối đa 2 màu',
  );

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (icon is IconData) {
      child = Icon(icon as IconData, size: size, color: colors.isEmpty ? null : colors.first);
    } else if (icon is String && (icon as String).endsWith('.svg')) {
      child = SvgPicture.asset(
        icon as String,
        width: size,
        height: size,
        colorFilter: colors.length == 1
            ? ColorFilter.mode(colors.first, BlendMode.srcIn)
            : null,
      );
    } else if (icon is String) {
      child = Image.asset(
        icon as String,
        width: size,
        height: size,
        color: colors.length == 1 ? colors.first : null,
        colorBlendMode: colors.length == 1 ? BlendMode.srcIn : null,
      );
    } else {
      return const SizedBox.shrink();
    }

    // Nếu có 2 màu -> bọc ShaderMask
    if (colors.length == 2) {
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: child,
      );
    }

    return child;
  }
}

