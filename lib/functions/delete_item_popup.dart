import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vhn/constants/data.dart';
import 'package:vhn/core/classes/spacing.dart';
import 'package:vhn/functions/show_snack_bar.dart';
import 'package:vhn/widgets/input_fields/vhn_input_field.dart';

import '../widgets/buttons/vhn_elevated_button.dart';

void deleteItemPopup(context, setState, itemType, itemData) {
  final _fStore = FirebaseFirestore.instance;

  String text;
  TextEditingController deleteController = TextEditingController();

  switch (itemType) {
    case 'WINE':
      text = itemData['cuvee'];
      break;
    case 'DOMAIN':
      text = itemData['name'];
      break;
    case 'REGION':
      text = itemData['name'];
      break;
    default:
      return;
  }

  showDialog(
      context: context,
      builder: (context) {
        bool canDelete = deleteController.text == 'SUPPRIMER';
        deleteController.addListener(() {
          if (canDelete != (deleteController.text == 'SUPPRIMER')) {
            canDelete = !canDelete;
            (context as Element).markNeedsBuild();
          }
        });

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Supprimer $text ?'),
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
              Text(
                'Pour supprimer, remplissez le champ ci-dessous avec le terme "SUPPRIMER :',
              ),
              Spacing.height(baseSpace * 2),
              VhnInputField(
                text: 'SUPPRIMER',
                controller: deleteController,
              ),
            ],
          ),
          actions: [
            VhnElevatedButton(
              text: 'Supprimer',
              color: canDelete ? Colors.red : Colors.grey,
              onPress: canDelete
                  ? () {
                      () async {
                        enableLoading(setState);

                        try {
                          switch (itemType) {
                            case 'REGION':
                              await _fStore.collection('n_regions').doc(itemData['id']).delete();

                              // QuerySnapshot domainSnapshot = await FirebaseFirestore.instance
                              //     .collection('n_domains')
                              //     .where('regionID', isEqualTo: itemData['id'])
                              //     .get();
                              //
                              // for (var domain in domainSnapshot.docs) {
                              //   QuerySnapshot wineSnapshot = await FirebaseFirestore.instance
                              //       .collection('n_wines')
                              //       .where('domainID', isEqualTo: domain.id)
                              //       .get();
                              //
                              //   await _fStore.collection('n_domains').doc(domain.id).delete();
                              //
                              //   for (var wine in wineSnapshot.docs) {
                              //     await _fStore.collection('n_wines').doc(wine.id).delete();
                              //   }
                              // }
                              Navigator.pop(context);

                              //DEBUG
                              break;
                            case 'DOMAIN':
                              // QuerySnapshot wineSnapshot = await FirebaseFirestore.instance
                              //     .collection('n_wines')
                              //     .where('domainID', isEqualTo: itemData['id'])
                              //     .get();

                              await _fStore.collection('n_domains').doc(itemData['id']).delete();

                              // for (var wine in wineSnapshot.docs) {
                              //   await _fStore.collection('n_wines').doc(wine.id).delete();
                              // }
                              Navigator.pop(context);
                              break;
                            case 'WINE':
                              await _fStore.collection('n_wines').doc(itemData['id']).delete();
                              Navigator.pop(context);
                              break;
                            default:
                              return;
                          }

                          disableLoading(setState);
                        } catch (e) {
                          disableLoading(setState);
                          showSnackBar(context, e.toString());
                        }
                      }();
                    }
                  : () {},
            )
          ],
        );
      });
}
