import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DepartmentManager extends StatefulWidget {
  final fStore;
  String departmentParam;
  bool descending;

  DepartmentManager({
    Key? key,
    required this.fStore,
    required this.departmentParam,
    required this.descending,
  }) : super(key: key);

  @override
  State<DepartmentManager> createState() => _DepartmentManagerState();
}

class _DepartmentManagerState extends State<DepartmentManager> {
  String orderType = 'name';
  late List<DocumentSnapshot> documents;

  List<dynamic> regions = [];

  bool filterByValidation = false;
  bool validationParam = true;

  // --- ENTÊTES DE COLONNE ---
  DataColumn dataHeaderDomainTitle(String title, String orderBy, int columnIndex, double? fontSize) {
    IconData? icon;

    if (orderBy.toLowerCase() == orderType.toLowerCase()) {
      widget.descending == false ? icon = Icons.arrow_downward : icon = Icons.arrow_upward;
    }
    return DataColumn(
      label: InkWell(
        onTap: () {
          setState(() {
            switch (columnIndex) {
              case 0:
                orderType = 'name';
                widget.descending = !widget.descending;
                filterByValidation = false;
                break;
              case 1:
                orderType = 'regionID';
                widget.descending = !widget.descending;
                filterByValidation = false;
                break;
              case 2:
                orderType = 'isValidated';
                widget.descending = !widget.descending;
                break;
            }
          });
        },
        child: Row(
          children: [
            if (icon != null) Icon(icon, size: 18),
            const SizedBox(width: 4),
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

  // --- RÉCUPÉRATION DES RÉGIONS ---
  Future<void> getRegions() async {
    QuerySnapshot regionSnapshot = await FirebaseFirestore.instance.collection("n_regions").get();
    for (var region in regionSnapshot.docs) {
      regions.add(region);
    }
  }

  @override
  void initState() {
    getRegions();
    super.initState();
  }

  // --- TRI / FILTRE SUR LA COLONNE 'orderType' ---
  void updateHeaderFilter() {
    switch (widget.descending) {
      case true:
        if (orderType != 'isValidated') {
          documents.sort((a, b) => a[orderType].compareTo(b[orderType]));
          filterByValidation = false;
        } else {
          filterByValidation = true;
          validationParam = true;
        }
        break;
      case false:
        if (orderType != 'isValidated') {
          documents.sort((a, b) => b[orderType].compareTo(a[orderType]));
          filterByValidation = false;
        } else {
          filterByValidation = true;
          validationParam = false;
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.fStore.collection('n_domains').snapshots(),
      builder: (context, snapshot) {
        List<DataRow> resultWidgets = [];

        if (snapshot.hasData) {
          documents = snapshot.data!.docs;
          // On applique le tri/filtre avant de générer le DataRow
          updateHeaderFilter();

          for (var domain in documents) {
            var deploy = domain['deploy'];
            String regionName = '';

            // Retrouver le nom de la région via regionID
            for (var regionDocSnapshot in regions) {
              if (regionDocSnapshot.id == domain['regionID']) {
                regionName = regionDocSnapshot['name'];
                break;
              }
            }

            // FILTRE sur la validation (isValidated)
            if (filterByValidation == true) {
              // On veut afficher soit les "true" soit les "false"
              if (validationParam == true) {
                // n'afficher que ceux qui sont "true" dans deploy[departmentParam]
                if (domain['deploy'][widget.departmentParam] == true) {
                  resultWidgets.add(_buildDataRow(domain, deploy, regionName));
                }
              } else {
                // n'afficher que ceux qui sont "false"
                if (domain['deploy'][widget.departmentParam] == false) {
                  resultWidgets.add(_buildDataRow(domain, deploy, regionName));
                }
              }
            } else {
              // Pas de filtre, on affiche tout
              resultWidgets.add(_buildDataRow(domain, deploy, regionName));
            }
          }
        }

        // --- CONSTRUCTION DU TABLEAU ---
        return LayoutBuilder(
          builder: (context, constraints) {
            // constraints.maxWidth = largeur max dispo
            return Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  // Force la DataTable à occuper au moins la largeur de son parent
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 30,
                    columns: [
                      dataHeaderDomainTitle('Nom', 'name', 0, null),
                      dataHeaderDomainTitle('Région', 'regionID', 1, null),
                      dataHeaderDomainTitle('Distribution', 'isValidated', 2, null),
                    ],
                    rows: resultWidgets,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Extrait la logique de construction d’une ligne
  DataRow _buildDataRow(dynamic domain, Map deploy, String regionName) {
    return DataRow(
      cells: [
        DataCell(Text(domain['name'])),
        DataCell(Text(regionName)),
        DataCell(
          Switch(
            value: deploy[widget.departmentParam],
            onChanged: (value) {
              deploy[widget.departmentParam] = value;
              widget.fStore.collection('n_domains').doc(domain.id).set(
                {'deploy': deploy},
                SetOptions(merge: true),
              );
            },
          ),
        ),
      ],
    );
  }
}
