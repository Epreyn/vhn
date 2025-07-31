import 'package:flutter/material.dart';



class WidgetSizedBox extends StatelessWidget {

  Widget? widget;

  WidgetSizedBox(
      {
        Key? key,
        this.widget = null
      }
      ) : super(key: key);

  Widget isInput(value) {
    var result;

    if(value != null) {
      result = value;
    } else {
      result = SizedBox(width: 0, height: 0,);
    }

    return result;
  }


  @override
  Widget build(BuildContext context) {
    return isInput(widget);
  }
}
