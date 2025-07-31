import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:vhn/functions/edit/edit_wine_popup.dart';

import '../../../../constants/data.dart';
import '../../../../core/classes/spacing.dart';
import '../../../../core/classes/uniques_controllers.dart';
import '../../../../functions/dynamic_column_of_datatable.dart';
import '../../../../widgets/buttons/VhnTextButton.dart';
import '../../../../widgets/columns/vhn_column.dart';
import '../widget/vhn_wine_card.dart';

class WineManagerView extends StatefulWidget {
  String? domainID;

  WineManagerView({Key? key, this.domainID}) : super(key: key);

  @override
  State<WineManagerView> createState() => _WineManagerViewState();
}

class _WineManagerViewState extends State<WineManagerView> {
  final _fStore = FirebaseFirestore.instance;
  var lastIndex = 0;

  late List<DocumentSnapshot> documents;
  late Future _saving;

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

  String orderType = 'cuvee';

  bool descending = true;
  DataColumn tableTitle(String title, int columnIndex) {
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
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            letterSpacing: 1,
            wordSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final domainID = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Obx(
          () => VhnColumn(
            width: dynamicColumnOfDataTable(context),
            centered: false,
            widgets: [
              Spacing.height(baseSpace * 4),
              !UniquesControllers().data.isWantedInList.value
                  ? StreamBuilder<QuerySnapshot>(
                      stream: _fStore
                          .collection('n_wines')
                          .where('domainID', isEqualTo: widget.domainID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        List<Widget> resultWidgets = [];

                        if (snapshot.hasData) {
                          documents = snapshot.data!.docs;
                          descending
                              ? documents.sort((a, b) =>
                                  a[orderType].compareTo(b[orderType]))
                              : documents.sort((a, b) =>
                                  b[orderType].compareTo(a[orderType]));

                          List<List<DocumentSnapshot>> orderedWines = [];

                          List<String> banIds = [];
                          for (var wine in documents) {
                            List<DocumentSnapshot> cuveeWines = [];
                            for (var element in documents) {
                              if (!banIds.contains(element.id) &&
                                  element['cuvee']
                                          .toString()
                                          .characters
                                          .first
                                          .toLowerCase() ==
                                      wine['cuvee']
                                          .toString()
                                          .characters
                                          .first
                                          .toLowerCase()) {
                                cuveeWines.add(element);
                                banIds.add(element.id);
                              }
                            }

                            descending
                                ? cuveeWines.sort((a, b) =>
                                    a['vintage'].compareTo(b['vintage']))
                                : cuveeWines.sort((a, b) =>
                                    b['vintage'].compareTo(a['vintage']));

                            orderedWines.add(cuveeWines);
                          }
                          List<DocumentSnapshot> results = [];

                          for (var cuveList in orderedWines) {
                            for (var wineItem in cuveList) {
                              results.add(wineItem);
                            }
                          }

                          for (var wine in results) {
                            resultWidgets.add(
                              VhnWineCard(wineSnap: wine),
                            );
                          }
                        }

                        return Column(
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

                          List<List<DocumentSnapshot>> orderedWines = [];

                          List<String> banIds = [];
                          for (var wine in documents) {
                            List<DocumentSnapshot> cuveeWines = [];
                            for (var element in documents) {
                              if (!banIds.contains(element.id) &&
                                  element['cuvee']
                                          .toString()
                                          .characters
                                          .first
                                          .toLowerCase() ==
                                      wine['cuvee']
                                          .toString()
                                          .characters
                                          .first
                                          .toLowerCase()) {
                                cuveeWines.add(element);
                                banIds.add(element.id);
                              }
                            }

                            descending
                                ? cuveeWines.sort((a, b) =>
                                    a['vintage'].compareTo(b['vintage']))
                                : cuveeWines.sort((a, b) =>
                                    b['vintage'].compareTo(a['vintage']));

                            orderedWines.add(cuveeWines);
                          }
                          List<DocumentSnapshot> results = [];

                          for (var cuveList in orderedWines) {
                            for (var wineItem in cuveList) {
                              results.add(wineItem);
                            }
                          }
                          for (var wine in results) {
                            resultWidgets.add(
                              VhnWineCard(wineSnap: wine),
                            );
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
                  text: 'Ajouter un vin'.toUpperCase(),
                  onPressed: () {
                    editWinePopup(context, setState, null, widget.domainID);
                  },
                ),
            ],
          ),
        ));
  }
}
