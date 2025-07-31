import 'package:flutter/material.dart';
import 'package:vhn/constants/style/text_style.dart';

import '../../../../core/classes/spacing.dart';

class CellMaker extends StatelessWidget {
  String text;
  Icon? icon;
  Color? iconColor;
  double? width;
  int maxLine;

  CellMaker({Key? key, required this.text, this.icon = null, this.iconColor, this.width = null, this.maxLine = 1})
      : super(key: key);

  Icon? iconIsNull(icon) {
    var result = icon == null ? Icon(null) : icon;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: width != null ? width : null,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: kDataCellTextStyle,
                maxLines: maxLine,
              ),
              iconIsNull(icon)!,
              Spacing.width(44)
            ],
          ),
        ),
      ),
    );
  }
}
