import 'package:core_base_bloc/core_base_bloc.dart';
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
    this.fillColor = Colors.white, this.radius = 10, this.enabledBorderColor = Colors.transparent,
    this.alertColor = Colors.red,
    this.focusedBorderColor = Colors.grey, this.textStyle, this.cursorColor = Colors.blue
  }) : assert(
  autoSelectAll == false || controller != null,
  'To use autoSelectAll = true, you must pass the controller!',
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
  final double radius;
  final Color fillColor,
      enabledBorderColor,
      focusedBorderColor,
      alertColor,
      cursorColor;

  @override
  Widget build(BuildContext context) {
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
          cursorColor: cursorColor,
          enabled: enabled,
          style: textStyle ?? textStyleWithCtx(context).sColor(Colors.black),
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
            fillColor: fillColor,
            contentPadding: contentPadding ?? const EdgeInsets.fromLTRB(20, 15, 20, 19),
            suffixIcon: suffixIcon != null ? IntrinsicWidth(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 10),
                child: IconButton(
                  onPressed: suffixIcon!.onPressed,
                  icon: WidgetIcon(icon: suffixIcon!.icon, colors: [?suffixIcon!.color],),
                ),
              ),
            ) : null,
            hintStyle: hintStyle ?? textStyleWithCtx(context).sColor(Colors.grey).regular,
            hintText: !hintTextAnimation ? hintText ?? '' : null,
            label: hintTextAnimation ? Text(hintText ?? "",
                style: hintStyle ?? textStyleWithCtx(context).sColor((validateValue??'').isNotEmpty
                    ? alertColor
                    : hintStyle?.color ?? Colors.grey
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
                borderSide: BorderSide(color: (validateValue??'').isNotEmpty
                    ? alertColor
                    : enabledBorderColor
                ),
                borderRadius: BorderRadius.circular(radius)
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: (validateValue??'').isNotEmpty ? alertColor : focusedBorderColor),
                borderRadius: BorderRadius.circular(radius)
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
  final Color? color;
  SuffixIcon({
    this.onPressed,
    required this.icon,
    this.color
  }) : assert(
  icon is IconData || icon is String,
  'icon must be `IconData` or `String`',
  );
}