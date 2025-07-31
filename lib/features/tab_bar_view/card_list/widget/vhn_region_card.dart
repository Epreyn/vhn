import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vhn/widgets/buttons/vhn_icon_button.dart';

import '../../../../constants/data.dart';
import '../../../../core/classes/uniques_controllers.dart';
import '../../../../functions/delete_item_popup.dart';
import '../../../../functions/edit/edit_zone_data.dart';
import '../../unfoldable_data_table/widget/vhn_area_panel.dart'
    hide PopupMenuItems;

class VhnRegionCard extends StatefulWidget {
  DocumentSnapshot regionSnap;

  VhnRegionCard({
    Key? key,
    required this.regionSnap,
  }) : super(key: key);

  @override
  State<VhnRegionCard> createState() => _VhnRegionCardState();
}

class _VhnRegionCardState extends State<VhnRegionCard> {
  final _fStore = FirebaseFirestore.instance;
  var lastIndex = 0;

  late List<DocumentSnapshot> documents;
  late Future _saving;

  bool departmentExist(List<String> departments, DocumentSnapshot domainSnap) {
    var count = 0;
    for (var dpt in departments) {
      if (domainSnap['deploy'][dpt] == true) count++;
    }
    return count > 0;
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    documents.insert(newIndex, documents.removeAt(oldIndex));
    final futures = <Future>[];
    for (int pos = 0; pos < documents.length; pos++) {
      futures.add(documents[pos]
          .reference
          .set({'index': pos}, SetOptions(merge: true)));
    }
    setState(() {
      _saving = Future.wait(futures);
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    // Vérifier que le document a bien un champ 'name'
    final data = widget.regionSnap.data() as Map<String, dynamic>?;
    if (data == null || !data.containsKey('name')) {
      return SizedBox(); // Ne rien afficher si le document est invalide
    }

    final regionName = data['name'] ?? 'Sans nom';
    final regionIndex = data['index'] ?? 0;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            UniquesControllers()
                .data
                .addToStack('DOMAINS', widget.regionSnap.id);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Card(
              elevation: baseSpace,
              margin: EdgeInsets.all(baseSpace),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    baseSpace * 4, baseSpace * 4, baseSpace * 2, baseSpace * 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          regionName,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: baseSpace * 3,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (currentUserStatus == 'VHN')
                          PopupMenuButton(
                              tooltip: '',
                              child: Icon(
                                Icons.edit,
                                size: baseSpace * 4,
                                color: Colors.blue,
                              ),
                              onSelected: (value) {
                                switch (value) {
                                  case PopupMenuItems.editItem:
                                    editZoneData(
                                        context,
                                        setState,
                                        {
                                          'name': regionName,
                                          'index': regionIndex,
                                        },
                                        'REGION',
                                        widget.regionSnap.id);
                                    break;
                                  case PopupMenuItems.deleteItem:
                                    deleteItemPopup(
                                        context, setState, 'REGION', {
                                      'id': widget.regionSnap.id,
                                      'name': regionName,
                                    });
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem(
                                      value: PopupMenuItems.editItem,
                                      child: Text('Modifier la région'),
                                    ),
                                    const PopupMenuItem(
                                      value: PopupMenuItems.deleteItem,
                                      child: Text('Supprimer la région'),
                                    ),
                                  ]),
                        if (currentUserStatus == 'VHN')
                          ReorderableDragStartListener(
                            key: ValueKey(regionIndex),
                            index: regionIndex,
                            child: VhnIconButton(
                                size: baseSpace * 4,
                                icon: Icons.drag_handle,
                                onPressed: () {}),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
