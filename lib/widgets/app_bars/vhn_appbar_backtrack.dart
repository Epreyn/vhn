import 'package:flutter/material.dart';

class VhnAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  Widget? titleWidget;
  Widget? leadingWidget;
  List<Widget>? actions;

  VhnAppBar({
    Key? key,
    this.height = kToolbarHeight,
    this.titleWidget,
    this.leadingWidget,
    this.actions,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leadingWidth: 200,
      backgroundColor: Colors.white,
      elevation: 0,
      title: titleWidget,
      leading: leadingWidget,
      actions: actions,
    );
  }
}
