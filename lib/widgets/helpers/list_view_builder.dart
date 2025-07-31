import 'package:flutter/material.dart';

class ListViewBuilder extends StatelessWidget {
  Widget widget;
  int count;
  int index;

  ListViewBuilder({Key? key, required this.widget, required this.count, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (BuildContext context, int a) {
        return widget;
      },
    );
  }
}
