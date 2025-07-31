import 'package:flutter/material.dart';
import 'package:vhn/models/popup_input_field_model.dart';

import 'vhn_input_field.dart';

class PopupInputField extends StatelessWidget {
  PopupInputFieldModel? dataPopupInputField;

  double? bottomSpacing;

  PopupInputField({
    Key? key,
    this.dataPopupInputField,
    this.bottomSpacing = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VhnInputField(
      text: dataPopupInputField!.placeHolder,
      onTap: () {},
      controller: dataPopupInputField!.textEditingController,
    );
  }
}
