

import 'package:core_base_bloc/core_base_bloc.dart';

class WidgetSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final List<Color> activeColor;
  final Color unActiveColor;
  final Color dotColor;

  const WidgetSwitch({super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const [Colors.orange],
    this.unActiveColor = Colors.black12,
    this.dotColor = Colors.white
  }) : assert(
      activeColor.length <= 2, "colors chỉ tối đa không vượt quá 2 màu"
  );

  @override
  State<WidgetSwitch> createState() => _WidgetSwitchState();
}

class _WidgetSwitchState extends State<WidgetSwitch> {
  @override
  Widget build(BuildContext context) {
    final List<Color> colorResult;
    if(widget.activeColor.isEmpty) {
      colorResult = [Colors.orange, Colors.orange];
    } else if(widget.activeColor.length == 1) {
      colorResult = [widget.activeColor[0], widget.activeColor[0]];
    } else {
      colorResult = widget.activeColor;
    }

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 34,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: widget.value
              ? LinearGradient(colors: colorResult)
              : LinearGradient(colors: [widget.unActiveColor.withValues(alpha: 0.2), widget.unActiveColor.withValues(alpha: 0.2)]),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment:
          widget.value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: EdgeInsetsGeometry.symmetric(horizontal: 5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}