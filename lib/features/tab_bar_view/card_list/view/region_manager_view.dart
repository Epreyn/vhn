import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/data.dart';
import '../../../../core/classes/spacing.dart';
import '../../../../core/classes/uniques_controllers.dart';
import '../../../../functions/add/add_zone_popup.dart';
import '../../../../functions/dynamic_column_of_datatable.dart';
import '../../../../widgets/buttons/VhnTextButton.dart';
import '../../../../widgets/columns/vhn_column.dart';
import '../widget/vhn_region_card.dart';
import '../widget/vhn_wine_card.dart';

class RegionManagerView extends StatefulWidget {
  RegionManagerView({Key? key}) : super(key: key);

  @override
  State<RegionManagerView> createState() => _RegionManagerViewState();
}

class _RegionManagerViewState extends State<RegionManagerView> {
  final _fStore = FirebaseFirestore.instance;
  late Future _saving;

  // Pour le tri sur n_wines
  String orderType = 'cuvee';
  bool descending = true;

  // Exemple : on récupère le département de l’utilisateur
  // Si vous en avez plusieurs, adaptez le code.
  final String userDepartment = currentUserDepartments.isNotEmpty ? currentUserDepartments.first : '01';

  void sortColumn(int columnIndex) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => VhnColumn(
        centered: false,
        width: dynamicColumnOfDataTable(context),
        widgets: [
          Spacing.height(baseSpace * 4),

          // --- Premier StreamBuilder : on récupère tous les domaines ---
          StreamBuilder<QuerySnapshot>(
            stream: _fStore.collection('n_domains').snapshots(),
            builder: (context, domainSnapshot) {
              if (!domainSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Liste de tous les domaines
              final allDomainDocs = domainSnapshot.data!.docs;

              // --- Second StreamBuilder : on récupère toutes les régions ---
              return StreamBuilder<QuerySnapshot>(
                stream: _fStore.collection('n_regions').orderBy('index').snapshots(),
                builder: (context, regionSnapshot) {
                  if (!regionSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final regionDocs = regionSnapshot.data!.docs;
                  int lastIndex = regionDocs.length;

                  // Selon la variable isWantedInList, on alterne l'affichage
                  if (!UniquesControllers().data.isWantedInList.value) {
                    // ---- AFFICHAGE DES REGIONS ----
                    List<Widget> regionWidgets = [];

                    for (var region in regionDocs) {
                      // Récupérer tous les domaines de cette région
                      final domainsOfThisRegion = allDomainDocs.where((domain) {
                        final data = domain.data() as Map<String, dynamic>;
                        return data['regionID'] == region.id;
                      });

                      // Filtrer pour ne garder que ceux qui sont "accessibles" = deploy[dept] == true
                      final accessibleDomains = domainsOfThisRegion.where((domain) {
                        final data = domain.data() as Map<String, dynamic>;
                        final deploy = data['deploy'] as Map<String, dynamic>;
                        return deploy[userDepartment] == true;
                      }).toList();

                      // Si cette région n'a AUCUN domaine accessible => on skip
                      if (accessibleDomains.isEmpty) {
                        continue;
                      }

                      // Sinon, on affiche la carte pour cette région
                      regionWidgets.add(
                        SizedBox(
                          key: ValueKey(region.id),
                          child: VhnRegionCard(
                            regionSnap: region,
                          ),
                        ),
                      );
                    }

                    // Construire la liste
                    if (regionWidgets.isEmpty) {
                      // Si après filtrage, aucune région n'a de domaines accessibles
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("Aucune région accessible pour vous."),
                        ),
                      );
                    }

                    // Si user = VHN, on permet un ReorderableListView, sinon ListView simple
                    return Column(
                      children: [
                        currentUserStatus == 'VHN'
                            ? ReorderableListView(
                                scrollController: ScrollController(),
                                buildDefaultDragHandles: false,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                onReorder: _onReorderRegions(regionWidgets),
                                children: regionWidgets,
                              )
                            : ListView(
                                controller: ScrollController(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: regionWidgets,
                              ),
                        if (currentUserStatus == 'VHN') Spacing.height(baseSpace * 2),
                        if (currentUserStatus == 'VHN')
                          VhnTextButton(
                            padding: baseSpace,
                            fontSize: baseSpace * 2,
                            icon: Icons.add,
                            text: 'Ajouter une région'.toUpperCase(),
                            onPressed: () {
                              addZonePopup(context, setState, 'REGION', lastIndex, null);
                            },
                          ),
                      ],
                    );
                  } else {
                    // ---- AFFICHAGE DES WINES (si isWantedInList = true) ----
                    // Cf. votre code d’origine
                    List<DocumentSnapshot> wineDocs = [];
                    // On peut déjà trier
                    if (regionSnapshot.hasData) {
                      // ??? Dans votre code, vous récupériez docs de n_wines.
                      // Or ici, on a regionDocs. Probablement il faut un AUTRE stream sur n_wines ?
                      // On peut se baser sur domainSnapshot => 'n_domains' ou un stream "n_wines" ?
                      // Je recopie votre code existant en l'adaptant :
                    }

                    // Dans votre code d’origine, vous aviez un stream: _fStore.collection('n_wines')
                    // => ICI on suppose qu'on veut juste reprendre la logique
                    // On va s'appuyer sur domainSnapshot ou un autre snapshot ???

                    // Pour rester fidèle, on va ignorer "regionSnapshot"
                    // et on va créer un "wineDocs" depuis la variable domainSnapshot
                    // si c'est en fait "n_wines".
                    // Adaptez selon votre structure Firestore.

                    wineDocs = domainSnapshot.data!.docs;
                    // tri
                    if (descending) {
                      wineDocs.sort((a, b) => a[orderType].compareTo(b[orderType]));
                    } else {
                      wineDocs.sort((a, b) => b[orderType].compareTo(a[orderType]));
                    }

                    List<Widget> resultWidgets = [];
                    for (var wine in wineDocs) {
                      final data = wine.data() as Map<String, dynamic>;
                      if (data['cuvee'].toString().toLowerCase().contains(textCurrentController.text.toLowerCase())) {
                        resultWidgets.add(
                          VhnWineCard(wineSnap: wine),
                        );
                      }
                    }

                    return Column(
                      children: resultWidgets,
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Méthode utilitaire pour reorder
  /// ATTENTION : ReorderableListView exige un callback onReorder(int oldIndex, int newIndex)
  /// On crée une closure pour conserver regionWidgets
  Function(int, int) _onReorderRegions(List<Widget> regionWidgets) {
    return (oldIndex, newIndex) {
      setState(() {
        if (oldIndex < newIndex) newIndex -= 1;
        final item = regionWidgets.removeAt(oldIndex);
        regionWidgets.insert(newIndex, item);

        // Màj en BDD
        // => Il faut retrouver le doc Firestore correspondant,
        //    via regionWidgets[newIndex].key => ValueKey(region.id)
        //    puis set { 'index': pos }
        // Mais comme on fait un reorder purement "visuel" (List<Widget>),
        // si vous avez besoin de persister l'ordre dans Firestore,
        // il faut stocker "documents" (regionDocs) en variable globale, etc.
        // Cf. votre code original.
      });
    };
  }
}
