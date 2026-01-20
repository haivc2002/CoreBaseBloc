

import 'dart:io';

import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';

enum WidgetListViewType {
  auto,
  android,
  ios
}

class WidgetListView extends StatelessWidget {
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final List<Widget>? children;
  final IndexedWidgetBuilder? itemBuilder;
  final int? itemCount;
  final EdgeInsetsGeometry? padding;
  final WidgetListViewType listViewType;
  final Future<void> Function()? onRefresh;
  final Color? onRefreshColor;

  const WidgetListView._({
    super.key,
    this.controller,
    this.physics,
    this.children,
    this.itemBuilder,
    this.itemCount,
    this.onRefresh,
    this.padding,
    this.listViewType = WidgetListViewType.auto,
    this.onRefreshColor
  });

  factory WidgetListView({
    Key? key,
    ScrollController? controller,
    ScrollPhysics? physics,
    Color onRefreshColor = Colors.grey,
    required List<Widget> children,
    Future<void> Function()? onRefresh,
    WidgetListViewType listViewType = WidgetListViewType.auto,
    EdgeInsetsGeometry? padding
  }) {
    return WidgetListView._(
      key: key,
      controller: controller,
      physics: physics,
      onRefresh: onRefresh,
      onRefreshColor: onRefreshColor,
      listViewType: listViewType,
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
    WidgetListViewType listViewType = WidgetListViewType.auto,
    Future<void> Function()? onRefresh
  }) {
    return WidgetListView._(
      key: key,
      controller: controller,
      physics: physics,
      onRefresh: onRefresh,
      onRefreshColor: onRefreshColor,
      itemBuilder: itemBuilder,
      listViewType: listViewType,
      itemCount: itemCount,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollPhysics effectivePhysics = physics ?? const BouncingScrollPhysics().applyTo(const AlwaysScrollableScrollPhysics());
    final EdgeInsetsGeometry defPadding = padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 20);

    return CustomRefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      builder: (context, child, controller) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            TweenAnimationBuilder(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0, end: controller.isLoading ? 30 : 0),
                curve: Curves.ease,
                builder: (context, value, _) {
                  return Padding(
                    padding: EdgeInsets.only(top: value + (controller.value * 18)),
                    child: child,
                  );
                }
            ),
            Positioned(
              top: 13.0,
              child: Opacity(
                opacity: controller.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: controller.value.clamp(0.8, 1.0),
                  child: Center(child: Offstage(
                    offstage: onRefresh == null,
                    child: _progress
                  ))
                ),
              ),
            ),
          ],
        );
      },
      child: () {
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
      } (),
    );

  }

  Widget get _progress {
    if(listViewType == WidgetListViewType.android) {
      return RefreshProgressIndicator(
        backgroundColor: Colors.white,
        color: onRefreshColor,
      );
    } else if(listViewType == WidgetListViewType.ios) {
      return CupertinoActivityIndicator(
        color: onRefreshColor,
        radius: 14,
      );
    } else {
      if(Platform.isIOS) {
        return CupertinoActivityIndicator(
          color: onRefreshColor,
          radius: 14,
        );
      } else {
        return RefreshProgressIndicator(
          backgroundColor: Colors.white,
          color: onRefreshColor,
        );
      }
    }
  }
}