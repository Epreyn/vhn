import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:vhn/functions/dynamic_column_of_datatable.dart';

import '../../../../constants/data.dart';
import '../../../../core/classes/spacing.dart';
import '../../../../core/classes/uniques_controllers.dart';
import '../../../../functions/add/add_zone_popup.dart';
import '../../../../widgets/buttons/VhnTextButton.dart';
import '../../../../widgets/columns/vhn_column.dart';
import '../widget/vhn_domain_card.dart';
import '../widget/vhn_wine_card.dart';

class DomainManagerView extends StatefulWidget {
  String? regionID;

  DomainManagerView({Key? key, this.regionID}) : super(key: key);

  @override
  State<DomainManagerView> createState() => _DomainManagerViewState();
}

class _DomainManagerViewState extends State<DomainManagerView> {
  final _fStore = FirebaseFirestore.instance;
  var lastIndex = 0;

  String orderType = 'cuvee';
  bool descending = true;

  late List<DocumentSnapshot> documents;
  late Future _saving;

  bool departmentExist(List<String> departments, DocumentSnapshot domainSnap) {
    var count = 0;
    for (var dpt in departments) {
      if (domainSnap['deploy'][dpt] == true) count++;
    }
    return count > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Obx(
          () => VhnColumn(
            centered: false,
            width: dynamicColumnOfDataTable(context),
            widgets: [
              Spacing.height(baseSpace * 4),
              !UniquesControllers().data.isWantedInList.value
                  ? StreamBuilder<QuerySnapshot>(
                      stream: _fStore
                          .collection('n_domains')
                          .where('regionID', isEqualTo: widget.regionID)
                          .snapshots(),
                      builder: (buildContext, snapshot) {
                        List<Widget> resultWidgets = [];

                        if (snapshot.hasData) {
                          documents = snapshot.data!.docs;
                          lastIndex = documents.length;
                          documents
                              .sort((a, b) => a['name'].compareTo(b['name']));

                          for (var domain in documents) {
                            if (currentUserStatus == 'VHN' ||
                                currentUserStatus == 'Ambassade') {
                              // VHN et Ambassade voient tout
                              resultWidgets.add(
                                SizedBox(
                                  key: ValueKey(domain.id),
                                  child: VhnDomainCard(domainSnap: domain),
                                ),
                              );
                            } else {
                              // Les autres sont soumis aux restrictions
                              if (departmentExist(
                                  currentUserDepartments, domain)) {
                                resultWidgets.add(
                                  SizedBox(
                                    key: ValueKey(domain.id),
                                    child: VhnDomainCard(domainSnap: domain),
                                  ),
                                );
                              }
                            }
                          }
                        }

                        return ListView(
                          controller: ScrollController(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: resultWidgets,
                        );
                      },
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: _fStore.collection('n_wines').snapshots(),
                      builder: (context, snapshot) {
                        List<Widget> resultWidgets = [];
                        final _horizontalScrollController = ScrollController();

                        if (snapshot.hasData) {
                          documents = snapshot.data!.docs;
                          descending
                              ? documents.sort((a, b) =>
                                  a[orderType].compareTo(b[orderType]))
                              : documents.sort((a, b) =>
                                  b[orderType].compareTo(a[orderType]));

                          for (var wine in documents) {
                            if (wine['cuvee'].toLowerCase().contains(
                                textListController.text.toLowerCase())) {
                              TextEditingController quantityController =
                                  TextEditingController(text: wine['quantity']);
                              String currentQuantity = '';
                              resultWidgets.add(VhnWineCard(wineSnap: wine));
                            }
                          }
                        }

                        return Column(
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
                        widget.regionID);
                  },
                ),
            ],
          ),
        ));
  }
}
