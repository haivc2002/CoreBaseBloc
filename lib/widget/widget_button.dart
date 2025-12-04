import 'package:core_base_bloc/core_base_bloc.dart';

class WidgetButton extends StatelessWidget {
  WidgetButton({
    super.key,
    Object? title,
    this.onTap,
    double? vertical,
    double? horizontal,
    List<Color> colors = const [],
    this.contentStyle,
    Color? borderColor,
    double? radius,
    this.iconLeading,
    this.iconTrailing,
  })  : title = title ?? d.title,
        vertical = vertical ?? d.vertical,
        horizontal = horizontal ?? d.horizontal,
        colors = colors.isEmpty ? d.colors : colors,
        borderColor = borderColor ?? d.borderColor,
        radius = radius ?? d.radius,
        assert(colors.isEmpty || colors.length <= 2, "colors chỉ tối đa không vượt quá 2 màu"),
        assert(title is Widget? || title is String?, "title chỉ có thể là widget hoặc String");

  final Object title;
  final Color? borderColor;
  final List<Color> colors;
  final Function()? onTap;
  final double? vertical, horizontal, radius;
  final TextStyle? contentStyle;
  final Object? iconLeading;
  final Object? iconTrailing;

  static ConfigButton get d => CoreBaseConfig.instance.configButton ?? ConfigButton();

  @override
  Widget build(BuildContext context) {
    final TextStyle resolvedStyle =
        contentStyle ?? CoreStyle.def.sColor(Colors.white).sSize(15).bold;

    final List<Color> buttonColors = colors.isEmpty
        ? [d.colors[0], d.colors[0]]
        : colors.length == 1
        ? [colors[0], colors[0]]
        : colors;

    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius!),
          border: Border.all(
              color: borderColor ?? Colors.transparent, strokeAlign: 1),
          gradient: LinearGradient(
            colors: buttonColors,
          ),
          boxShadow: [
            BoxShadow(
              color: buttonColors[0].withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius!),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: vertical ?? 16, horizontal: horizontal ?? 0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (iconLeading != null)
                      Padding(
                        padding: EdgeInsets.only(right: title != "" ? 6 : 0),
                        child: WidgetIcon(
                          icon: iconLeading!,
                          colors: [?resolvedStyle.color],
                          size: resolvedStyle.fontSize! * 1.2,
                        ),
                      ),
                    ConstrainedBox(
                      constraints:
                      BoxConstraints(maxWidth: width - 24 - horizontal!),
                      child: title is String
                        ? Text(title as String, style: resolvedStyle)
                        : title as Widget,
                    ),
                    if (iconTrailing != null)
                      Padding(
                        padding: EdgeInsets.only(left: title != "" ? 6 : 0),
                        child: WidgetIcon(
                          icon: iconTrailing!,
                          colors: [?resolvedStyle.color],
                          size: resolvedStyle.fontSize! * 1.2,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

