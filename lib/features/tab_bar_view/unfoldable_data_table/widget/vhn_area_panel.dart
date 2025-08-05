import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vhn/functions/delete_item_popup.dart';
import 'package:vhn/functions/edit/edit_wine_popup.dart';
import 'package:vhn/widgets/buttons/vhn_icon_button.dart';

import '../../../../constants/data.dart';
import '../../../../core/classes/spacing.dart';
import '../../../../functions/edit/edit_zone_data.dart';
import '../../../../widgets/buttons/VhnTextButton.dart';
import '../../../../widgets/helpers/cell_maker.dart';

enum PopupMenuItems { addItem, editItem, deleteItem }

enum PopupMenuSMS {
  cavisteSMS,
  chrSMS,
  cavisteEmail,
  chrEmail,
  ambassadeEmail,
  ambassadeSMS
}

class VhnAreaPanel extends StatefulWidget {
  DocumentSnapshot domainSnap;

  VhnAreaPanel({
    Key? key,
    required this.domainSnap,
  }) : super(key: key);

  @override
  State<VhnAreaPanel> createState() => _VhnAreaPanelState();
}

class _VhnAreaPanelState extends State<VhnAreaPanel> {
  final _fStore = FirebaseFirestore.instance;

  late List<DocumentSnapshot> documents;

  String orderType = 'cuvee';
  bool descending = true;

  String getDeploy(dynamic deploy) {
    var count = 0;
    for (var entry in deploy.entries) {
      if (entry.value == true) {
        count++;
      }
    }

    return count.toString();
  }

  DataColumn tableTitle(
      String title, String orderBy, int columnIndex, fontSize) {
    IconData? icon;

    if (orderBy.toLowerCase() == orderType.toLowerCase()) {
      descending == false
          ? icon = Icons.arrow_downward
          : icon = Icons.arrow_upward;
    }

    return DataColumn(
      label: InkWell(
        onTap: () {
          setState(() {
            switch (columnIndex) {
              case 0:
                orderType = 'cuvee';
                descending = !descending;
                break;
              case 1:
                orderType = 'vintage';
                descending = !descending;
                break;
              case 2:
                orderType = 'color';
                descending = !descending;
                break;
              case 3:
                orderType = 'format';
                descending = !descending;
                break;
              case 4:
                orderType = 'quantity';
                descending = !descending;
                break;
            }
          });
        },
        child: Row(
          children: [
            Icon(icon),
            Text(
              title,
              style: TextStyle(
                fontSize: fontSize ?? 15,
                color: Colors.black,
                letterSpacing: 1,
                wordSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: baseSpace,
      margin: EdgeInsets.all(baseSpace),
      child: ExpansionTile(
        key: ObjectKey(widget.domainSnap.id),
        tilePadding: EdgeInsets.all(baseSpace * 2),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: ReorderableDragStartListener(
                key: ValueKey(widget.domainSnap.id),
                index: widget.domainSnap['index'],
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.domainSnap['name'],
                    maxLines: 1,
                    style: TextStyle(fontSize: baseSpace * 3),
                  ),
                ),
              ),
            ),
            if (currentUserStatus == 'VHN')
              PopupMenuButton(
                  tooltip: '',
                  child: Icon(
                    Icons.edit,
                    size: baseSpace * 3,
                    color: Colors.blue,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case PopupMenuItems.editItem:
                        editZoneData(
                          context,
                          setState,
                          {
                            'name': widget.domainSnap['name'],
                            'invoice': widget.domainSnap['invoice'],
                            'deploy': widget.domainSnap['deploy'],
                          },
                          'DOMAIN',
                          widget.domainSnap.id,
                        );
                        break;
                      case PopupMenuItems.deleteItem:
                        deleteItemPopup(context, setState, 'DOMAIN', {
                          'id': widget.domainSnap.id,
                          'name': widget.domainSnap['name']
                        });
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: PopupMenuItems.editItem,
                          child: Text('Modifier le Domaine'),
                        ),
                        const PopupMenuItem(
                          value: PopupMenuItems.deleteItem,
                          child: Text('Supprimer le Domaine'),
                        ),
                      ])
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacing.height(baseSpace),
            Text('Facturation : ' + widget.domainSnap['invoice']),
            if (currentUserStatus == 'VHN')
              Text('Déploiement : ' +
                  getDeploy(widget.domainSnap['deploy']) +
                  ' département(s)'),
          ],
        ),
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _fStore
                .collection('n_wines')
                .where('domainID', isEqualTo: widget.domainSnap.id)
                //.orderBy('name', descending: descending)
                .snapshots(),
            builder: (context, snapshot) {
              List<DataRow> resultWidgets = [];
              final _horizontalScrollController = ScrollController();

              if (snapshot.hasData) {
                documents = snapshot.data!.docs;
                descending
                    ? documents
                        .sort((a, b) => a[orderType].compareTo(b[orderType]))
                    : documents
                        .sort((a, b) => b[orderType].compareTo(a[orderType]));

                for (var wine in documents) {
                  TextEditingController quantityController =
                      TextEditingController(text: wine['quantity']);
                  //String? initialValue;
                  String currentQuantity = '';
                  resultWidgets.add(
                    DataRow(
                      cells: [
                        DataCell(
                          CellMaker(
                            text: wine['cuvee'],
                            width: 150,
                          ),
                        ),
                        DataCell(
                          CellMaker(
                            text: wine['vintage'],
                          ),
                        ),
                        DataCell(CellMaker(
                          text: wine['color'],
                          width: 100,
                        )),
                        DataCell(
                          CellMaker(
                            text: wine['format'],
                            width: 100,
                          ),
                        ),
                        DataCell(
                          currentUserStatus == 'VHN'
                              ? SizedBox(
                                  width: 70,
                                  child: Focus(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) async {},
                                      controller: quantityController,
                                    ),
                                    onFocusChange: (isFocus) async {
                                      if (!isFocus) {
                                        if (quantityController.text !=
                                            currentQuantity) {
                                          enableLoading(setState);
                                          await _fStore
                                              .collection('n_wines')
                                              .doc(wine.id)
                                              .set({
                                            'quantity': quantityController.text,
                                          }, SetOptions(merge: true));
                                          disableLoading(setState);
                                        }
                                      } else {
                                        currentQuantity =
                                            quantityController.text;
                                      }
                                    },
                                  ),
                                )
                              : Text(wine['quantity']),
                        ),
                        DataCell(
                          currentUserStatus == 'VHN'
                              ? Row(
                                  children: [
                                    VhnIconButton(
                                      size: baseSpace * 3,
                                      icon: Icons.edit,
                                      onPressed: () {
                                        editWinePopup(
                                            context,
                                            setState,
                                            {
                                              'id': wine.id,
                                              'cuvee': wine['cuvee'],
                                              'vintage': wine['vintage'],
                                              'color': wine['color'],
                                              'packaging': wine['packaging'],
                                              'format': wine['format'],
                                              'quantity': wine['quantity'],
                                              'chr': wine['prices']['chr'],
                                              'caviste': wine['prices']
                                                  ['caviste'],
                                            },
                                            widget.domainSnap.id);
                                      },
                                    ),
                                    VhnIconButton(
                                      size: baseSpace * 3,
                                      icon: Icons.delete,
                                      color: Colors.red,
                                      onPressed: () {
                                        deleteItemPopup(
                                            context, setState, 'WINE', {
                                          'id': wine.id,
                                          'cuvee': wine['cuvee']
                                        });
                                      },
                                    ),
                                  ],
                                )
                              : currentUserStatus == 'Agent' ||
                                      currentUserStatus == 'Vigneron'
                                  ? Text(' CHR ' +
                                      wine['prices']['chr'] +
                                      ' / Caviste ' +
                                      wine['prices']['caviste'])
                                  : Text(wine['prices'][
                                          currentUserStatus == 'CHR'
                                              ? 'chr'
                                              : 'caviste'] +
                                      ' €'),
                        ),
                      ],
                    ),
                  );
                }
              }

              return Scrollbar(
                thumbVisibility: true,
                controller: _horizontalScrollController,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 0,
                    // headingTextStyle: TextStyle(fontSize: 13),
                    columns: [
                      tableTitle('Cuvée', 'cuvee', 0, null),
                      tableTitle('Millésime', 'vintage', 1, null),
                      tableTitle('Couleur', 'color', 2, null),
                      tableTitle('Format', 'format', 3, null),
                      tableTitle('Quantité', 'quantity', 4, null),
                      tableTitle(currentUserStatus == 'VHN' ? '' : 'Prix', '',
                          5, null),
                    ],
                    rows: resultWidgets,
                  ),
                ),
              );
            },
          ),
          if (currentUserStatus == 'VHN') Spacing.height(baseSpace * 2),
          if (currentUserStatus == 'VHN')
            VhnTextButton(
              padding: baseSpace,
              fontSize: baseSpace * 2,
              icon: Icons.add,
              text: 'Ajouter un vin'.toUpperCase(),
              onPressed: () {
                editWinePopup(context, setState, null, widget.domainSnap.id);
              },
            ),
        ],
      ),
    );
  }
}
