import 'package:core_base_bloc/core_base_bloc.dart';

final btnPadding = const EdgeInsets.symmetric(vertical: 7, horizontal: 10);

class WidgetButton extends StatelessWidget {
  WidgetButton({
    super.key,
    this.title,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
    this.colors = const [Colors.black, Colors.black],
    TextStyle? contentStyle,
    this.borderColor,
    this.radius = 10,
    this.enableShadow = true,
    this.iconLeading,
    this.iconTrailing,
  })  : assert(colors.isEmpty || colors.length <= 2, "The maximum number of 'colors' should not exceed 2."),
        assert(title is Widget? || title is String?, "The 'title' can only be a widget or a string."),
        assert(iconLeading is IconData? || title is String?, "The 'iconLeading' can only be a IconData or a string."),
        assert(iconTrailing is IconData? || title is String?, "The 'iconTrailing' can only be a IconData or a string."),
  contentStyle = contentStyle ?? TextStyle(
      fontFamily: CoreBaseConfigState.configTextStyle.fontFamily,
      fontSize: 13,
      color: Colors.white,
      fontWeight: FontWeight.bold
      );

  final Object? title;
  final Color? borderColor;
  final List<Color> colors;
  final Function()? onTap;
  final double radius;
  final TextStyle contentStyle;
  final EdgeInsets padding;
  final bool enableShadow;
  final Object? iconLeading;
  final Object? iconTrailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
              color: borderColor ?? Colors.transparent, strokeAlign: 1),
          gradient: LinearGradient(
            colors: () {
              if(colors.isEmpty) return [Colors.black, Colors.black];
              if(colors.length < 2) return [colors[0], colors[0]];
              return colors;
            } (),
          ),
          boxShadow: [
            if(enableShadow) BoxShadow(
              color: colors[0].withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Padding(
              padding: padding,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (iconLeading != null)
                      Padding(
                        padding: EdgeInsets.only(right: title == null ? 6 : 0),
                        child: WidgetIcon(
                          icon: iconLeading!,
                          colors: [?contentStyle.color],
                          size: contentStyle.fontSize! * 1.2,
                        ),
                      ),
                    ConstrainedBox(
                      constraints:
                      BoxConstraints(maxWidth: width - 24 - padding.horizontal),
                      child: title is String
                        ? Text(title as String? ?? "", style: contentStyle)
                        : title as Widget? ?? const SizedBox(),
                    ),
                    if (iconTrailing != null)
                      Padding(
                        padding: EdgeInsets.only(left: title != "" ? 6 : 0),
                        child: WidgetIcon(
                          icon: iconTrailing!,
                          colors: [contentStyle.color ?? Colors.white],
                          size: contentStyle.fontSize! * 1.2,
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

extension EdgeInsetsFluent on EdgeInsets {
  EdgeInsets pVertical(double value) {
    return copyWith(top: value, bottom: value);
  }

  EdgeInsets pHorizontal(double value) {
    return copyWith(left: value, right: value);
  }

  EdgeInsets pAll(double value) {
    return EdgeInsets.all(value);
  }
}


