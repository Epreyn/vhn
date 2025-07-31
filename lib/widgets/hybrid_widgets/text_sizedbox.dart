import 'package:flutter/material.dart';

class TextSizedBox extends StatelessWidget {

  Widget? widget;

       TextSizedBox(
      {
        Key? key,
        this.widget = null
      }
      ) : super(key: key);

  Widget isText(value) {
     var result;

     if(value.runtimeType == Text) {
       result = value;
     } else {
       result = SizedBox(width: 0, height: 0,);
     }

    return result;
  }
  

  @override
  Widget build(BuildContext context) {
    return this.isText(widget);
  }
}
