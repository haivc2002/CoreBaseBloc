import 'package:core_base_bloc/base/base_context.dart';
import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_base_cubit.dart';
import 'package:flutter/services.dart';

class WidgetInput extends StatelessWidget {
  const WidgetInput({super.key,
    this.enabled, this.keyboardType,
    this.maxLines, this.controller,
    this.hintText, this.hintStyle,
    this.suffixIcon, this.obscureText, this.prefixIcon,
    this.validateValue, this.title, this.maxLength,
    this.onChange, this.tick = false,
    this.focusNode, this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.hintTextAnimation = true,
    this.autoSelectAll = false,
    this.contentPadding, this.onSubmitted,
    this.fillColor, this.radius, this.enabledBorderColor,
    this.focusedBorderColor, this.textStyle
  }) : assert(
  autoSelectAll == false || controller != null,
  'Để sử dụng autoSelectAll = true thì phải truyền controller!',
  );

  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled, obscureText, tick;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;
  final int? maxLines, maxLength;
  final TextEditingController? controller;
  final String? hintText, validateValue, title;
  final TextStyle? hintStyle;
  final Widget? prefixIcon;
  final Function(String)? onChange;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final SuffixIcon? suffixIcon;
  final bool hintTextAnimation, autoSelectAll;
  final EdgeInsetsGeometry? contentPadding;
  final Function(String)? onSubmitted;
  final double? radius;
  final Color? fillColor, enabledBorderColor, focusedBorderColor;

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<CoreBaseCubit>().state.initBaseWidget?.configInput ?? ConfigInput();
    final resultRadius = radius ?? sys.radius;
    final resultFillColor = fillColor ?? sys.fillColor.resolve(context);
    final resultFocusedBorderColor = focusedBorderColor ?? sys.focusBorderColor.resolve(context);
    final resultEnabledBorderColor = enabledBorderColor ?? sys.enableBorderColor.resolve(context);
    final styleDef = context.watch<CoreBaseCubit>().state.initBaseWidget?.configTextStyle;
    final resultStyle = textStyle ?? TextStyle(
      fontSize: styleDef?.fontSize,
      color: styleDef?.color?.resolve(context),
      fontFamily: styleDef?.fontFamily,
      fontWeight: styleDef?.fontWeight
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          if(title != null && (title??'').isNotEmpty) Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(title??'', style: textStyleWithCtx(context)),
          ),
          const SizedBox(width: 5),
          if(tick!) Text("*", style: textStyleWithCtx(context).sColor(Colors.red).sSize(18))
        ]),
        TextField(
          textAlign: textAlign,
          cursorColor: sys.cursorColor.resolve(context),
          enabled: enabled,
          style: resultStyle,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          keyboardType: keyboardType ?? TextInputType.text,
          obscureText: obscureText ?? false,
          controller: controller,
          maxLines: maxLines ?? 1,
          maxLength: maxLength,
          textInputAction: onSubmitted != null ? TextInputAction.search : null,
          onSubmitted: onSubmitted,
          onChanged: (value) { if (onChange != null) onChange!(value); },
          onTap: () {
            if(!autoSelectAll) return;
            controller?.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller!.text.length,
            );
          },
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: resultFillColor,
            contentPadding: contentPadding ?? const EdgeInsets.fromLTRB(20, 15, 20, 19),
            suffixIcon: suffixIcon != null ? IntrinsicWidth(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 10),
                child: IconButton(
                  onPressed: suffixIcon!.onPressed,
                  icon: suffixIcon!.icon is Icon
                      ? suffixIcon!.icon as Icon
                      : WidgetIcon(icon: suffixIcon!.icon),
                ),
              ),
            ) : null,
            hintStyle: hintStyle ?? textStyleWithCtx(context).sColor(sys.hintColor.resolve(context)).regular,
            hintText: !hintTextAnimation ? hintText ?? '' : null,
            label: hintTextAnimation ? Text(hintText ?? "",
                style: hintStyle ?? textStyleWithCtx(context).sColor((validateValue??'').isNotEmpty
                    ? sys.alertColor.resolve(context)
                    : sys.hintColor.resolve(context)
                ).regular
            ) : null,
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 15, right: 8),
              child: prefixIcon,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: (validateValue??'').isNotEmpty ? sys.alertColor.resolve(context) : resultEnabledBorderColor),
                borderRadius: BorderRadius.circular(resultRadius)
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: (validateValue??'').isNotEmpty ? sys.alertColor.resolve(context) : resultFocusedBorderColor),
                borderRadius: BorderRadius.circular(resultRadius)
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
          child: (validateValue != null && (validateValue ?? '').isNotEmpty) ? Text(
            validateValue!,
            style: textStyleWithCtx(context).sColor(Colors.red).medium.sSize(12),
          ) : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class SuffixIcon {
  final Function()? onPressed;
  final Object icon;
  SuffixIcon({
    this.onPressed,
    required this.icon
  });
}