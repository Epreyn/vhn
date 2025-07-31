import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:vhn/models/dropdownbutton_model.dart';
import 'package:vhn/widgets/buttons/vhn_elevated_button.dart';
import 'package:vhn/widgets/rows/card_row.dart';

import '../../../../core/classes/spacing.dart';
import '../../../../constants/data.dart';
import '../../../../functions/responsive/responsive_card_modifier.dart';
import '../../../../widgets/buttons/dropdown_button_maker.dart';
import '../../../../widgets/buttons/vhn_icon_button.dart';

class CardOfUser extends StatelessWidget {
  DocumentSnapshot<Object?> user;
  DropDownButtonModel model;
  void Function() onPressed;
  void Function() onChangedValidation;
  void Function() onChangedArchived;

  CardOfUser({
    Key? key,
    required this.user,
    required this.model,
    required this.onPressed,
    required this.onChangedValidation,
    required this.onChangedArchived,
  }) : super(key: key);

  Widget getTextWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              // Ajouter Flexible ici
              child: DropDownButtonMaker(
                model: model,
                width: 150,
              ),
            ),
            SizedBox(width: baseSpace), // Ajouter un espace
            getButtonWidgets()
          ],
        ),
        Spacing.height(baseSpace),
        CardRow(label: 'Entreprise : ', text: user['entreprise']),
        Spacing.height(baseSpace),
        CardRow(label: 'Téléphone : ', text: user['téléphone']),
        CardRow(label: "Email : ", text: user['email']),
        Spacing.height(baseSpace),
        CardRow(label: 'Département : ', text: user['département']),
        CardRow(label: 'Adresse : ', text: user['adresse']),
        CardRow(label: 'Ville : ', text: user['ville']),
        CardRow(label: 'Code postal : ', text: user['code postal']),
      ],
    );
  }

  Widget getButtonWidgets() {
    return SizedBox(
      child: Row(
        children: [
          VhnIconButton(
            size: baseSpace * 4,
            icon: user['validation']
                ? Icons.check_circle_outlined
                : Icons.circle_outlined,
            color: user['validation'] ? Colors.green : Colors.grey,
            onPressed: onChangedValidation,
          ),
          VhnIconButton(
            size: baseSpace * 4,
            icon: Icons.edit,
            color: Colors.blue,
            onPressed: onPressed,
          ),

          VhnIconButton(
            size: baseSpace * 4,
            icon: user['archive']
                ? Icons.unarchive_outlined
                : Icons.delete_outlined,
            color: Colors.red,
            onPressed: onChangedArchived,
          ),

          // VhnElevatedButton(
          //   text: user['archive'] ? 'DÉSARCHIVER' : 'ARCHIVER',
          //   color: Colors.red,
          //   onPress: onChangedArchived,
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: baseSpace,
      child: Padding(
        padding: EdgeInsets.all(baseSpace * 2),
        child: responsiveCardModifier(getTextWidgets(), getButtonWidgets(),
            MediaQuery.of(context).size.width),
        //responsiveCardModifier(getTextWidgets(), getButtonWidgets(), MediaQuery.of(context).size.width),
      ),
    );
  }
}
