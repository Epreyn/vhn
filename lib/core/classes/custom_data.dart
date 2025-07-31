import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:vhn/constants/data.dart';

import '../../screens/login_screen/login_screen.dart';

class CustomData extends GetxController {
  RxInt screenIndex = 0.obs;

  RxString currentList = 'AREAS'.obs;
  RxString currentListId = ''.obs;

  RxBool stackIsEmpty = true.obs;

  RxList<Map<String, dynamic>> stack = <Map<String, dynamic>>[].obs;

  RxString textTopLeftButton = ''.obs;
  Rx<IconData> iconTopLeftButton = Icons.logout.obs;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  RxBool isWantedInUser = false.obs;
  RxBool isWantedInList = false.obs;
  RxBool isWantedInUnFoldable = false.obs;
  RxBool isWantedInTransport = false.obs;

  RxBool isSearching = false.obs;
  RxBool userManagerFlag = true.obs;

  String getTextTopLeftButton() {
    // if (isWantedInList.value && screenIndex.value == 0 ||
    //     isWantedInUnFoldable.value && screenIndex.value == 1 ||
    //     isWantedInTransport.value && screenIndex.value == 2 ||
    //     isWantedInUser.value && screenIndex.value == 3) {
    //   textTopLeftButton.value = 'ANNULER';
    // } else {
    //   if (screenIndex.value == 0 && !stackIsEmpty.value) {
    //     textTopLeftButton.value = 'RETOUR';
    //   } else {
    //     textTopLeftButton.value = 'DÉCONNEXION';
    //   }
    // }
    // return textTopLeftButton.value;

    if (stack.isEmpty || currentList.value == 'REGIONS') {
      return 'SE DÉCONNECTER';
    } else {
      return 'RETOUR';
    }
  }

  IconData getIconTopLeftButton() {
    // if (isWantedInList.value && screenIndex.value == 0 ||
    //     isWantedInUnFoldable.value && screenIndex.value == 1 ||
    //     isWantedInTransport.value && screenIndex.value == 2 ||
    //     isWantedInUser.value && screenIndex.value == 3) {
    //   iconTopLeftButton.value = Icons.close;
    // } else {
    //   if (screenIndex.value == 0 && !stackIsEmpty.value) {
    //     iconTopLeftButton.value = Icons.arrow_back;
    //   } else {
    //     iconTopLeftButton.value = Icons.all_inclusive;
    //   }
    // }
    // return iconTopLeftButton.value;

    if (stack.isEmpty || currentList.value == 'REGIONS') {
      return Icons.logout;
    } else {
      return Icons.arrow_back;
    }
  }

  void stackPop() {
    if (stack.isNotEmpty) {
      stack.removeLast();
      if (stack.isEmpty) {
        stackIsEmpty.value = true;
        currentList.value = 'AREAS';
      } else {
        currentList.value = stack.last['path'];
        currentListId.value = stack.last['id'];
      }
    }
  }

  void firebaseSignOut(BuildContext context) {
    if (stack.isEmpty || currentList.value == 'REGIONS') {
      // Déconnexion
      FirebaseAuth.instance.signOut();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      // Retour arrière
      goBack();
    }
  }

  // Méthode pour revenir en arrière dans la navigation
  void goBack() {
    if (stack.isNotEmpty) {
      stack.removeLast();

      if (stack.isEmpty) {
        currentList.value = 'REGIONS';
        currentListId.value = '';
      } else {
        final lastItem = stack.last;
        currentList.value = lastItem['path'] ?? 'REGIONS';
        currentListId.value = lastItem['id'] ?? '';
      }

      // Mettre à jour stackIsEmpty après les modifications
      stackIsEmpty.value = stack.isEmpty;
    }
  }

  // Méthode pour ajouter à la stack
  void addToStack(String path, String id) {
    stack.add({
      'path': path,
      'id': id,
    });
    currentList.value = path;
    currentListId.value = id;
    stackIsEmpty.value = false;
  }

  // Méthode pour réinitialiser la navigation
  void resetNavigation() {
    stack.clear();
    currentList.value = 'REGIONS';
    currentListId.value = '';
    stackIsEmpty.value = true;
  }

  void clearSearchSystem() {
    textCurrentController.clear();
    textListController.clear();
    textTableController.clear();
    textUserController.clear();
    textTransportController.clear();
    isWantedInList.value = false;
    isWantedInUser.value = false;
    isWantedInUnFoldable.value = false;
    isWantedInTransport.value = false;
    isSearching.value = false;
  }

  List<Map<String, dynamic>> subOrderByVintage(
      List<DocumentSnapshot<Object?>> documents, String mainOrderType) {
    List<Map<String, dynamic>> wineList = [];

    if (mainOrderType != 'cuvee') {
      for (var document in documents) {
        Map<String, dynamic> wineData = document.data() as Map<String, dynamic>;
        wineData['id'] = document.id;
        wineList.add(wineData);
      }
    } else {
      for (var wine in documents) {
        Map<String, dynamic> wineData = wine.data() as Map<String, dynamic>;
        wineData['cuvee'] = wineData['cuvee'].toString().trim();
        wineData['id'] = wine.id;
        wineList.add(wineData);
      }
      Map<String, List<dynamic>> cuveeGroups = {};
      for (var document in wineList) {
        final cuvee = document['cuvee'].toString();
        if (!cuveeGroups.containsKey(cuvee)) {
          cuveeGroups[cuvee] = [];
        }
        cuveeGroups[cuvee]!.add(document);
      }

      List<List<dynamic>> cuveeDocumentLists = cuveeGroups.values.toList();

      wineList.clear();

      for (var list in cuveeDocumentLists) {
        list.sort((a, b) => a['vintage'].compareTo(b['vintage']));
        for (var test in list) {
          if (test['cuvee'] == 'Marèle') {}
        }

        for (var cuvee in list) {
          wineList.add(cuvee);
        }
      }
    }

    return wineList;
  }
}
