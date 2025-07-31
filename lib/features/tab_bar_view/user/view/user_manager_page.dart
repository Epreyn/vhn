import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:vhn/constants/style/text_style.dart';
import 'package:vhn/features/tab_bar_view/user/widget/card_of_user.dart';
import 'package:vhn/functions/dynamic_column_of_datatable.dart';
import 'package:vhn/functions/edit/edit_user_popup.dart';
import 'package:vhn/widgets/buttons/vhn_elevated_button.dart';
import 'package:vhn/widgets/columns/vhn_column.dart';

import '../../../../constants/data.dart';
import '../../../../core/classes/spacing.dart';
import '../../../../core/classes/uniques_controllers.dart';
import '../../../../models/dropdownbutton_model.dart';

class UserManagerPage extends StatefulWidget {
  const UserManagerPage({
    Key? key,
  }) : super(key: key);

  @override
  _UserManagerPageState createState() => _UserManagerPageState();
}

class _UserManagerPageState extends State<UserManagerPage> {
  bool isLoaded = false;

  final _fStore = FirebaseFirestore.instance;
  late List<DocumentSnapshot> documents;

  String orderType = 'validation';
  bool descending = false;
  bool archived = false;

  // VARIABLE POUR MODIFICATION UTILISATEUR
  String? initialValue;
  List<String> items = [
    'Agent',
    'CHR',
    'Caviste',
    'VHN',
    'Vigneron',
    'Ambassade',
    'Particulier', // Ajouter Particulier à la liste
  ];

  void sortColumn(int columnIndex) {
    setState(() {
      switch (columnIndex) {
        case 0:
          orderType = 'email';
          descending = !descending;
          break;
        case 1:
          orderType = 'entreprise';
          descending = !descending;
          break;
        case 2:
          orderType = 'statut';
          descending = !descending;
          break;
      }
    });
  }

  Widget headerUserFilter(
      String label, String filterBy, bool descending, int columnIndex) {
    Widget button = const SizedBox();

    if (orderType.toLowerCase() == filterBy.toLowerCase()) {
      button = Expanded(
        flex: 1,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: TextButton.icon(
            onPressed: () {
              sortColumn(columnIndex);
            },
            icon: descending == true
                ? const Icon(Icons.arrow_downward)
                : const Icon(Icons.arrow_upward),
            label: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                label,
                style: kUserDataHeaderFilterStyle,
              ),
            ),
          ),
        ),
      );
    } else {
      button = Expanded(
        flex: 1,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: TextButton(
            onPressed: () {
              sortColumn(columnIndex);
            },
            child: Text(
              label,
              style: kUserDataHeaderFilterStyle,
            ),
          ),
        ),
      );
    }

    return button;
  }

  @override
  Widget build(BuildContext context) {
    Widget getArchivedButton() {
      return VhnElevatedButton(
        text: 'Archivés',
        color: !archived ? Colors.white : null,
        textColor: !archived ? Colors.blue : null,
        onPress: () {
          setState(() => archived = !archived);
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: VhnColumn(
        centered: false,
        width: dynamicColumnOfDataTable(context),
        widgets: [
          Spacing.height(baseSpace * 4),
          // Utiliser ValueListenableBuilder au lieu de Obx pour écouter les changements
          ValueListenableBuilder<int>(
            valueListenable: searchUpdateNotifier,
            builder: (context, _, __) {
              return StreamBuilder<QuerySnapshot>(
                stream: _fStore
                    .collection('utilisateurs')
                    .orderBy(orderType, descending: descending)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<Widget> resultWidgets = [];
                  if (snapshot.hasData) {
                    documents = snapshot.data!.docs;

                    for (var doc in documents) {
                      // Récupérer la map globale
                      final data = doc.data() as Map<String, dynamic>;

                      // Prévenir les champs inexistants en prenant une valeur par défaut
                      String email = data['email']?.toString() ?? '';
                      String entreprise = data['entreprise']?.toString() ?? '';
                      String statut = data['statut']?.toString() ?? '';
                      bool validation = data['validation'] ?? false;
                      bool isArchived = data['archive'] ?? false;

                      // Champs utiles pour l'édition
                      String address = data['adresse']?.toString() ?? '';
                      String postalCode = data['code postal']?.toString() ?? '';
                      String department = data['département']?.toString() ?? '';
                      String city = data['ville']?.toString() ?? '';
                      String telephone = data['téléphone']?.toString() ?? '';

                      // Vérifier si le statut existe dans la liste, sinon utiliser le premier élément
                      String dropdownValue = statut;
                      if (!items.contains(statut)) {
                        // Si le statut n'est pas dans la liste, on peut soit :
                        // 1. L'ajouter à la liste (ce qu'on fait ci-dessous)
                        // 2. Ou utiliser une valeur par défaut
                        if (statut.isNotEmpty) {
                          items.add(statut);
                          dropdownValue = statut;
                        } else {
                          dropdownValue = items.first;
                        }
                      }

                      // Dropdown avec la valeur corrigée
                      DropDownButtonModel model = DropDownButtonModel(
                        hint: '',
                        items: items,
                        initialValue: dropdownValue,
                        onChanged: (String? value) {
                          if (value != null && value.isNotEmpty) {
                            _fStore.collection("utilisateurs").doc(doc.id).set(
                                {'statut': value}, SetOptions(merge: true));
                          }
                        },
                      );

                      // La Card
                      CardOfUser widgetCard = CardOfUser(
                        user: doc,
                        model: model,
                        onPressed: () {
                          editUserPopup(context, setState, {
                            'id': doc.id,
                            'address': address,
                            'postal_code': postalCode,
                            'department': department,
                            'company': entreprise,
                            'telephone': telephone,
                            'city': city,
                          });
                        },
                        onChangedValidation: () {
                          _fStore.collection('utilisateurs').doc(doc.id).set(
                              {'validation': !validation},
                              SetOptions(merge: true));
                          if (!validation) {
                            sendMail(
                              setState,
                              context,
                              email,
                              'Validation d\'inscription Vins Hors Normes',
                              'Votre compte sur l\'application Vins Hors Normes a été validé.\n\n'
                                  'Vous pouvez désormais accéder à l\'application.',
                            );
                          }
                        },
                        onChangedArchived: () {
                          _fStore.collection('utilisateurs').doc(doc.id).set(
                              {'archive': !isArchived},
                              SetOptions(merge: true));
                        },
                      );

                      // GESTION FILTRE DE RECHERCHE
                      final searchText =
                          userSearchController.text.toLowerCase();
                      final isSearching = searchText.length > 1;

                      if (isSearching) {
                        // Si on fait une recherche, on filtre sur l'input
                        if (entreprise.toLowerCase().contains(searchText) ||
                            email.toLowerCase().contains(searchText) ||
                            statut.toLowerCase().contains(searchText) ||
                            department.toLowerCase().contains(searchText) ||
                            postalCode.toLowerCase().contains(searchText) ||
                            city.toLowerCase().contains(searchText) ||
                            address.toLowerCase().contains(searchText)) {
                          resultWidgets.add(widgetCard);
                        }
                      } else {
                        // Pas de recherche, on affiche que les non-validés + archive = archived ?
                        if (validation == false && isArchived == archived) {
                          resultWidgets.add(widgetCard);
                        }
                      }
                    }
                  }

                  // Si recherche active mais aucun résultat
                  final searchText = userSearchController.text.toLowerCase();
                  final isSearching = searchText.length > 1;

                  if (isSearching && resultWidgets.isEmpty) {
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
                            'Aucun utilisateur trouvé pour "$searchText"',
                            style: TextStyle(
                              fontSize: baseSpace * 2.5,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Affichage final
                  return Column(
                    children: resultWidgets.isNotEmpty
                        ? [
                            // En-tête des colonnes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Spacing.width(baseSpace),
                                      headerUserFilter(
                                          'Email', 'email', descending, 0),
                                      Spacing.width(baseSpace),
                                      headerUserFilter('Entreprise',
                                          'entreprise', descending, 1),
                                      Spacing.width(baseSpace),
                                      headerUserFilter(
                                          'Status', 'statut', descending, 2),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: getArchivedButton(),
                                  ),
                                ),
                              ],
                            ),
                            Spacing.height(baseSpace * 4),
                            // Les cards
                            for (var card in resultWidgets) card,
                          ]
                        : [
                            // S'il n'y a pas de résultat
                            Row(
                              children: [
                                Center(
                                  child: Text(
                                    archived
                                        ? 'Vous n\'avez aucune inscription archivée'
                                        : 'Toutes les inscriptions sont validées',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: getArchivedButton(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
