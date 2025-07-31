import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// Importez vos widgets et constantes :
import 'package:vhn/constants/data.dart';
import 'package:vhn/features/tab_bar_view/transport_costs/widget/department_manager.dart';
import 'package:vhn/features/tab_bar_view/transport_costs/widget/transport_cost_calculator.dart';
import 'package:vhn/models/dropdownbutton_model.dart';
import 'package:vhn/widgets/buttons/dropdown_button_maker.dart';
import 'package:vhn/widgets/input_fields/vhn_focus_input_field.dart';

// Exemples de champs pour chaque transporteur
// Adaptez selon vos besoins.

final List<Map<String, String>> stefFields = [
  {'label': '1 à 36 cols', 'key': 'package1To36'},
  {'label': '37 à 72 cols', 'key': 'package37To72'},
  {'label': '73 à 120 cols', 'key': 'package73To120'},
  {'label': '121 à 150 cols', 'key': 'package121To150'},
  {'label': '151 à 200 cols', 'key': 'package151To200'},
  {'label': '201 à 250 cols', 'key': 'package201To250'},
  {'label': '1 palette', 'key': 'palletFor1'},
  {'label': '2 à 3 palettes', 'key': 'pallet2To3'},
  {'label': '4 à 6 palettes', 'key': 'pallet4To6'},
];

final List<Map<String, String>> schenkerFields = [
  {'label': '1 à 3 cols', 'key': 'package1To3_B'},
  {'label': '4 à 6 cols', 'key': 'package4To6_B'},
  {'label': '7 à 12 cols', 'key': 'package7To12_B'},
  {'label': '13 à 18 cols', 'key': 'package13To18_B'},
  {'label': '19 à 24 cols', 'key': 'package19To24_B'},
  {'label': '25 à 36 cols', 'key': 'package25To36_B'},
  {'label': '37 à 48 cols', 'key': 'package37To48_B'},
  {'label': '49 à 60 cols', 'key': 'package49To60_B'},
  {'label': '61 à 299 cols', 'key': 'package61To299_B'},
  {'label': '300 à 599 cols', 'key': 'package300To599_B'},
  {'label': '600 à 799 cols', 'key': 'package600To799_B'},
  {'label': '800 à 1199 cols', 'key': 'package800To1199_B'},
  {'label': '+1200 cols', 'key': 'package1200_B'},
];

final List<Map<String, String>> bonnardFields = [
  {'label': '1 à 6 cols', 'key': 'package1To6_C'},
  {'label': '7 à 12 cols', 'key': 'package7To12_C'},
  {'label': '13 à 24 cols', 'key': 'package13To24_C'},
  {'label': '25 à 36 cols', 'key': 'package25To36_C'},
  {'label': '37 à 48 cols', 'key': 'package37To48_C'},
  {'label': '49 à 72 cols', 'key': 'package49To72_C'},
  {'label': '73 à 96 cols', 'key': 'package73To96_C'},
  {'label': '97 à 300 cols', 'key': 'package97To300_C'},
  {'label': 'Palette 1', 'key': 'palletFor1_C'},
  {'label': 'Palette 2', 'key': 'palletFor2_C'},
  {'label': 'Palette 3', 'key': 'palletFor3_C'},
];

class TransportCostsView extends StatefulWidget {
  const TransportCostsView({Key? key}) : super(key: key);

  @override
  State<TransportCostsView> createState() => _TransportCostsViewState();
}

class _TransportCostsViewState extends State<TransportCostsView> with SingleTickerProviderStateMixin {
  final _fStore = FirebaseFirestore.instance;

  late TabController _tabController;

  String queryParam = '01';
  String initialValueForDepartment = '01';
  bool descending = true;

  @override
  void initState() {
    super.initState();
    // 4 onglets : STEF, SCHENKER, BONNARD, Domaines distribués
    _tabController = TabController(length: 4, vsync: this);
  }

  // Liste des départements (clés dans kDeploy)
  List<String> getDepartments() {
    List<String> departments = [];
    kDeploy.forEach((key, value) {
      departments.add(key);
    });
    return departments;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserStatus != 'VHN') {
      return TransportCostCalculator(fStore: _fStore);
    }

    final bool isReadOnly = (currentUserStatus == 'Agent');

    // Sinon, page admin avec Tabs
    return Scaffold(
      appBar: AppBar(
        //title: const Text("Gestion des tarifs de transport"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Choix du département
              const SizedBox(height: 8),
              Text(
                "Département",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 200,
                child: DropDownButtonMaker(
                  model: DropDownButtonModel(
                    hint: '',
                    items: getDepartments(),
                    initialValue: initialValueForDepartment,
                    onChanged: (value) {
                      setState(() {
                        initialValueForDepartment = value!;
                        queryParam = value;
                      });
                    },
                  ),
                  width: 200,
                ),
              ),
              const SizedBox(height: 8),
              // TabBar
              TabBar(
                controller: _tabController,
                isScrollable: false,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: "STEF"),
                  Tab(text: "SCHENKER"),
                  Tab(text: "BONNARD"),
                  Tab(text: "Domaines"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // --- Onglet STEF ---
          TransportCostTab(
            fStore: _fStore,
            queryParam: queryParam,
            descending: descending,
            fields: stefFields,
            isReadOnly: isReadOnly,
          ),
          // --- Onglet SCHENKER ---
          TransportCostTab(
            fStore: _fStore,
            queryParam: queryParam,
            descending: descending,
            fields: schenkerFields,
            isReadOnly: isReadOnly,
          ),
          // --- Onglet BONNARD ---
          TransportCostTab(
            fStore: _fStore,
            queryParam: queryParam,
            descending: descending,
            fields: bonnardFields,
            isReadOnly: isReadOnly,
          ),
          // --- Onglet Domaines distribués ---
          isReadOnly
              ? Container()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: DepartmentManager(
                    fStore: _fStore,
                    departmentParam: queryParam,
                    descending: descending,
                  ),
                ),
        ],
      ),
    );
  }
}

/// Widget réutilisable qui construit une liste de tuiles (label + champ sur la même ligne)
/// en récupérant un ou plusieurs documents Firestore pour un "department" donné.
class TransportCostTab extends StatelessWidget {
  final FirebaseFirestore fStore;
  final String queryParam;
  final bool descending;
  final List<Map<String, String>> fields;
  final bool isReadOnly;

  const TransportCostTab({
    Key? key,
    required this.fStore,
    required this.queryParam,
    required this.descending,
    required this.fields,
    required this.isReadOnly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // On écoute la collection "transport_costs" filtrée sur le département
    // Adaptez si besoin (ex: "where('transporter', isEqualTo: 'STEF')" si vous séparez).
    return StreamBuilder<QuerySnapshot>(
      stream: fStore.collection('transport_costs').where('department', isEqualTo: queryParam).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Aucun tarif trouvé pour ce département."),
            ),
          );
        }

        // Si vous n'avez qu'un seul document par département, on prend le premier
        // Sinon, vous pouvez utiliser ListView.builder pour plusieurs docs
        final doc = docs.first;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: fields.map((field) {
              final label = field['label']!;
              final keyDb = field['key']!;
              final currentQuantity = doc[keyDb];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      // Label
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Champ de saisie
                      SizedBox(
                        width: 80,
                        child: isReadOnly
                            ? Text(
                                currentQuantity.toString(),
                                textAlign: TextAlign.right,
                              )
                            : VhnFocusInputField(
                                currentQuantity: currentQuantity,
                                transportCost: doc,
                                fStore: fStore,
                                fStoreFieldName: keyDb,
                              ),

                        // child: VhnFocusInputField(
                        //   currentQuantity: currentQuantity,
                        //   transportCost: doc,
                        //   fStore: fStore,
                        //   fStoreFieldName: keyDb,
                        // ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
