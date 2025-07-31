import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vhn/features/tab_bar_view/card_list/widget/vhn_wine_card.dart';
import '../../../../core/classes/uniques_controllers.dart';
import '../../../../constants/data.dart';
// SUPPRIMÉ : import '../../../navigation/vhn_search_controller.dart';

class WineList extends StatefulWidget {
  String domainID;

  WineList({
    Key? key,
    required this.domainID,
  }) : super(key: key);

  @override
  State<WineList> createState() => _WineListState();
}

class _WineListState extends State<WineList> {
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: searchUpdateNotifier, // Vient de data.dart
      builder: (context, _, __) {
        // Récupérer le texte de recherche
        final searchText =
            wineSearchController.text.toLowerCase(); // Vient de data.dart
        final isSearching = searchText.length > 1;

        // Si on cherche, afficher tous les vins filtrés
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

                // // Vérifier la quantité
                // final quantity =
                //     int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;
                // if (quantity == 0) continue; // Ignorer les vins avec quantité 0

                final cuvee = (data['cuvee'] ?? '').toString().toLowerCase();
                final color = (data['color'] ?? '').toString().toLowerCase();
                final vintage =
                    (data['vintage'] ?? '').toString().toLowerCase();
                final format = (data['format'] ?? '').toString().toLowerCase();

                if (cuvee.contains(searchText) ||
                    color.contains(searchText) ||
                    vintage.contains(searchText) ||
                    format.contains(searchText)) {
                  filteredWines.add(data);
                }
              }

              if (filteredWines.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(baseSpace * 4),
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
              return SingleChildScrollView(
                child: Column(
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
                        return VhnWineCard(wineSnap: filteredWines[index]);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }

        // Sinon afficher la liste normale des vins du domaine
        return StreamBuilder<QuerySnapshot>(
          stream: _fStore
              .collection('n_wines')
              .where('domainID', isEqualTo: widget.domainID)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            documents = snapshot.data!.docs;

            // Trier les documents
            descending
                ? documents.sort((a, b) => a[orderType].compareTo(b[orderType]))
                : documents
                    .sort((a, b) => b[orderType].compareTo(a[orderType]));

            // Organiser par cuvée et millésime
            List<List<dynamic>> orderedWines = [];
            List<String> banIds = [];

            List<dynamic> wineList = UniquesControllers()
                .data
                .subOrderByVintage(documents, orderType);

            for (var wine in wineList) {
              List<dynamic> cuveeWines = [];
              for (var element in wineList) {
                if (!banIds.contains(element['id']) &&
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
                  banIds.add(element['id']);
                }
              }
              orderedWines.add(cuveeWines);
            }

            List<dynamic> results = [];
            for (var cuveList in orderedWines) {
              for (var wineItem in cuveList) {
                results.add(wineItem);
              }
            }

            // Créer les widgets
            List<Widget> resultWidgets = [];
            for (var wine in results) {
              // Vérifier la quantité
              final data =
                  wine is Map ? wine : wine.data() as Map<String, dynamic>;
              final quantity =
                  int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;
              if (quantity > 0) {
                // Seulement si quantité > 0
                resultWidgets.add(
                  VhnWineCard(wineSnap: wine),
                );
              }
            }

            if (resultWidgets.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(baseSpace * 4),
                  child: Text(
                    'Aucun vin dans ce domaine',
                    style: TextStyle(
                      fontSize: baseSpace * 2,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: resultWidgets,
              ),
            );
          },
        );
      },
    );
  }
}
