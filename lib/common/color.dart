import 'package:core_base_bloc/core_base_bloc.dart';

extension ColorOpacity on Color {
  Color get op0 => withValues(alpha: 0.0);
  Color get op1 => withValues(alpha: 0.1);
  Color get op2 => withValues(alpha: 0.2);
  Color get op3 => withValues(alpha: 0.3);
  Color get op4 => withValues(alpha: 0.4);
  Color get op5 => withValues(alpha: 0.5);
  Color get op6 => withValues(alpha: 0.6);
  Color get op7 => withValues(alpha: 0.7);
  Color get op8 => withValues(alpha: 0.8);
  Color get op9 => withValues(alpha: 0.9);
  Color get op10 => withValues(alpha: 1.0);
  Color op(double value) => withValues(alpha: value);
}

