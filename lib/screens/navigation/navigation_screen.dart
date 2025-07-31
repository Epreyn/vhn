import 'dart:convert';
import 'dart:html';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:vhn/constants/data.dart';
import 'package:vhn/core/classes/uniques_controllers.dart';
import 'package:vhn/features/tab_bar_view/card_list/view/DomainManagerView.dart';
import 'package:vhn/features/tab_bar_view/card_list/view/card_list_manager_view.dart';
import 'package:vhn/features/tab_bar_view/card_list/view/wine_manager_view.dart';
import 'package:vhn/features/tab_bar_view/transport_costs/view/transport_costs_view.dart';
import 'package:vhn/features/tab_bar_view/unfoldable_data_table/view/stock_manager_page.dart';
import 'package:vhn/features/tab_bar_view/user/view/user_manager_page.dart';
import 'package:vhn/widgets/buttons/vhn_icon_button.dart';

import '../../features/tab_bar_view/transport_costs/widget/transport_cost_calculator.dart';
import '../../widgets/app_bars/vhn_appbar_backtrack.dart';
import '../../widgets/buttons/VhnTextButton.dart';
import '../../widgets/input_fields/vhn_input_field.dart';

class NavigationScreen extends StatefulWidget {
  String? path;
  String? id;

  NavigationScreen({Key? key, this.path, this.id}) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _fStore = FirebaseFirestore.instance;

  double winesCount = 1;
  double currentCount = 0;

  // Timer pour le debounce
  Timer? _debounceTimer;

  // Variable pour stocker la dernière valeur de recherche
  String _lastSearchValue = '';

  @override
  void initState() {
    super.initState();

    // S'assurer que les controllers sont initialisés
    if (!_areControllersInitialized()) {
      initializeGlobalData();
    }

    // Initialiser le TabController
    controller = TabController(
      length: currentUserStatus == 'VHN' ? 5 : 2,
      vsync: this,
    );

    // Listener pour détecter le changement de tab
    controller.addListener(() {
      if (!mounted) return;

      setState(() {
        UniquesControllers().data.screenIndex.value = controller.index;

        // Sauvegarder la valeur actuelle avant de changer
        if (textCurrentController != null) {
          _lastSearchValue = textCurrentController.text;
        }

        // Changer de controller selon le tab
        if (currentUserStatus == 'VHN') {
          if (controller.index == 3) {
            // Tab utilisateurs
            currentSearchType = SearchType.users;
            textCurrentController = userSearchController;
            // Effacer le controller utilisateur si on vient d'un autre tab
            if (_lastSearchValue.isNotEmpty &&
                currentSearchType != SearchType.users) {
              userSearchController.clear();
            }
          } else if (controller.index == 0 || controller.index == 1) {
            // Tabs Liste et Tableur
            currentSearchType = SearchType.wines;
            textCurrentController = wineSearchController;
          } else {
            // Autres tabs - ne pas toucher aux controllers
            textCurrentController = TextEditingController();
          }
        } else {
          // Pour les non-VHN
          if (controller.index == 0) {
            currentSearchType = SearchType.wines;
            textCurrentController = wineSearchController;
          } else {
            textCurrentController = TextEditingController();
          }
        }
      });
    });
  }

  bool _areControllersInitialized() {
    try {
      return wineSearchController != null && userSearchController != null;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    controller.dispose();
    // Ne pas disposer les controllers globaux ici
    super.dispose();
  }

  // Méthode pour déterminer si on doit afficher la barre de recherche
  bool shouldShowSearchBar() {
    if (currentUserStatus == 'VHN') {
      // Pour VHN : afficher sur Liste (0), Tableur (1) et Utilisateurs (3)
      return controller.index == 0 ||
          controller.index == 1 ||
          controller.index == 3;
    } else {
      // Pour les autres : afficher seulement sur Liste (0)
      return controller.index == 0;
    }
  }

  // Méthode de recherche avec debounce
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      // Forcer la mise à jour du notifier
      searchUpdateNotifier.value++;

      // Mettre à jour les flags de recherche selon le type
      final isSearching = value.length > 1;

      if (currentSearchType == SearchType.users) {
        UniquesControllers().data.isWantedInUser.value = isSearching;
      } else {
        UniquesControllers().data.isWantedInList.value = isSearching;
        UniquesControllers().data.isWantedInUnFoldable.value = isSearching;
      }
    });
  }

  String getSearchPlaceholder() {
    if (controller.index == 3 && currentUserStatus == 'VHN') {
      return 'Rechercher un utilisateur';
    } else {
      return 'Rechercher un vin';
    }
  }

  Future createExcel() async {
    final allwines = await _fStore.collection('n_wines').get();
    winesCount = allwines.docs.length.toDouble();
    currentCount = 0;

    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByIndex(1, 1).setText('Region');
    sheet.getRangeByIndex(1, 2).setText('Domaine');
    sheet.getRangeByIndex(1, 3).setText('Cuvée');
    sheet.getRangeByIndex(1, 4).setText('Quantité');
    sheet.getRangeByIndex(1, 5).setText('Format');
    sheet.getRangeByIndex(1, 6).setText('Couleur');
    sheet.getRangeByIndex(1, 7).setText('Millésime');
    sheet.getRangeByIndex(1, 8).setText('Conditionnement');
    sheet.getRangeByIndex(1, 9).setText('Tarif Caviste');
    sheet.getRangeByIndex(1, 10).setText('Tarif CHR');

    String currentRegion = '';
    String currentRegionName = '';
    String currentDomaine = '';
    String currentDomaineName = '';
    int count = 2;

    final regions =
        await _fStore.collection('n_regions').orderBy('index').get();

    for (var region in regions.docs) {
      currentRegion = region.id;
      currentRegionName = region['name'];

      final domaines = await _fStore
          .collection('n_domains')
          .where('regionID', isEqualTo: currentRegion)
          .get();

      for (var domaine in domaines.docs) {
        currentDomaine = domaine.id;
        currentDomaineName = domaine['name'];

        final wines = await _fStore
            .collection('n_wines')
            .where('domainID', isEqualTo: currentDomaine)
            .get();

        for (var wine in wines.docs) {
          sheet.getRangeByIndex(count, 1).setText(currentRegionName);
          sheet.getRangeByIndex(count, 2).setText(currentDomaineName);
          sheet.getRangeByIndex(count, 3).setText(wine['cuvee']);
          sheet.getRangeByIndex(count, 4).setText(wine['quantity']);
          sheet.getRangeByIndex(count, 5).setText(wine['format']);
          sheet.getRangeByIndex(count, 6).setText(wine['color']);
          sheet.getRangeByIndex(count, 7).setText(wine['vintage']);
          sheet.getRangeByIndex(count, 8).setText(wine['packaging']);
          sheet.getRangeByIndex(count, 9).setText(wine['prices']['caviste']);
          sheet.getRangeByIndex(count, 10).setText(wine['prices']['chr']);

          count++;

          setState(() {
            currentCount++;
          });
        }
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    AnchorElement(
        href:
            'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download', 'ExportAppVHN.xlsx')
      ..click();
  }

  Widget router(path, id) {
    Widget widget = CardListManagerView();
    switch (path) {
      case 'domains':
        widget = DomainManagerView(regionID: id);
        break;
      case 'wines':
        widget = WineManagerView(domainID: id);
        break;
    }

    return widget;
  }

  Widget getTab(index, iconON, iconOFF, text) {
    Widget tab;
    if (controller.index == index) {
      tab = Row(
        children: [
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Tab(
                text: text,
                icon: Icon(
                  iconON,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      tab = Row(
        children: [
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Tab(
                icon: Icon(
                  iconOFF,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return tab;
  }

  List<Widget> getTabList() {
    List<Widget> tabs = [];

    if (currentUserStatus == 'VHN') {
      tabs.add(
          getTab(0, Icons.view_agenda_outlined, Icons.view_agenda, 'Listes'));
      tabs.add(
          getTab(1, Icons.table_rows_outlined, Icons.table_rows, 'Tableur'));
      tabs.add(getTab(
          2, Icons.local_shipping_outlined, Icons.local_shipping, 'Transport'));
      tabs.add(getTab(
          3, Icons.people_alt_outlined, Icons.people_alt, 'Utilisateurs'));
      tabs.add(
          getTab(4, Icons.settings_outlined, Icons.settings, 'Paramètres'));
    } else {
      tabs.add(
          getTab(0, Icons.view_agenda_outlined, Icons.view_agenda, 'Listes'));
      tabs.add(getTab(
          1, Icons.local_shipping_outlined, Icons.local_shipping, 'Transport'));
    }

    return tabs;
  }

  Widget getExcelButton() {
    return currentUserStatus == 'VHN'
        ? VhnIconButton(
            size: baseSpace * 4,
            icon: Icons.description,
            onPressed: () async {
              enableLoading(setState);
              await createExcel();
              disableLoading(setState);
            })
        : SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final pathID = ModalRoute.of(context)!.settings.arguments;

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(
        value: currentCount / winesCount,
      ),
      child: DefaultTabController(
        length: currentUserStatus == 'VHN' ? 4 : 2,
        child: Scaffold(
          appBar: VhnAppBar(
            titleWidget: shouldShowSearchBar()
                ? SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: VhnInputField(
                      controller: textCurrentController,
                      text: getSearchPlaceholder(),
                      onChange: _onSearchChanged,
                    ),
                  )
                : null,
            actions: controller.index == 1 ? [getExcelButton()] : null,
            leadingWidget: Obx(() {
              final icon = UniquesControllers().data.getIconTopLeftButton();
              final text = UniquesControllers().data.getTextTopLeftButton();

              return VhnTextButton(
                icon: icon,
                padding: baseSpace,
                fontSize: baseSpace * 2,
                text: text,
                onPressed: () {
                  UniquesControllers().data.firebaseSignOut(context);
                },
              );
            }),
          ),
          backgroundColor: Colors.white,
          bottomNavigationBar: Container(
            height: baseSpace * 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  spreadRadius: baseSpace / 2,
                  blurRadius: baseSpace,
                ),
              ],
            ),
            child: TabBar(
              labelColor: Colors.black,
              controller: controller,
              indicatorWeight: baseSpace / 2,
              tabs: getTabList(),
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: controller,
            children: [
              router(widget.path, widget.id),
              if (currentUserStatus == 'VHN') StockManagerPage(),
              TransportCostCalculator(fStore: _fStore),
              if (currentUserStatus == 'VHN') UserManagerPage(),
              if (currentUserStatus == 'VHN') TransportCostsView(),
            ],
          ),
        ),
      ),
    );
  }
}
