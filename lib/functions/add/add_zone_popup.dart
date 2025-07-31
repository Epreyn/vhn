import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vhn/constants/data.dart';
import 'package:vhn/models/dropdownbutton_model.dart';
import 'package:vhn/widgets/buttons/dropdown_button_maker.dart';
import 'package:vhn/widgets/buttons/vhn_elevated_button.dart';
import 'package:vhn/widgets/helpers/switch_maker.dart';

import '../../../../core/classes/spacing.dart';
import '../../widgets/input_fields/vhn_input_field.dart';

void addZonePopup(context, setState, zone, lastIndex, foreignZoneID) {
  TextEditingController controller = TextEditingController();

  final _fStore = FirebaseFirestore.instance;

  var deploy = kDeploy;

  String? initialValue;

  List<String> items = [
    'VHL',
    'VHN',
    'Domaine',
  ];

  String _status = '';

  var invoiceModel = DropDownButtonModel(
      hint: '   Facturation',
      items: items,
      initialValue: initialValue,
      onChanged: (String? value) {
        setState(() {
          initialValue = value!;
          _status = value;
        });
      });

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          zone == 'REGION' ? const Text('Ajouter une région') : const Text('Ajouter un domaine'),
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
          VhnInputField(
            text: zone == 'REGION' ? 'Nom de la région' : 'Nom du domaine',
            controller: controller,
          ),
          Spacing.height(baseSpace),
          zone != 'REGION'
              ? Column(
                  children: [
                    DropDownButtonMaker(
                      model: invoiceModel,
                      width: 220,
                    ),
                    Spacing.height(baseSpace),
                    Container(
                      height: 200,
                      width: 300,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          children: [
                            Spacing.height(baseSpace),
                            const Center(
                              child: Text('Départements'),
                            ),
                            Spacing.height(baseSpace),
                            for (var key in deploy.keys) SwitchMaker(map: deploy, mapKey: key),
                          ],
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(baseSpace / 2),
                        border: Border.all(
                          color: Colors.black54,
                        ),
                      ),
                    )
                  ],
                )
              : const SizedBox(),
        ],
      ),
      actions: [
        VhnElevatedButton(
            text: 'valider',
            onPress: () async {
              var index = lastIndex;
              String name = controller.text;
              _status == '' ? _status = 'Domaine' : _status;

              if (zone == 'REGION') {
                await _fStore.collection('n_regions').add({'name': name, 'index': index});
              } else {
                await _fStore.collection('n_domains').add({
                  'name': name.toString(),
                  'index': index,
                  'deploy': deploy,
                  'invoice': _status.toString(),
                  'regionID': foreignZoneID.toString(),
                });
              }
              Navigator.pop(context);
            }),
      ],
    ),
  );
}
