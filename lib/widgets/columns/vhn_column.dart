import 'package:flutter/material.dart';

class VhnColumn extends StatefulWidget {
  final List<Widget> widgets;
  final double width;
  final bool centered;

  const VhnColumn({
    Key? key,
    required this.widgets,
    required this.width,
    this.centered = true,
  }) : super(key: key);

  @override
  State<VhnColumn> createState() => _VhnColumnState();
}

class _VhnColumnState extends State<VhnColumn> {
  final scrollController = ScrollController(initialScrollOffset: 1);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.width,
        child: ListView.builder(
          controller: scrollController,
          physics: BouncingScrollPhysics(),
          shrinkWrap: widget.centered,
          itemCount: widget.widgets.length,
          itemBuilder: (context, index) {
            return widget.widgets[index];
          },
        ),
      ),
    );
  }
}
