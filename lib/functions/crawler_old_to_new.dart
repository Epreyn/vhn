import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:vhn/constants/data.dart';

void addDeploy98(
  void Function(VoidCallback fn) setState,
  FirebaseFirestore _fStore,
) async {
  enableLoading(setState);

  try {
    // Récupère tous les documents de la collection (ex: n_domains)
    final querySnapshot = await _fStore.collection('n_domains').get();

    // Pour chaque document, on ajoute "98": false dans le champ deploy
    for (var doc in querySnapshot.docs) {
      await doc.reference.set({
        'deploy': {
          '98': false,
        },
      }, SetOptions(merge: true));
    }
  } catch (e) {
    // Gérez éventuellement les erreurs (logs, alertes, etc.)
  } finally {
    disableLoading(setState);
  }
}

void addArchive(setState, FirebaseFirestore _fStore) async {
  enableLoading(setState);

  final users = await _fStore.collection('utilisateurs').get();

  for (var user in users.docs) {
    _fStore.collection('utilisateurs').doc(user.id).set(
      {'archive': false},
      SetOptions(merge: true),
    );
  }

  disableLoading(setState);
}

void importTransportStefCSV(setState, FirebaseFirestore _fStore) async {
  enableLoading(setState);

  final fileContent = await rootBundle.loadString('transport_a_2025.csv');
  final rows = CsvToListConverter().convert(fileContent);

  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];

    final department = row[0];
    final package1To36 = row[1];
    final package37To72 = row[2];
    final package73To120 = row[3];
    final package121To150 = row[4];
    final package151To200 = row[5];
    final package201To250 = row[6];
    final palletFor1 = row[7];
    final pallet2To3 = row[8];
    final pallet4To6 = row[9];

    String departmentID = department.toString();
    if (departmentID.length == 1) {
      departmentID = '0$departmentID';
    }

    final transportCost =
        await _fStore.collection('transport_costs').where('department', isEqualTo: departmentID).get();

    if (transportCost.docs.isNotEmpty) {
      _fStore.collection('transport_costs').doc(transportCost.docs.first.id).set(
        {
          'package1To36': package1To36.toString(),
          'package37To72': package37To72.toString(),
          'package73To120': package73To120.toString(),
          'package121To150': package121To150.toString(),
          'package151To200': package151To200.toString(),
          'package201To250': package201To250.toString(),
          'palletFor1': palletFor1.toString(),
          'pallet2To3': pallet2To3.toString(),
          'pallet4To6': pallet4To6.toString(),
        },
        SetOptions(merge: true),
      );
    }
  }

  disableLoading(setState);
}

void importTransportBonnardCSV(setState, FirebaseFirestore _fStore) async {
  enableLoading(setState);

  final fileContent = await rootBundle.loadString('transport_c_2025.csv');
  final rows = CsvToListConverter().convert(fileContent);

  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];

    final department = row[0];
    final package1To6_C = row[1];
    final package7To12_C = row[2];
    final package13To24_C = row[3];
    final package25To36_C = row[4];
    final package37To48_C = row[5];
    final package49To72_C = row[6];
    final package73To96_C = row[7];
    final package97To300_C = row[8];
    final palletFor1_C = row[9];
    final palletFor2_C = row[10];
    final palletFor3_C = row[11];

    String departmentID = department.toString();
    if (departmentID.length == 1) {
      departmentID = '0$departmentID';
    }

    final transportCost =
        await _fStore.collection('transport_costs').where('department', isEqualTo: departmentID).get();

    if (transportCost.docs.isNotEmpty) {
      _fStore.collection('transport_costs').doc(transportCost.docs.first.id).set(
        {
          'package1To6_C': package1To6_C.toString(),
          'package7To12_C': package7To12_C.toString(),
          'package13To24_C': package13To24_C.toString(),
          'package25To36_C': package25To36_C.toString(),
          'package37To48_C': package37To48_C.toString(),
          'package49To72_C': package49To72_C.toString(),
          'package73To96_C': package73To96_C.toString(),
          'package97To300_C': package97To300_C.toString(),
          'palletFor1_C': palletFor1_C.toString(),
          'palletFor2_C': palletFor2_C.toString(),
          'palletFor3_C': palletFor3_C.toString(),
        },
        SetOptions(merge: true),
      );
    }
  }

  disableLoading(setState);
}

void addTransportB(setState, FirebaseFirestore _fStore) async {
  enableLoading(setState);
  final transportCosts = await _fStore.collection('transport_costs').get();

  for (var transportCost in transportCosts.docs) {
    _fStore.collection('transport_costs').doc(transportCost.id).set(
      {
        'package1To36_B': '',
        'package37To75_B': '',
        'package76To115_B': '',
        'package116To150_B': '',
        'package151To200_B': '',
        'package201To250_B': '',
        'palletFor1_B': '',
        'pallet2To3_B': '',
        'pallet4To6_B': '',
      },
      SetOptions(merge: true),
    );
  }

  disableLoading(setState);
}

void importTransportCSV(setState, FirebaseFirestore _fStore) async {
  enableLoading(setState);

  final fileContent = await rootBundle.loadString('transport_b_2024.csv');
  final rows = CsvToListConverter().convert(fileContent);

  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];

    final department = row[0];
    final package1To3_B = row[1];
    final package4To6_B = row[2];
    final package7To12_B = row[3];
    final package13To18_B = row[4];
    final package19To24_B = row[5];
    final package25To36_B = row[6];
    final package37To48_B = row[7];
    final package49To60_B = row[8];
    final package61To299_B = row[9];
    final package300To599_B = row[10];
    final package600To799_B = row[11];
    final package800To1199_B = row[12];
    final package1200_B = row[13];

    String departmentID = department.toString();
    if (departmentID.length == 1) {
      departmentID = '0$departmentID';
    }

    final transportCost =
        await _fStore.collection('transport_costs').where('department', isEqualTo: departmentID).get();

    if (transportCost.docs.isNotEmpty) {
      _fStore.collection('transport_costs').doc(transportCost.docs.first.id).set(
        {
          'package1To3_B': package1To3_B.toString(),
          'package4To6_B': package4To6_B.toString(),
          'package7To12_B': package7To12_B.toString(),
          'package13To18_B': package13To18_B.toString(),
          'package19To24_B': package19To24_B.toString(),
          'package25To36_B': package25To36_B.toString(),
          'package37To48_B': package37To48_B.toString(),
          'package49To60_B': package49To60_B.toString(),
          'package61To299_B': package61To299_B.toString(),
          'package300To599_B': package300To599_B.toString(),
          'package600To799_B': package600To799_B.toString(),
          'package800To1199_B': package800To1199_B.toString(),
          'package1200_B': package1200_B.toString(),
        },
        SetOptions(merge: true),
      );
    }
  }

  disableLoading(setState);
}

void crawlerOldToNew(setState, FirebaseFirestore _fStore) async {
  enableLoading(setState);

  final regions = await _fStore.collection('regions').orderBy('index').get();
  for (var region in regions.docs) {
    var regionID = '';

    await _fStore.collection('n_regions').add({
      'name': region['id'].toString(),
      'index': region['index'],
    }).then((value) {
      regionID = value.id;
    });

    final domains = await _fStore.collection('regions').doc(region['id']).collection('domaines').get();

    for (var domain in domains.docs) {
      var domainID = '';

      await _fStore.collection('n_domains').add({
        'regionID': regionID,
        'name': domain['id'].toString(),
        'index': domain['index'],
        'deploy': domain['déploiement'],
        'invoice': domain['facturation'],
      }).then((value) {
        domainID = value.id;
      });

      final vins = await _fStore
          .collection('regions')
          .doc(region['id'])
          .collection('domaines')
          .doc(domain['id'])
          .collection('vins')
          .get();

      for (var vin in vins.docs) {
        await _fStore.collection('n_wines').add({
          'domainID': domainID,
          'color': vin['couleur'].toString(),
          'quantity': vin['quantité'].toString(),
          'prices': vin['tarifs'],
          'vintage': vin['millésime'].toString(),
          'format': vin['format'].toString(),
          'cuvee': vin['cuvée'].toString(),
          'packaging': vin['conditionnement'].toString(),
        });
      }
    }
  }

  disableLoading(setState);
}
