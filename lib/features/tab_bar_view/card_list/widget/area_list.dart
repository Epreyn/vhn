import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vhn/features/tab_bar_view/card_list/widget/vhn_region_card.dart';
import 'package:vhn/features/tab_bar_view/card_list/widget/vhn_wine_card.dart';

import '../../../../constants/data.dart';
import '../../../../core/classes/spacing.dart';
import '../../../../functions/add/add_zone_popup.dart';
import '../../../../widgets/buttons/VhnTextButton.dart';

class AreaList extends StatefulWidget {
  const AreaList({Key? key}) : super(key: key);

  @override
  State<AreaList> createState() => _AreaListState();
}

class _AreaListState extends State<AreaList> {
  int lastIndex = 0;
  final _fStore = FirebaseFirestore.instance;
  late List<DocumentSnapshot> documents;
  late Future _saving;

  @override
  Widget build(BuildContext context) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: searchUpdateNotifier,
                  builder: (context, notifierValue, __) {
                    // Récupérer le texte de recherche
                    final searchText = wineSearchController.text.toLowerCase();
                    final isSearching = searchText.length > 1;

                    // Si on cherche, afficher les vins
                    if (isSearching) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: _fStore.collection('n_wines').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          var wineDocuments = snapshot.data!.docs;

                          // Filtrer les vins
                          List<Map<String, dynamic>> filteredWines = [];

                          for (var wine in wineDocuments) {
                            final data = wine.data() as Map<String, dynamic>;
                            data['id'] = wine.id;

                            // NE PAS filtrer par quantité - afficher TOUS les vins
                            // Même ceux avec quantité = 0

                            final cuvee =
                                (data['cuvee'] ?? '').toString().toLowerCase();
                            final color =
                                (data['color'] ?? '').toString().toLowerCase();
                            final vintage = (data['vintage'] ?? '')
                                .toString()
                                .toLowerCase();
                            final format =
                                (data['format'] ?? '').toString().toLowerCase();

                            if (cuvee.contains(searchText) ||
                                color.contains(searchText) ||
                                vintage.contains(searchText) ||
                                format.contains(searchText)) {
                              filteredWines.add(data);
                            }
                          }

                          if (filteredWines.isEmpty) {
                            return Container(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: baseSpace * 8,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: baseSpace * 2),
                                    Text(
                                      'Aucun vin trouvé pour "$searchText"',
                                      style: TextStyle(
                                        fontSize: baseSpace * 2.5,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Afficher les vins trouvés
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(baseSpace * 2),
                                child: Text(
                                  '${filteredWines.length} vin(s) trouvé(s)',
                                  style: TextStyle(
                                    fontSize: baseSpace * 2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: filteredWines.length,
                                itemBuilder: (context, index) {
                                  return VhnWineCard(
                                      wineSnap: filteredWines[index]);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }

                    // Sinon afficher la liste normale des régions
                    return StreamBuilder<QuerySnapshot>(
                      stream: _fStore
                          .collection('n_regions')
                          .orderBy('index')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        documents = snapshot.data!.docs;
                        lastIndex = documents.length;

                        List<Widget> resultWidgets = [];

                        for (var region in documents) {
                          // Vérifier que le document est valide
                          final data = region.data() as Map<String, dynamic>?;
                          if (data != null && data.containsKey('name')) {
                            resultWidgets.add(
                              SizedBox(
                                key: ValueKey(region.id),
                                child: VhnRegionCard(regionSnap: region),
                              ),
                            );
                          }
                        }

                        // Widget principal
                        if (currentUserStatus == 'VHN') {
                          return Column(
                            children: [
                              SizedBox(
                                height: constraints.maxHeight - 100,
                                child: ReorderableListView(
                                  buildDefaultDragHandles: false,
                                  scrollDirection: Axis.vertical,
                                  onReorder: _onReorder,
                                  children: resultWidgets,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return ListView(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: resultWidgets,
                          );
                        }
                      },
                    );
                  },
                ),
                // Bouton ajouter région
                ValueListenableBuilder<int>(
                  valueListenable: searchUpdateNotifier,
                  builder: (context, _, __) {
                    final isSearching = wineSearchController.text.length > 1;

                    if (!isSearching && currentUserStatus == 'VHN') {
                      return Column(
                        children: [
                          Spacing.height(baseSpace * 2),
                          VhnTextButton(
                            padding: baseSpace,
                            fontSize: baseSpace * 2,
                            icon: Icons.add,
                            text: 'Ajouter une région'.toUpperCase(),
                            onPressed: () {
                              addZonePopup(
                                  context, setState, 'REGION', lastIndex, null);
                            },
                          ),
                          Spacing.height(baseSpace * 2),
                        ],
                      );
                    }
                    return SizedBox();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
