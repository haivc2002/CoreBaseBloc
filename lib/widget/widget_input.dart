import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:flutter/services.dart';

class WidgetInput extends StatelessWidget {
  WidgetInput({super.key,
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
    double? radius, Color? fillColor,
    Color? enabledBorderColor, Color? focusedBorderColor
  }) : radius = radius ?? d.radius,
       fillColor = fillColor ?? d.fillColor,
       focusedBorderColor = focusedBorderColor ?? d.focusBorderColor,
       enabledBorderColor = enabledBorderColor ?? d.enableBorderColor,
       assert(
  autoSelectAll == false || controller != null,
  'Để sử dụng autoSelectAll = true thì phải truyền controller!',
  );

  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled, obscureText, tick;
  final TextInputType? keyboardType;
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
  final Color fillColor, enabledBorderColor, focusedBorderColor;

  static ConfigInput get d => CoreBaseConfig.instance.configInput ?? ConfigInput();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          if(title != null && (title??'').isNotEmpty) Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(title??'', style: CoreStyle.def),
          ),
          const SizedBox(width: 5),
          if(tick!) Text("*", style: CoreStyle.def.sColor(Colors.red).sSize(18))
        ]),
        TextField(
          textAlign: textAlign,
          cursorColor: d.cursorColor,
          enabled: enabled,
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
                  icon: suffixIcon!.icon is Icon
                      ? suffixIcon!.icon as Icon
                      : WidgetIcon(icon: suffixIcon!.icon),
                ),
              ),
            ) : null,
            hintStyle: hintStyle ?? CoreStyle.def.sColor(d.hintColor).regular,
            hintText: !hintTextAnimation ? hintText ?? '' : null,
            label: hintTextAnimation ? Text(hintText ?? "",
                style: hintStyle ?? CoreStyle.def.sColor((validateValue??'').isNotEmpty
                    ? d.alertColor
                    : d.hintColor
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
                borderSide: BorderSide(color: (validateValue??'').isNotEmpty ? d.alertColor : enabledBorderColor),
                borderRadius: BorderRadius.circular(radius)
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: (validateValue??'').isNotEmpty ? d.alertColor : focusedBorderColor),
                borderRadius: BorderRadius.circular(radius)
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
          child: (validateValue != null && (validateValue ?? '').isNotEmpty) ? Text(
            validateValue!,
            style: CoreStyle.def.sColor(Colors.red).medium.sSize(12),
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