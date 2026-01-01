import 'package:core_base_bloc/base/base_context.dart';
import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_base_cubit.dart';

class WidgetButton extends StatelessWidget {
  WidgetButton({
    super.key,
    this.title,
    this.onTap,
    this.vertical,
    this.horizontal,
    this.colors = const [],
    this.contentStyle,
    this.borderColor,
    this.radius,
    this.iconLeading,
    this.iconTrailing,
  })  : assert(colors.isEmpty || colors.length <= 2, "The maximum number of 'colors' should not exceed two."),
        assert(title is Widget? || title is String?, "The 'title' can only be a widget or a string.");

  final Object? title;
  final Color? borderColor;
  final List<Color> colors;
  final Function()? onTap;
  final double? vertical, horizontal, radius;
  final TextStyle? contentStyle;
  final Object? iconLeading;
  final Object? iconTrailing;

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<CoreBaseCubit>().state.initBaseWidget?.configButton ?? ConfigButton();
    final TextStyle resultStyle =
        contentStyle ?? textStyleWithCtx(context).sColor(Colors.white).sSize(15).bold;
    final Object resultTitle = title ?? sys.title;
    final double resultVertical = vertical ?? sys.vertical;
    final double resultHorizontal = horizontal ?? sys.horizontal;
    final Color? resultBorderColor = borderColor ?? sys.borderColor?.resolve(context);
    final double resultRadius = radius ?? sys.radius;

    final List<Color> buttonColors = colors.isEmpty
        ? [sys.colors[0].resolve(context), sys.colors[0].resolve(context)]
        : colors.length == 1
        ? [colors[0], colors[0]]
        : colors;

    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(resultRadius),
          border: Border.all(
              color: resultBorderColor ?? Colors.transparent, strokeAlign: 1),
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
            borderRadius: BorderRadius.circular(resultRadius),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: resultVertical, horizontal: resultHorizontal),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (iconLeading != null)
                      Padding(
                        padding: EdgeInsets.only(right: resultTitle != "" ? 6 : 0),
                        child: WidgetIcon(
                          icon: iconLeading!,
                          colors: [?resultStyle.color],
                          size: resultStyle.fontSize! * 1.2,
                        ),
                      ),
                    ConstrainedBox(
                      constraints:
                      BoxConstraints(maxWidth: width - 24 - resultHorizontal),
                      child: title is String
                        ? Text(title as String, style: resultStyle)
                        : title as Widget,
                    ),
                    if (iconTrailing != null)
                      Padding(
                        padding: EdgeInsets.only(left: title != "" ? 6 : 0),
                        child: WidgetIcon(
                          icon: iconTrailing!,
                          colors: [?resultStyle.color],
                          size: resultStyle.fontSize! * 1.2,
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

