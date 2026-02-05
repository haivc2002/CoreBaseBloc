import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_app.dart';

class OverlayBottom extends StatelessWidget {
  const OverlayBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

Future<void> bottomSheet() async {
  showModalBottomSheet(
    context: navigatorKey.currentContext!,
    builder: (context) {
      return Text("data");
    }
  );
}
