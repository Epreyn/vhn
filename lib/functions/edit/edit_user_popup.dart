import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vhn/constants/data.dart';
import 'package:vhn/functions/show_snack_bar.dart';
import 'package:vhn/widgets/input_fields/popup_input_field.dart';

import '../../../../core/classes/spacing.dart';
import '../../data/text_editing_controllers.dart';
import '../../widgets/buttons/vhn_elevated_button.dart';
import '../get/get_popup_input_field_user_models.dart';

void editUserPopup(context, setState, userData) {
  String department;
  String telephone;
  String address;
  String postalCode;
  String city;
  String company;

  final _fStore = FirebaseFirestore.instance;

  List<Widget> popupInputFields = [];

  // Si l'utilisateur existe on donne aux champs de saisie les valeurs actuelles par défaut
  userEditingControllers['company']!.text = userData['company'];
  userEditingControllers['department']!.text = userData['department'];
  userEditingControllers['telephone']!.text = userData['telephone'];
  userEditingControllers['address']!.text = userData['address'];
  userEditingControllers['postalCode']!.text = userData['postal_code'];
  userEditingControllers['city']!.text = userData['city'];

  for (var data in getUserPopupInputFieldModels().values) {
    popupInputFields.add(PopupInputField(dataPopupInputField: data));
    popupInputFields.add(Spacing.height(baseSpace));
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Modifier un utilisateur'),
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
        children: popupInputFields,
      ),
      actions: [
        VhnElevatedButton(
            text: 'valider',
            onPress: () async {
              enableLoading(setState);
              company = userEditingControllers['company']!.text;
              department = userEditingControllers['department']!.text;
              telephone = userEditingControllers['telephone']!.text;
              address = userEditingControllers['address']!.text;
              postalCode = userEditingControllers['postalCode']!.text;
              city = userEditingControllers['city']!.text;

              try {
                await _fStore.collection('utilisateurs').doc(userData['id']).set({
                  'adresse': address,
                  'code postal': postalCode,
                  'département': department,
                  'entreprise': company,
                  'téléphone': telephone,
                  'ville': city,
                }, SetOptions(merge: true));
              } catch (e) {
                disableLoading(setState);
                showSnackBar(context, e.toString());
              }

              disableLoading(setState);
              Navigator.pop(context);
            })
      ],
    ),
  );
}
