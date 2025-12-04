import 'package:core_base_bloc/core_base_bloc.dart';

class OverlayDialog extends StatelessWidget {
  final Widget? content, bottom;
  final bool showBottom, showTitle;
  final String title;
  final TextStyle? styleTitle;
  final EdgeInsetsGeometry padding;
  const OverlayDialog({super.key,
    this.content,
    this.bottom,
    this.showBottom = true,
    this.showTitle = true,
    this.title = "Thông báo",
    this.styleTitle,
    this.padding = const EdgeInsets.all(20)
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastEaseInToSlowEaseOut,
        builder: (context, value, _) {
          return Transform.scale(
            scale: value,
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
                child: Padding(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(showTitle) SizedBox(
                        width: double.infinity,
                        child: Text(title, style: styleTitle ?? CoreStyle.def.bold.sSize(15), maxLines: 1),
                      ),
                      const SizedBox(height: 8),
                      Flexible(child: Padding(
                        padding: const EdgeInsetsGeometry.only(bottom: 10),
                        child: content ?? const SizedBox(),
                      )),
                      if(showBottom) bottom ?? SizedBox(
                        width: 100,
                        child: WidgetButton(
                          title: "Đóng",
                          contentStyle: CoreStyle.def.sColor(Colors.white),
                          vertical: 7,
                          onTap: ()=> Navigator.pop(context),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
