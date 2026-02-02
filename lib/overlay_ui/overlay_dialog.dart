import 'package:core_base_bloc/core_base_bloc.dart';

class OverlayDialog extends StatelessWidget {
  final bool showBottom, showTitle;
  final OverlayDialogTitle dialogTitle;
  final OverlayDialogBody dialogBody;
  final OverlayDialogBottom dialogBottom;

  OverlayDialog({super.key,
    this.showBottom = true,
    this.showTitle = true,
    OverlayDialogTitle? dialogTitle,
    OverlayDialogBody? dialogBody,
    OverlayDialogBottom? dialogBottom,
  }) : dialogBody = dialogBody ?? OverlayDialogBody(),
       dialogTitle = dialogTitle ?? OverlayDialogTitle(),
       dialogBottom = dialogBottom ?? OverlayDialogBottom();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Dialog(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if(showTitle) ColoredBox(
                color: dialogTitle.backgroundColor,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: dialogTitle.padding,
                    child: dialogTitle.title is String
                        ? Text(dialogTitle.title as String, style: Theme.of(context).textTheme.labelMedium?.bold.sSize(15).sColor(Colors.black), maxLines: 1)
                        : dialogTitle.title as Widget,
                  ),
                ),
              ),
              Flexible(child: ColoredBox(
                color: dialogBody.backgroundColor,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: dialogBody.padding,
                    child: dialogBody.body,
                  ),
                ),
              )),
              if(showBottom) ColoredBox(
                color: dialogBottom.backgroundColor,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: dialogBottom.padding,
                    child: dialogBottom.bottom,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OverlayDialogTitle {
  Object title;
  Color backgroundColor;
  EdgeInsets padding;

  OverlayDialogTitle({
    this.title = "Thông báo",
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 9)
  }) : assert(title is String || title is Widget,
  'title must be a String or a Widget');
}

class OverlayDialogBody {
  Widget body;
  EdgeInsets padding;
  Color backgroundColor;

  OverlayDialogBody({
    this.body = const SizedBox(),
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.only(bottom: 10, top: 8, right: 15, left: 15)
  });
}

class OverlayDialogBottom {
  Widget bottom;
  EdgeInsets padding;
  Color backgroundColor;

  OverlayDialogBottom({
    Widget? bottom,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.only(left: 15, right: 15, top: 7, bottom: 17)
  }) : bottom = Center(
    child: bottom ?? Builder(
        builder: (context) {
          return SizedBox(
            width: 100,
            child: WidgetButton(
              title: "Đóng",
              contentStyle: Theme.of(context).textTheme.labelMedium?.sColor(Colors.white).bold,
              onTap: back,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            ),
          );
        }
    ),
  );
}
