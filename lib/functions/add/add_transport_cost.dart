import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/classes/spacing.dart';
import '../../constants/data.dart';
import '../../widgets/buttons/vhn_elevated_button.dart';
import '../../widgets/input_fields/vhn_input_field.dart';

void addTransportCost(context, setState) {
  TextEditingController departmentController = TextEditingController();
  TextEditingController _1To36Controller = TextEditingController();
  TextEditingController _37To75Controller = TextEditingController();
  TextEditingController _76To115Controller = TextEditingController();
  TextEditingController _116To150Controller = TextEditingController();
  TextEditingController _151To200Controller = TextEditingController();
  TextEditingController _201To250Controller = TextEditingController();
  TextEditingController _forOneController = TextEditingController();
  TextEditingController _2To3Controller = TextEditingController();
  TextEditingController _4To6Controller = TextEditingController();

  final _fStore = FirebaseFirestore.instance;

  var deploy = kDeploy;

  String? initialValue;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Ajouter un tarif'),
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
        height: 400,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 180,
                  height: 400,
                  child: Column(
                    children: [
                      Text("Département"),
                      VhnInputField(
                        text: '1',
                        controller: departmentController,
                      ),
                      Spacing.height(baseSpace),
                      VhnInputField(
                        text: 'De 1 à 36 cols',
                        controller: _1To36Controller,
                      ),
                      Spacing.height(baseSpace),
                      VhnInputField(
                        text: 'De 37 à 75 cols',
                        controller: _37To75Controller,
                      ),
                      Spacing.height(baseSpace),
                      VhnInputField(
                        text: 'De 76 à 115 cols',
                        controller: _76To115Controller,
                      ),
                      Spacing.height(baseSpace),
                      VhnInputField(
                        text: 'De 116 à 150 cols',
                        controller: _116To150Controller,
                      ),
                      Spacing.height(baseSpace),
                    ],
                  ),
                ),
                Container(
                  width: 180,
                  height: 400,
                  child: Column(
                    children: [
                      Spacing.height(19),
                      VhnInputField(
                        text: 'De 151 à 200 cols',
                        controller: _151To200Controller,
                      ),
                      Spacing.height(baseSpace),
                      VhnInputField(
                        text: 'De 201 à 250 cols',
                        controller: _201To250Controller,
                      ),
                      Spacing.height(baseSpace),
                      VhnInputField(
                        text: '1 palette',
                        controller: _forOneController,
                      ),
                      Spacing.height(baseSpace),
                      VhnInputField(
                        text: 'De 2 à 3 palettes',
                        controller: _2To3Controller,
                      ),
                      Spacing.height(baseSpace),
                      VhnInputField(
                        text: '4 à 6 palettes',
                        controller: _4To6Controller,
                      ),
                      Spacing.height(baseSpace),
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
                  await _fStore.collection('transport_costs').add({
                    'department': departmentController.text,
                    'package1To36': _1To36Controller.text,
                    'package37To75': _37To75Controller.text,
                    'package76To115': _76To115Controller.text,
                    'package116To150': _116To150Controller.text,
                    'package151To200': _151To200Controller.text,
                    'package201To250': _201To250Controller.text,
                    'palletFor1': _forOneController.text,
                    'pallet2To3': _2To3Controller.text,
                    'pallet4To6': _4To6Controller.text
                  });
                  Navigator.pop(context);
                }),
          ],
        ),
      ],
    ),
  );
}
