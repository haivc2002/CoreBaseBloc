

import 'package:core_base_bloc/base/base_context.dart';
import 'package:core_base_bloc/core_base_bloc.dart';

class WidgetCheckbox extends StatelessWidget {
  const WidgetCheckbox({super.key, required this.onChanged, required this.value, this.title, this.style, this.activeColor});

  final Function(bool?) onChanged;
  final bool value;
  final String? title;
  final TextStyle? style;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (value) => onChanged(value),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              activeColor: activeColor
            ),
            const SizedBox(width: 5),
            if(title != null) Expanded(child: Text(title!, style: style ?? textStyleWithCtx(context)))
          ],
        ),
      ),
    );
  }
}