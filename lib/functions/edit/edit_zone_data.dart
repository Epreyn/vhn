import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vhn/functions/validators/string_value_checker.dart';

import '../../../../core/classes/spacing.dart';
import '../../constants/data.dart';
import '../../models/dropdownbutton_model.dart';
import '../../widgets/buttons/dropdown_button_maker.dart';
import '../../widgets/buttons/vhn_elevated_button.dart';
import '../../widgets/helpers/switch_maker.dart';
import '../../widgets/input_fields/vhn_input_field.dart';

/// Convertit un code de département en double "logique"
/// pour trier correctement:
///  - 2A => 20.0
///  - 2B => 20.5
///  - tout autre code => extraction numérique, sinon 9999
double mapDept(String code) {
  if (code == '2A') return 20.0;
  if (code == '2B') return 20.5;

  final match = RegExp(r'^\d+').firstMatch(code);
  if (match != null) {
    return double.parse(match.group(0)!);
  }
  return 9999;
}

/// Comparateur personnalisé utilisant mapDept
int customDeptCompare(String a, String b) {
  return mapDept(a).compareTo(mapDept(b));
}

/// Affiche la modale pour éditer les données d'une zone (REGION ou DOMAIN).
/// [dataMap] : données actuelles de la zone
/// [zone] : 'REGION' ou 'DOMAIN'
/// [zoneID] : l'ID Firestore de la zone
void editZoneData(
  BuildContext context,
  void Function(VoidCallback fn) setState,
  Map dataMap,
  String zone,
  String zoneID,
) async {
  final _fStore = FirebaseFirestore.instance;

  // Contrôleur pour le champ nom
  TextEditingController nameController = TextEditingController();
  nameController.text = dataMap['name'] ?? '';

  String? initialValue;
  String? _status = '';

  // Liste de facturation possible
  List<String> items = ['VHL', 'VHN', 'Domaine'];

  /// ---------------------------------------------------------------------------
  /// Logique DOMAINE : récupérer et trier le déploiement
  /// ---------------------------------------------------------------------------
  // On ne s’en occupe que si zone != 'REGION'
  Map<String, bool> sortedDeployMap = {};

  if (zone != 'REGION') {
    // dataMap['deploy'] peut être null (ou inexistant) => on crée une map vide si null
    Map<String, bool> deployMap = {};
    if (dataMap['deploy'] != null) {
      // Cast prudent
      deployMap = Map<String, bool>.from(dataMap['deploy']);
    }

    // 1) On exclut "20"
    // 2) On force l'ajout de 2A / 2B si "20" existait
    List<String> deptKeys = deployMap.keys.where((k) => k != '20').toList();
    if (deployMap.containsKey('20')) {
      if (!deptKeys.contains('2A')) deptKeys.add('2A');
      if (!deptKeys.contains('2B')) deptKeys.add('2B');
    }

    // Tri personnalisé
    deptKeys.sort(customDeptCompare);

    // Construction du nouveau map trié, en ignorant "20"
    for (var key in deptKeys) {
      // Si c’est 2A ou 2B, on pique la valeur de "20" si disponible
      if ((key == '2A' || key == '2B') && deployMap.containsKey('20')) {
        sortedDeployMap[key] = deployMap['20'] ?? false;
      } else {
        // Cas normal
        sortedDeployMap[key] = deployMap[key] ?? false;
      }
    }

    // On remet sortedDeployMap dans dataMap
    dataMap['deploy'] = sortedDeployMap;

    // On récupère également la facturation
    initialValue = dataMap['invoice'] as String?;
    _status = initialValue;
  }

  /// ---------------------------------------------------------------------------
  /// Ouverture de la boîte de dialogue
  /// ---------------------------------------------------------------------------
  if (zone != 'REGION') {
    //  =============== D O M A I N E ===============
    final invoiceModel = DropDownButtonModel(
      hint: 'Facturation',
      items: items,
      initialValue: initialValue,
      onChanged: (String? value) {
        setState(() => _status = value);
      },
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Modifier le domaine'),
            IconButton(
              splashRadius: baseSpace * 3,
              iconSize: baseSpace * 3,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.red),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VhnInputField(
              text: 'Nom du domaine',
              controller: nameController,
            ),
            Spacing.height(baseSpace),
            Column(
              children: [
                // Dropdown facturation
                DropDownButtonMaker(model: invoiceModel, width: 200),
                Spacing.height(baseSpace),
                // Conteneur pour la liste des départements
                Container(
                  height: 200,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(baseSpace / 2),
                    border: Border.all(color: Colors.black54),
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Spacing.height(baseSpace),
                        const Center(child: Text('Départements')),
                        Spacing.height(baseSpace),
                        for (var key in sortedDeployMap.keys) SwitchMaker(map: sortedDeployMap, mapKey: key),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          VhnElevatedButton(
            text: 'valider',
            onPress: () async {
              // Vérification du nom (si champ vide, on remet ancien nom)
              String zoneName = stringValueChecker(
                nameController.text,
                dataMap['name'],
              );

              // Mise à jour Firestore DOMAINE
              await _fStore.collection('n_domains').doc(zoneID).set(
                {
                  'name': zoneName,
                  'deploy': sortedDeployMap,
                  'invoice': _status ?? '',
                },
                SetOptions(merge: true),
              );

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  } else {
    //  =============== R E G I O N ===============
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Modifier la région'),
            IconButton(
              splashRadius: baseSpace * 3,
              iconSize: baseSpace * 3,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.red),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VhnInputField(
              text: 'Nom de la région',
              controller: nameController,
            ),
          ],
        ),
        actions: [
          VhnElevatedButton(
            text: 'valider',
            onPress: () async {
              String zoneName = stringValueChecker(
                nameController.text,
                dataMap['name'],
              );

              // Mise à jour Firestore REGION
              await _fStore.collection('n_regions').doc(zoneID).set(
                {
                  'name': zoneName,
                  // On réutilise l'index si présent dans dataMap
                  'index': dataMap['index'],
                },
                SetOptions(merge: true),
              );

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
