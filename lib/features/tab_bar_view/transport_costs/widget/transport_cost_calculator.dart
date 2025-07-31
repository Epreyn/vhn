import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vhn/models/dropdownbutton_model.dart';

import '../../../../constants/data.dart';
import '../../../../core/classes/spacing.dart';
import '../../../../widgets/buttons/dropdown_button_maker.dart';
import '../../../../widgets/input_fields/vhn_input_field.dart';

class TransportCostCalculator extends StatefulWidget {
  final FirebaseFirestore fStore;

  const TransportCostCalculator({Key? key, required this.fStore}) : super(key: key);

  @override
  State<TransportCostCalculator> createState() => _TransportCostCalculatorState();
}

class _TransportCostCalculatorState extends State<TransportCostCalculator> {
  // Nombre de produits (bouteilles) saisi par l’utilisateur
  int productCount = 0;

  // On stocke les coûts calculés pour les 3 transporteurs
  double? _stefCost;
  double? _schenkerCost;
  double? _bonnardCost;

  // Contrôleur pour la saisie du nombre de bouteilles
  TextEditingController controller = TextEditingController(text: "0");

  // Le département sélectionné dans le dropdown
  // On part du principe que currentUserDepartments n’est pas vide
  String selectedDepartment = currentUserDepartments.isNotEmpty ? currentUserDepartments[0] : '01';

  // Liste des documents Firestore correspondant au département sélectionné
  List<DocumentSnapshot> documents = [];
  DocumentSnapshot? currentDoc;

  // On retient l'ID du doc pour détecter un changement
  String? lastDocId;

  /// Récupère la liste des départements (clés de kDeploy)
  List<String> getDepartments() {
    return kDeploy.keys.toList();
  }

  /// Additionne un forfait fixe + un % sur le coût de base, en fonction du transporteur
  /// STEF = index 0, SCHENKER = 1, BONNARD = 2
  double addFixedRateWithCostDouble(int transporterIndex, double baseCost) {
    // STEF 14 + 20%
    // SCHENKER 9 + 20%
    // BONNARD 8 + 20%
    int flat = 0;
    double percent = 0.20;

    switch (transporterIndex) {
      case 0: // STEF
        flat = 14;
        break;
      case 1: // SCHENKER
        flat = 9;
        break;
      case 2: // BONNARD
        flat = 8;
        break;
    }

    double r1 = baseCost + flat;
    double r2 = r1 + (r1 * percent);
    return r2;
  }

  /// Convertit un prix unitaire (en String) en double puis le multiplie par le nombre de produits
  double costMultiplication(String price, int count) {
    double cost = double.parse(price) * count;
    return cost;
  }

  /// Calcule les 3 coûts en fonction des plages de productCount
  /// et met à jour _stefCost, _schenkerCost, _bonnardCost
  void calculateTransportCost(DocumentSnapshot transportCostDocument) {
    if (controller.text.trim().isEmpty) {
      productCount = 0;
    } else {
      productCount = int.parse(controller.text);
    }

    if (productCount == 0) {
      setState(() {
        _stefCost = null;
        _schenkerCost = null;
        _bonnardCost = null;
      });
      return;
    }

    final doc = transportCostDocument.data() as Map<String, dynamic>;

    double? stef, schenker, bonnard;

    /// Petit utilitaire pour lire un champ, puis ajouter le forfait + % selon transporteurIndex
    double parseAndAddFixedRate(int transporterIndex, String fieldName, {bool multiply = false}) {
      double baseVal = double.parse(doc[fieldName]);
      if (multiply) baseVal *= productCount;
      return addFixedRateWithCostDouble(transporterIndex, baseVal);
    }

    // --- Logique de plages ---
    if (productCount >= 1 && productCount <= 3) {
      stef = parseAndAddFixedRate(0, 'package1To36');
      schenker = parseAndAddFixedRate(1, 'package1To3_B');
      bonnard = parseAndAddFixedRate(2, 'package1To6_C');
    }
    if (productCount >= 4 && productCount <= 6) {
      stef = parseAndAddFixedRate(0, 'package1To36');
      schenker = parseAndAddFixedRate(1, 'package4To6_B');
      bonnard = parseAndAddFixedRate(2, 'package1To6_C');
    }
    if (productCount >= 7 && productCount <= 12) {
      stef = parseAndAddFixedRate(0, 'package1To36');
      schenker = parseAndAddFixedRate(1, 'package7To12_B');
      bonnard = parseAndAddFixedRate(2, 'package7To12_C');
    }
    if (productCount >= 13 && productCount <= 18) {
      stef = parseAndAddFixedRate(0, 'package1To36');
      schenker = parseAndAddFixedRate(1, 'package13To18_B');
      bonnard = parseAndAddFixedRate(2, 'package13To24_C');
    }
    if (productCount >= 19 && productCount <= 24) {
      stef = parseAndAddFixedRate(0, 'package1To36');
      schenker = parseAndAddFixedRate(1, 'package19To24_B');
      bonnard = parseAndAddFixedRate(2, 'package13To24_C');
    }
    if (productCount >= 25 && productCount <= 36) {
      stef = parseAndAddFixedRate(0, 'package1To36');
      schenker = parseAndAddFixedRate(1, 'package25To36_B');
      bonnard = parseAndAddFixedRate(2, 'package25To36_C');
    }
    if (productCount >= 37 && productCount <= 48) {
      stef = parseAndAddFixedRate(0, 'package37To72');
      schenker = parseAndAddFixedRate(1, 'package37To48_B');
      bonnard = parseAndAddFixedRate(2, 'package37To48_C');
    }
    if (productCount >= 49 && productCount <= 60) {
      stef = parseAndAddFixedRate(0, 'package37To72');
      schenker = parseAndAddFixedRate(1, 'package49To60_B');
      bonnard = parseAndAddFixedRate(2, 'package49To72_C');
    }
    if (productCount >= 61 && productCount <= 72) {
      stef = parseAndAddFixedRate(0, 'package37To72');
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package61To299_B'], productCount));
      bonnard = parseAndAddFixedRate(2, 'package49To72_C');
    }
    if (productCount >= 73 && productCount <= 75) {
      stef = addFixedRateWithCostDouble(0, costMultiplication(doc['package73To120'], productCount));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package61To299_B'], productCount));
      bonnard = parseAndAddFixedRate(2, 'package73To96_C');
    }
    if (productCount >= 76 && productCount <= 96) {
      stef = addFixedRateWithCostDouble(0, costMultiplication(doc['package73To120'], productCount));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package61To299_B'], productCount));
      bonnard = parseAndAddFixedRate(2, 'package73To96_C');
    }
    if (productCount >= 97 && productCount <= 115) {
      stef = addFixedRateWithCostDouble(0, costMultiplication(doc['package73To120'], productCount));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package61To299_B'], productCount));
      bonnard = addFixedRateWithCostDouble(2, costMultiplication(doc['package97To300_C'], productCount));
    }
    if (productCount >= 116 && productCount <= 120) {
      stef = addFixedRateWithCostDouble(0, costMultiplication(doc['package73To120'], productCount));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package61To299_B'], productCount));
      bonnard = addFixedRateWithCostDouble(2, costMultiplication(doc['package97To300_C'], productCount));
    }
    if (productCount >= 121 && productCount <= 150) {
      stef = addFixedRateWithCostDouble(0, costMultiplication(doc['package121To150'], productCount));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package61To299_B'], productCount));
      bonnard = addFixedRateWithCostDouble(2, costMultiplication(doc['package97To300_C'], productCount));
    }
    if (productCount >= 151 && productCount <= 200) {
      stef = addFixedRateWithCostDouble(0, costMultiplication(doc['package151To200'], productCount));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package61To299_B'], productCount));
      bonnard = addFixedRateWithCostDouble(2, costMultiplication(doc['package97To300_C'], productCount));
    }
    if (productCount >= 201 && productCount <= 250) {
      stef = addFixedRateWithCostDouble(0, costMultiplication(doc['package201To250'], productCount));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package61To299_B'], productCount));
      bonnard = addFixedRateWithCostDouble(2, costMultiplication(doc['package97To300_C'], productCount));
    }
    if (productCount >= 251 && productCount <= 299) {
      stef = addFixedRateWithCostDouble(0, double.parse(doc['palletFor1']));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package61To299_B'], productCount));
      bonnard = addFixedRateWithCostDouble(2, costMultiplication(doc['package97To300_C'], productCount));
    }
    if (productCount >= 300 && productCount <= 599) {
      stef = addFixedRateWithCostDouble(0, double.parse(doc['palletFor1']));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package300To599_B'], productCount));
      bonnard = addFixedRateWithCostDouble(2, double.parse(doc['palletFor1_C']));
    }
    if (productCount >= 600 && productCount <= 799) {
      stef = addFixedRateWithCostDouble(0, double.parse(doc['pallet2To3']));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package600To799_B'], productCount));
      bonnard = addFixedRateWithCostDouble(2, double.parse(doc['palletFor2_C']));
    }
    if (productCount >= 800 && productCount <= 1199) {
      stef = addFixedRateWithCostDouble(0, double.parse(doc['pallet2To3']));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package800To1199_B'], productCount));
      bonnard = addFixedRateWithCostDouble(2, double.parse(doc['palletFor2_C']));
    }
    if (productCount >= 1200 && productCount <= 1800) {
      stef = addFixedRateWithCostDouble(0, double.parse(doc['pallet2To3']));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package1200_B'], productCount));
      bonnard = addFixedRateWithCostDouble(2, double.parse(doc['palletFor3_C']));
    }
    if (productCount > 1800) {
      stef = addFixedRateWithCostDouble(0, double.parse(doc['pallet4To6']));
      schenker = addFixedRateWithCostDouble(1, costMultiplication(doc['package1200_B'], productCount));
      bonnard = addFixedRateWithCostDouble(2, double.parse(doc['palletFor3_C']));
    }

    setState(() {
      _stefCost = stef;
      _schenkerCost = schenker;
      _bonnardCost = bonnard;
    });
  }

  /// Incrémente le nb de bouteilles
  void increment() {
    setState(() {
      productCount++;
      controller.text = productCount.toString();
    });
    if (currentDoc != null) {
      calculateTransportCost(currentDoc!);
    }
  }

  /// Décrémente le nb de bouteilles
  void decrement() {
    if (productCount > 1) {
      setState(() {
        productCount--;
        controller.text = productCount.toString();
      });
    } else {
      setState(() {
        productCount = 0;
        controller.text = "0";
      });
    }
    if (currentDoc != null) {
      calculateTransportCost(currentDoc!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Calculez vos frais de transport",
          style: TextStyle(fontSize: baseSpace * 2.5),
        ),
        Spacing.height(baseSpace * 6),
        Text(
          "Département",
          style: TextStyle(
            color: Colors.blue,
            fontSize: baseSpace * 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacing.height(baseSpace),
        SizedBox(
          width: 200,
          child: DropDownButtonMaker(
            model: DropDownButtonModel(
              hint: '',
              items: getDepartments(),
              initialValue: selectedDepartment,
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value!;
                  // on peut remettre productCount = 0 si on veut
                  // productCount = 0;
                  // controller.text = '0';
                });
              },
            ),
            width: 200,
          ),
        ),
        Spacing.height(baseSpace * 2),
        StreamBuilder<QuerySnapshot>(
          stream: widget.fStore
              .collection('transport_costs')
              .where('department', isEqualTo: selectedDepartment)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Aucune donnée de transport trouvée pour ce département."));
            }

            documents = snapshot.data!.docs;
            final newDoc = documents[0];
            final newDocId = newDoc.id;

            // Si ce doc est différent du précédent => on update currentDoc,
            // mais on ne calcule pas tout de suite en build => addPostFrameCallback
            if (newDocId != lastDocId) {
              lastDocId = newDocId;
              currentDoc = newDoc;

              // On recalcule après le build, pour éviter setState() dans le build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  calculateTransportCost(newDoc);
                }
              });
            } else {
              // Sinon, on set la currentDoc, mais sans recalculer
              currentDoc = newDoc;
            }

            return _buildCalculatorUI();
          },
        ),
      ],
    );
  }

  /// Construit tout le bloc UI de calcul (boutons + affichage)
  Widget _buildCalculatorUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacing.height(baseSpace * 2),
        Text(
          "Nombre de Cols",
          style: TextStyle(
            color: Colors.blue,
            fontSize: baseSpace * 2,
            fontWeight: FontWeight.bold,
          ),
        ),

        Spacing.height(baseSpace),

        // Contrôles + saisie du nombre
        SizedBox(
          width: 400,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.blue),
                onPressed: decrement,
                iconSize: baseSpace * 8,
              ),
              SizedBox(
                width: 150,
                child: VhnInputField(
                  text: '',
                  centeredText: true,
                  controller: controller,
                  fontSize: baseSpace * 6,
                  bold: true,
                  onChange: (value) {
                    if (currentDoc != null) {
                      calculateTransportCost(currentDoc!);
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                onPressed: increment,
                iconSize: baseSpace * 8,
              ),
            ],
          ),
        ),

        Spacing.height(baseSpace * 4),
        _buildComparator(),
        Spacing.height(baseSpace * 4),
        SizedBox(
          width: 250,
          child: Text(
            'Les tarifs relatifs au transport sont donnés à titre indicatif '
            'et sont amenés à varier selon les conditions de transport.',
            style: const TextStyle(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Construit le comparateur (3 cartes) en mettant en valeur le meilleur prix
  Widget _buildComparator() {
    // Si le nombre de produits = 0 ou si l'un des costs est null,
    // on n'affiche rien ou un message
    if (productCount == 0 || _stefCost == null || _schenkerCost == null || _bonnardCost == null) {
      return Text(
        "Entrez un nombre de bouteilles pour calculer le coût.",
        style: TextStyle(fontSize: baseSpace * 2),
      );
    }

    // On détermine le minimum
    final bestCost = min(_stefCost!, min(_schenkerCost!, _bonnardCost!));

    // Affiche un Row avec 3 colonnes
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTransportCard("STEF", _stefCost!, bestCost),
        SizedBox(width: baseSpace * 2),
        _buildTransportCard("SCHENKER", _schenkerCost!, bestCost),
        SizedBox(width: baseSpace * 2),
        _buildTransportCard("BONNARD", _bonnardCost!, bestCost),
      ],
    );
  }

  /// Construit la "carte" pour un transporteur donné
  Widget _buildTransportCard(String name, double cost, double bestCost) {
    bool isBest = (cost == bestCost);

    return Card(
      elevation: 3,
      child: Container(
        width: 120,
        padding: EdgeInsets.all(baseSpace * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: baseSpace * 1.5,
              ),
            ),
            Spacing.height(baseSpace),
            Text(
              "${cost.toStringAsFixed(2)} € HT",
              style: TextStyle(
                fontSize: baseSpace * 1.5,
              ),
            ),
            if (isBest) ...[
              Spacing.height(baseSpace),
              Text(
                "Meilleur prix",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: baseSpace * 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
