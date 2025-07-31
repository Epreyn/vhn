import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/classes/spacing.dart';
import 'package:vhn/data/text_editing_controllers.dart';
import 'package:vhn/functions/add/add_dropdown_item_button.dart';
import 'package:vhn/functions/get/get_dropdownbutton_models.dart';
import 'package:vhn/functions/get/get_wine_input_field_models.dart';
import 'package:vhn/functions/validators/wineEntryValidator.dart';
import 'package:vhn/widgets/buttons/dropdown_button_maker.dart';
import 'package:vhn/widgets/buttons/vhn_icon_button.dart';
import 'package:vhn/widgets/input_fields/popup_input_field.dart';

import '../../models/wine.dart';
import '../../constants/data.dart';
import '../../data/wine_dropdown_values.dart';
import '../../widgets/buttons/vhn_elevated_button.dart';
import '../add/add_dropdown_item_popup.dart';

void editWinePopup(context, setState, wineData, domainID) {
  final _fStore = FirebaseFirestore.instance;

  Wine? wineToEdit;

  if (wineData != null) {
    wineToEdit = Wine(
        packaging: wineData['packaging'],
        cavistPrice: wineData['caviste'],
        color: wineData['color'],
        CHRPrice: wineData['chr'],
        cuvee: wineData['cuvee'],
        format: wineData['format'],
        quantity: wineData['quantity'],
        vintage: wineData['vintage']);
  }

  List<Widget> popupInputFields = [];
  List<Widget> dropDownButtons = [];

  for (var data in getWineInputFieldModels(wineToEdit).values) {
    popupInputFields.add(PopupInputField(dataPopupInputField: data));
    popupInputFields.add(Spacing.height(baseSpace));
  }

  for (var data
      in getDropDownButtonModels(setState, wineToEdit, context).values) {
    dropDownButtons.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 200,
            child: DropDownButtonMaker(
              model: data,
              buttonOption: 'add_dropdown_item',
              realTimeMode: true,
              width: 200,
            ),
          ),
          VhnIconButton(
            size: 40,
            icon: Icons.add,
            onPressed: () {
              addDropDownItemPopup(context, data.hint!);
            },
          )
        ],
      ),
    );
    dropDownButtons.add(Spacing.height(baseSpace));
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          wineData == null
              ? const Text('Ajouter un vin')
              : const Text('Modifier un vin'),
          IconButton(
            splashRadius: baseSpace * 3,
            iconSize: baseSpace * 3,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: popupInputFields,
          ),
          Column(
            children: dropDownButtons,
          ),
        ],
      ),
      actions: [
        Center(
          child: VhnElevatedButton(
              text: 'valider',
              onPress: () async {
                if (wineToEdit != null) {
                  wineToEdit = wineEntryValidator(
                    wineToEdit,
                    wineDropdownValues['color'],
                    wineDropdownValues['format'],
                    wineDropdownValues['packaging'],
                  );

                  await _fStore.collection('n_wines').doc(wineData['id']).set({
                    'color': wineToEdit!.color,
                    'cuvee': wineToEdit!.cuvee,
                    'format': wineToEdit!.format,
                    'packaging': wineToEdit!.packaging,
                    'prices': {
                      'caviste': wineToEdit!.cavistPrice,
                      'chr': wineToEdit!.CHRPrice,
                    },
                    'quantity': wineToEdit!.quantity.toString(),
                    'vintage': wineToEdit!.vintage,
                  }, SetOptions(merge: true));
                } else {
                  wineDropdownValues['color'] ?? '';
                  wineDropdownValues['format'] ?? '';
                  wineDropdownValues['packaging'] ?? '';

                  await _fStore.collection('n_wines').add({
                    'color': wineDropdownValues['color'],
                    'cuvee': wineEditingControllers['cuvee']!.text,
                    'domainID': domainID,
                    'format': wineDropdownValues['format'],
                    'packaging': wineDropdownValues['packaging'],
                    'prices': {
                      'caviste': wineEditingControllers['priceCellarMan']!.text,
                      'chr': wineEditingControllers['priceCHR']!.text,
                    },
                    'quantity': wineEditingControllers['quantity']!.text,
                    'vintage': wineEditingControllers['vintage']!.text,
                  });
                }

                Navigator.pop(context);
              }),
        ),
      ],
    ),
  );
}
