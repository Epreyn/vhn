import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants/data.dart';
import '../../widgets/buttons/vhn_elevated_button.dart';
import '../../widgets/input_fields/vhn_input_field.dart';

void addDropDownItemPopup(context, itemType) {
  TextEditingController textEditingController = TextEditingController();

  final _fStore = FirebaseFirestore.instance;

  var deploy = kDeploy;

  String? initialValue;

  String collectionName = '';
  String title = '';
  String hintText = '';
  switch (itemType) {
    case 'Couleur':
      collectionName = 'couleurs';
      title = 'Ajouter une couleur';
      hintText = 'Nouvelle couleur';
      break;
    case 'Format':
      collectionName = 'formats';
      title = 'Ajouter un format';
      hintText = 'Nouveau format';
      break;
    case 'Conditionnement':
      collectionName = 'conditionnements';
      title = 'Ajouter un conditionnement';
      hintText = 'Nouveau conditionnement';
      break;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
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
      content: Container(
        width: 360,
        height: 70,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 180,
                  height: 70,
                  child: Column(
                    children: [
                      VhnInputField(
                        text: hintText,
                        controller: textEditingController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VhnElevatedButton(
                text: 'valider',
                onPress: () async {
                  await _fStore.collection('$collectionName').add({
                    'name': textEditingController.text,
                  });

                  Navigator.pop(context);
                }),
          ],
        ),
      ],
    ),
  );
}
