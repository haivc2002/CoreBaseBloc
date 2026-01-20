import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_base_app.dart';

enum StatusSnackBar {
  FAILURE,
  WARNING,
  SUCCESS
}

void snackBar({
  required StatusSnackBar status,
  required String message,
  String? title
}) {
  Color color = Colors.green;
  IconData icon = Icons.check_circle;
  final context = navigatorKey.currentContext!;

  switch(status) {
    case StatusSnackBar.FAILURE:
      color = Colors.red;
      title = title ?? "Thất bại";
      icon = Icons.error;
      break;
    case StatusSnackBar.WARNING:
      color = const Color(0xFFFAA134);
      title = title ?? "Thông báo";
      icon = Icons.warning_rounded;
      break;
    case StatusSnackBar.SUCCESS:
      color = Colors.green;
      title = title ?? "Thành công";
      icon = Icons.check_circle;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: GestureDetector(
        onTap: ()=> ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if(title.isNotEmpty) Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(message),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}