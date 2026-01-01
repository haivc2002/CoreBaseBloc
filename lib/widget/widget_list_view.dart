

import 'package:core_base_bloc/core_base_bloc.dart';

class WidgetListView extends StatelessWidget {
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final List<Widget>? children;
  final IndexedWidgetBuilder? itemBuilder;
  final int? itemCount;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function()? onRefresh;
  final Color onRefreshColor;

  const WidgetListView._({
    super.key,
    this.controller,
    this.physics,
    this.children,
    this.itemBuilder,
    this.itemCount,
    this.onRefresh,
    this.padding,
    this.onRefreshColor = Colors.orange
  });

  factory WidgetListView({
    Key? key,
    ScrollController? controller,
    ScrollPhysics? physics,
    Color onRefreshColor = Colors.orange,
    required List<Widget> children,
    Future<void> Function()? onRefresh,
    EdgeInsetsGeometry? padding
  }) {
    return WidgetListView._(
      key: key,
      controller: controller,
      physics: physics,
      onRefresh: onRefresh,
      onRefreshColor: onRefreshColor,
      padding: padding,
      children: children,
    );
  }

  factory WidgetListView.builder({
    Key? key,
    ScrollController? controller,
    ScrollPhysics? physics,
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    Color onRefreshColor = Colors.orange,
    EdgeInsetsGeometry? padding,
    Future<void> Function()? onRefresh
  }) {
    return WidgetListView._(
      key: key,
      controller: controller,
      physics: physics,
      onRefresh: onRefresh,
      onRefreshColor: onRefreshColor,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    if(onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh!(),
        // color: MyColor.lavenderPink,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _body()
      );
    } else {
      return _body();
    }
  }

  Widget _body() {
    final ScrollPhysics effectivePhysics = physics ?? const BouncingScrollPhysics().applyTo(const AlwaysScrollableScrollPhysics());
    final EdgeInsetsGeometry defPadding = padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 20);

    if (itemBuilder != null && itemCount != null) {
      return ListView.builder(
        controller: controller,
        physics: effectivePhysics,
        itemCount: itemCount,
        padding: defPadding,
        itemBuilder: (context, index) {
          return itemBuilder!(context, index);
        },
      );
    } else {
      final List<Widget> safeChildren = children ?? [];
      return ListView(
        controller: controller,
        physics: effectivePhysics,
        padding: defPadding,
        children: safeChildren,
      );
    }
  }
}