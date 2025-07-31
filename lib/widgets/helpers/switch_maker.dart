import 'package:flutter/material.dart';

class SwitchMaker extends StatefulWidget {
  Map<String, bool> map;
  String mapKey;

  SwitchMaker({Key? key, required this.map, required this.mapKey}) : super(key: key);

  @override
  State<SwitchMaker> createState() => _SwitchMakerState();
}

class _SwitchMakerState extends State<SwitchMaker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.mapKey),
        Switch(
          value: widget.map[widget.mapKey]!,
          onChanged: (value) {
            setState(() {
              widget.map[widget.mapKey] = value;
            });
          },
        ),
      ],
    );
  }
}
