import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vhn/features/tab_bar_view/card_list/widget/vhn_domain_card.dart';
import 'package:vhn/features/tab_bar_view/card_list/widget/vhn_wine_card.dart';
import '../../../../constants/data.dart';

class DomainList extends StatefulWidget {
  String regionID;

  DomainList({
    Key? key,
    required this.regionID,
  }) : super(key: key);

  @override
  State<DomainList> createState() => _DomainListState();
}

class _DomainListState extends State<DomainList> {
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
    return ValueListenableBuilder<int>(
      valueListenable: searchUpdateNotifier,
      builder: (context, _, __) {
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

        // Sinon afficher la liste normale des domaines
        return StreamBuilder<QuerySnapshot>(
          stream: _fStore
              .collection('n_domains')
              .where('regionID', isEqualTo: widget.regionID)
              .snapshots(),
          builder: (buildContext, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            documents = snapshot.data!.docs;
            lastIndex = documents.length;

            // Filtrer par département si nécessaire
            List<DocumentSnapshot> filteredByDept = [];

            if (currentUserStatus == 'VHN' ||
                currentUserStatus == 'Ambassade') {
              // VHN et Ambassade voient tout
              filteredByDept = documents;
            } else {
              // Les autres sont filtrés par département
              filteredByDept = documents
                  .where((domain) =>
                      departmentExist(currentUserDepartments, domain))
                  .toList();
            }

            // Trier par nom
            filteredByDept.sort((a, b) => a['name'].compareTo(b['name']));

            // Créer les widgets
            List<Widget> resultWidgets = [];

            for (var domain in filteredByDept) {
              resultWidgets.add(
                SizedBox(
                  key: ValueKey(domain.id),
                  child: VhnDomainCard(domainSnap: domain),
                ),
              );
            }

            if (resultWidgets.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(baseSpace * 4),
                  child: Text(
                    'Aucun domaine dans cette région',
                    style: TextStyle(
                      fontSize: baseSpace * 2,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }

            return ListView(
              controller: ScrollController(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: resultWidgets,
            );
          },
        );
      },
    );
  }
}
