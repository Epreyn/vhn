import 'package:flutter/material.dart';
import 'package:vhn/models/dropdownbutton_model.dart';
import 'package:vhn/constants/data.dart';

import '../../data/wine_dropdown_values.dart';
import '../add/add_dropdown_item_popup.dart';

Map<String, DropDownButtonModel> getDropDownButtonModels(setState, wineToEdit, BuildContext context) {
  var dropDownButtonValues = wineDropdownValues;

  wineToEdit != null ? dropDownButtonValues['color'] = wineToEdit.color : dropDownButtonValues['color'];

  wineToEdit != null ? dropDownButtonValues['format'] = wineToEdit.format : dropDownButtonValues['format'];

  wineToEdit != null ? dropDownButtonValues['packaging'] = wineToEdit.packaging : dropDownButtonValues['packaging'];

  Map<String, DropDownButtonModel> dropDownButtonMap = {
    'color': DropDownButtonModel(
        hint: 'Couleur',
        items: kWineColors,
        initialValue: dropDownButtonValues['color'],
        onChanged: (String? value) {
          setState(() {
            dropDownButtonValues['color'] = value!;
          });
        }),
    'format': DropDownButtonModel(
        hint: 'Format',
        items: kWineFormats,
        initialValue: dropDownButtonValues['format'],
        onChanged: (String? value) {
          setState(() {
            dropDownButtonValues['format'] = value!;
          });
        }),
    'packaging': DropDownButtonModel(
        hint: 'Conditionnement',
        items: kWinepackaging,
        initialValue: dropDownButtonValues['packaging'],
        onChanged: (String? value) {
          setState(() {
            dropDownButtonValues['packaging'] = value!;
          });
        }),
  };

  return dropDownButtonMap;
}
