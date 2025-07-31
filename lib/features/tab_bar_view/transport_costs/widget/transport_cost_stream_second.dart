import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/input_fields/vhn_focus_input_field.dart';

class TransportCostStreamSecond extends StatefulWidget {
  final fStore;
  String queryParam;
  bool descending;

  TransportCostStreamSecond({Key? key, required this.fStore, required this.queryParam, required this.descending})
      : super(key: key);

  @override
  State<TransportCostStreamSecond> createState() => _TransportCostStreamState();
}

class _TransportCostStreamState extends State<TransportCostStreamSecond> {
  String orderType = 'department';
  late List<DocumentSnapshot> documents;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.fStore.collection('transport_costs').where('department', isEqualTo: widget.queryParam).snapshots(),
      builder: (context, snapshot) {
        List<DataRow> resultWidgets = [];
        final _horizontalScrollController = ScrollController();

        if (snapshot.hasData) {
          documents = snapshot.data!.docs;

          for (var transportCoast in documents) {
            final data = transportCoast.data() as Map<String, dynamic>;

            resultWidgets.add(
              DataRow(
                cells: [
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package1To3_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package1To3_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package4To6_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package4To6_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package7To12_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package7To12_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package13To18_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package13To18_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package19To24_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package19To24_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package25To36_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package25To36_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package37To48_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package37To48_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package49To60_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package49To60_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package61To299_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package61To299_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package300To599_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package300To599_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package600To799_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package600To799_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package800To1199_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package800To1199_B',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package1200_B'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package1200_B',
                    ),
                  ),
                ],
              ),
            );
          }
        }

        return Scrollbar(
          thumbVisibility: true,
          controller: _horizontalScrollController,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 64,
              dividerThickness: 0.0,
              columns: [
                DataColumn(label: Text('1 à 3 cols')),
                DataColumn(label: Text('4 à 6 cols')),
                DataColumn(label: Text('7 à 12 cols')),
                DataColumn(label: Text('13 à 18 cols')),
                DataColumn(label: Text('19 à 24 cols')),
                DataColumn(label: Text('25 à 36 cols')),
                DataColumn(label: Text('37 à 48 cols')),
                DataColumn(label: Text('49 à 60 cols')),
                DataColumn(label: Text('61 à 299 cols')),
                DataColumn(label: Text('300 à 599 cols')),
                DataColumn(label: Text('600 à 799 cols')),
                DataColumn(label: Text('800 à 1199 cols')),
                DataColumn(label: Text('+ 1200 cols')),
              ],
              rows: resultWidgets,
            ),
          ),
        );
      },
    );
  }
}
