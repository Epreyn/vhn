import 'package:flutter/material.dart';
import 'package:vhn/widgets/input_fields/vhn_input_field.dart';

class InputSizedBox extends StatelessWidget {
  Widget? widget;

  InputSizedBox({Key? key, this.widget = null}) : super(key: key);

  Widget isInput(value) {
    var result;

    if (value.runtimeType == VhnInputField) {
      result = value;
    } else {
      result = SizedBox(
        width: 0,
        height: 0,
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return isInput(widget);
  }
}
