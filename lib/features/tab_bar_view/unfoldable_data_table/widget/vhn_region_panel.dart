import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vhn/features/tab_bar_view/unfoldable_data_table/widget/vhn_area_panel.dart';
import '../../../../core/classes/spacing.dart';
import '../../../../constants/data.dart';
import '../../../../functions/add/add_zone_popup.dart';
import '../../../../functions/delete_item_popup.dart';
import '../../../../functions/edit/edit_zone_data.dart';
import '../../../../widgets/buttons/VhnTextButton.dart';

enum PopupMenuItems { addItem, editItem, deleteItem }

class VhnRegionPanel extends StatefulWidget {
  DocumentSnapshot regionSnap;

  VhnRegionPanel({
    Key? key,
    required this.regionSnap,
  }) : super(key: key);

  @override
  State<VhnRegionPanel> createState() => _VhnRegionPanelState();
}

class _VhnRegionPanelState extends State<VhnRegionPanel> {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: baseSpace,
      margin: EdgeInsets.all(baseSpace),
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(baseSpace * 2),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: ReorderableDragStartListener(
                key: ValueKey(widget.regionSnap['index']),
                index: widget.regionSnap['index'],
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.regionSnap['name'],
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: baseSpace * 3,
                    ),
                  ),
                ),
              ),
            ),
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
                              'name': widget.regionSnap['name'],
                              'index': widget.regionSnap['index'],
                            },
                            'REGION',
                            widget.regionSnap.id);
                        break;
                      case PopupMenuItems.deleteItem:
                        deleteItemPopup(context, setState, 'REGION', {
                          'id': widget.regionSnap.id,
                          'name': widget.regionSnap['name']
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
          ],
        ),
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _fStore
                .collection('n_domains')
                .where('regionID', isEqualTo: widget.regionSnap.id)
                .snapshots(),
            builder: (context, snapshot) {
              List<Widget> resultWidgets = [];

              if (snapshot.hasData) {
                documents = snapshot.data!.docs;
                lastIndex = documents.length;

                documents.sort((a, b) => a['name'].compareTo(b['name']));

                for (var domain in documents) {
                  if (currentUserStatus == 'VHN' ||
                      currentUserStatus == 'Ambassade') {
                    // VHN et Ambassade voient tout
                    resultWidgets.add(
                      SizedBox(
                        key: ValueKey(domain.id),
                        child: VhnAreaPanel(domainSnap: domain),
                      ),
                    );
                  } else {
                    // Les autres sont soumis aux restrictions
                    if (departmentExist(currentUserDepartments, domain)) {
                      resultWidgets.add(
                        SizedBox(
                          key: ValueKey(domain.id),
                          child: VhnAreaPanel(domainSnap: domain),
                        ),
                      );
                    }
                  }
                }
              }

              return currentUserStatus == 'VHN'
                  ? ReorderableListView(
                      physics: BouncingScrollPhysics(),
                      buildDefaultDragHandles: false,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      onReorder: _onReorder,
                      children: resultWidgets,
                    )
                  : ListView(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: resultWidgets,
                    );
            },
          ),
          if (currentUserStatus == 'VHN') Spacing.height(baseSpace * 2),
          if (currentUserStatus == 'VHN')
            VhnTextButton(
              padding: baseSpace,
              fontSize: baseSpace * 2,
              icon: Icons.add,
              text: 'Ajouter un domaine'.toUpperCase(),
              onPressed: () {
                addZonePopup(context, setState, 'DOMAINE', lastIndex,
                    widget.regionSnap.id);
              },
            ),
        ],
      ),
    );
  }
}
