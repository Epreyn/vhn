import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vhn/features/tab_bar_view/unfoldable_data_table/widget/vhn_region_panel.dart';
import '../../../../constants/data.dart';
import '../../../../core/classes/spacing.dart';
import '../../../../functions/add/add_zone_popup.dart';
import '../../../../widgets/buttons/VhnTextButton.dart';
import '../widget/vhn_area_panel.dart';

class StockManagerPage extends StatefulWidget {
  @override
  _StockManagerPageState createState() => _StockManagerPageState();
}

class _StockManagerPageState extends State<StockManagerPage> {
  final _fStore = FirebaseFirestore.instance;
  int lastIndex = 0;
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
    return ValueListenableBuilder<int>(
      valueListenable: searchUpdateNotifier,
      builder: (context, _, __) {
        // Utiliser wineSearchController pour chercher les vins
        final searchText = wineSearchController.text.toLowerCase();
        final isSearching = searchText.length > 1;

        if (isSearching) {
          // Mode recherche : afficher tous les vins filtrés
          return StreamBuilder<QuerySnapshot>(
            stream: _fStore.collection('n_wines').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var wines = snapshot.data!.docs;

              // Filtrer les vins selon la recherche
              wines = wines.where((wine) {
                final data = wine.data() as Map<String, dynamic>;

                // NE PAS filtrer par quantité - afficher TOUS les vins
                // Même ceux avec quantité = 0

                final cuvee = (data['cuvee'] ?? '').toString().toLowerCase();
                final color = (data['color'] ?? '').toString().toLowerCase();
                final vintage =
                    (data['vintage'] ?? '').toString().toLowerCase();
                final format = (data['format'] ?? '').toString().toLowerCase();

                return cuvee.contains(searchText) ||
                    color.contains(searchText) ||
                    vintage.contains(searchText) ||
                    format.contains(searchText);
              }).toList();

              if (wines.isEmpty) {
                return Center(
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
                );
              }

              // Créer une liste temporaire de régions/domaines avec leurs vins filtrés
              return FutureBuilder<Map<String, Map<String, List>>>(
                future: _buildFilteredHierarchy(wines),
                builder: (context, hierarchySnapshot) {
                  if (!hierarchySnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final hierarchy = hierarchySnapshot.data!;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(baseSpace * 2),
                          child: Text(
                            '${wines.length} vin(s) trouvé(s)',
                            style: TextStyle(
                              fontSize: baseSpace * 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...hierarchy.entries.map((regionEntry) {
                          final regionId = regionEntry.key;
                          final domainMap = regionEntry.value;

                          return FutureBuilder<DocumentSnapshot>(
                            future: _fStore
                                .collection('n_regions')
                                .doc(regionId)
                                .get(),
                            builder: (context, regionSnapshot) {
                              if (!regionSnapshot.hasData) return SizedBox();

                              return Card(
                                elevation: baseSpace,
                                margin: EdgeInsets.all(baseSpace),
                                child: ExpansionTile(
                                  initiallyExpanded: true,
                                  title: Text(
                                    regionSnapshot.data!['name'],
                                    style: TextStyle(
                                      fontSize: baseSpace * 3,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children:
                                      domainMap.entries.map((domainEntry) {
                                    final domainId = domainEntry.key;
                                    final wineList = domainEntry.value;

                                    return FutureBuilder<DocumentSnapshot>(
                                      future: _fStore
                                          .collection('n_domains')
                                          .doc(domainId)
                                          .get(),
                                      builder: (context, domainSnapshot) {
                                        if (!domainSnapshot.hasData)
                                          return SizedBox();

                                        // Créer un panel de domaine avec les vins filtrés
                                        return VhnAreaPanel(
                                          domainSnap: domainSnapshot.data!,
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              );
            },
          );
        }

        // Mode normal : afficher toutes les régions avec leurs domaines
        return StreamBuilder<QuerySnapshot>(
          stream: _fStore.collection('n_regions').orderBy('index').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            documents = snapshot.data!.docs;
            lastIndex = documents.length;

            List<Widget> resultWidgets = [];

            for (var region in documents) {
              resultWidgets.add(
                SizedBox(
                  key: ValueKey(region.id),
                  child: VhnRegionPanel(regionSnap: region),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: currentUserStatus == 'VHN'
                      ? ReorderableListView(
                          buildDefaultDragHandles: false,
                          scrollDirection: Axis.vertical,
                          onReorder: _onReorder,
                          children: resultWidgets,
                        )
                      : ListView(
                          scrollDirection: Axis.vertical,
                          children: resultWidgets,
                        ),
                ),
                if (currentUserStatus == 'VHN') Spacing.height(baseSpace * 2),
                if (currentUserStatus == 'VHN')
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
              ],
            );
          },
        );
      },
    );
  }

  // Construire la hiérarchie région > domaine > vins filtrés
  Future<Map<String, Map<String, List>>> _buildFilteredHierarchy(
      List<DocumentSnapshot> wines) async {
    Map<String, Map<String, List>> hierarchy = {};

    for (var wine in wines) {
      final domainId = wine['domainID'];

      // Récupérer le domaine
      final domainDoc =
          await _fStore.collection('n_domains').doc(domainId).get();
      if (!domainDoc.exists) continue;

      final regionId = domainDoc['regionID'];

      // Créer la structure si nécessaire
      if (!hierarchy.containsKey(regionId)) {
        hierarchy[regionId] = {};
      }
      if (!hierarchy[regionId]!.containsKey(domainId)) {
        hierarchy[regionId]![domainId] = [];
      }

      // Ajouter le vin
      hierarchy[regionId]![domainId]!.add(wine);
    }

    return hierarchy;
  }
}
