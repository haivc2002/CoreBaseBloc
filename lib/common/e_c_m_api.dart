import 'package:core_base_bloc/core_base_bloc.dart';

class ECMapi {
  final Widget errorWidget;
  final bool isError;

  const ECMapi._({
    this.errorWidget = const SizedBox(),
    this.isError = false,
  });

  factory ECMapi.success() => const ECMapi._(isError: false);

  factory ECMapi.failure({required Widget errorWidget}) =>
      ECMapi._(isError: true, errorWidget: errorWidget);

  factory ECMapi.end() => const ECMapi._(isError: false);
}