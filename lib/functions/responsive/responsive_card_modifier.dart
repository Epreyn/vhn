import 'package:flutter/material.dart';

Widget responsiveCardModifier(Widget widgetA, Widget widgetB, double width) {
  Widget responsiveWidget = SizedBox();

  if (width > 500) {
    responsiveWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: widgetA,
        ),
        // Expanded(
        //   flex: 1,
        //   child: widgetB,
        // ),
      ],
    );
  } else {
    responsiveWidget = Column(
      children: [
        widgetA,
        // widgetB,
      ],
    );
  }

  return responsiveWidget;
}
