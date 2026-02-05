import 'dart:io';

import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:core_base_bloc/core_config/core_app.dart';
import 'package:flutter/cupertino.dart';

class OverlayDialog extends StatelessWidget {

  static DialogType dialogTypeDefault = DialogType.auto;

  final DialogType dialogType;
  final String title;
  final Widget body;
  final List<DialogAction> actions;

  OverlayDialog({
    super.key,
    DialogType? dialogType,
    this.title = "",
    this.body = const SizedBox(),
    this.actions = const [],
  }) : dialogType = dialogType ?? dialogTypeDefault;

  @override
  Widget build(BuildContext context) {
    print(dialogType);
    if(dialogType == DialogType.android) {
      return dialogWithAndroid;
    } else if(dialogType == DialogType.ios) {
      return dialogWithIOS;
    } else {
      return Platform.isIOS
        ? dialogWithIOS
        : dialogWithAndroid;
    }
  }

  Widget get dialogWithIOS {
    return CupertinoAlertDialog(
      title: Text(title, style: TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w600
      )),
      content: body,
      actions: [
        if(actions.isEmpty) CupertinoDialogAction(
          onPressed: back,
          child: const Text('Đóng', style: TextStyle(color: Color(0xFF1947FF))),
        ) else ...actions.map((item) {
          return CupertinoDialogAction(
            onPressed: item.onTap,
            child: Text(item.title,
                style: TextStyle(color: item.color)
            ),
          );
        },)
      ]
    );
  }

  Widget get dialogWithAndroid {
    return Builder(
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 1.8,
                maxWidth: 450
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(title != "") Center(
                    child: Text(title, style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600
                    )),
                  ),
                  // Flexible(child: SizedBox(
                  //   width: double.infinity,
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  //     child: body,
                  //   ),
                  // )),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Center(child: body),
                    ),
                  ),
                  if(actions.isEmpty) Center(
                    child: TextButton(
                      onPressed: back,
                      child: Text("Đóng", style: TextStyle(color: Color(0xFF1947FF)))
                    )
                  )
                  else if(actions.isNotEmpty && actions.length <= 2)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Row(children: actions.map((item) {
                        return Expanded(
                          child: Center(
                            child: TextButton(
                              onPressed: item.onTap,
                                style: TextButton.styleFrom(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(item.title,
                                style: TextStyle(color: item.color),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            ),
                          ),
                        );
                      }).toList()),
                    )
                  else ...actions.map((item) {
                    return TextButton(
                      onPressed: item.onTap,
                      style: TextButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(item.title,
                        style: TextStyle(color: item.color),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    );
                  })
                ],
              ),
            ),
          ),
        );
      }
    );
  }

}

class DialogAction {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const DialogAction({
    required this.title,
    required this.onTap,
    this.color = const Color(0xFF1947FF)
  });
}

enum DialogType {
  android,
  ios,
  auto
}

final _context = navigatorKey.currentContext!;

Future<void> dialog({
  DialogType dialogType = DialogType.auto,
  String title = "",
  Widget body = const SizedBox(),
  List<DialogAction> actions = const [],
}) => showCupertinoDialog(context: _context, builder: (_) {
  return OverlayDialog(
    dialogType: dialogType,
    body: body,
    title: title,
    actions: actions,
  );
});

Future<void> openLoading() {
  return showCupertinoDialog(
    barrierColor: Colors.black26,
    context: _context,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Material(
          color: Colors.transparent,
          child: Center(child: DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: WidgetWait(color: Colors.white),
            ),
          )),
        ),
      );
    },
  );
}

void closeLoading() => back();