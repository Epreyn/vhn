import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/input_fields/vhn_focus_input_field.dart';

class TransportCostStream extends StatefulWidget {
  final fStore;
  String queryParam;
  bool descending;

  TransportCostStream({Key? key, required this.fStore, required this.queryParam, required this.descending})
      : super(key: key);

  @override
  State<TransportCostStream> createState() => _TransportCostStreamState();
}

class _TransportCostStreamState extends State<TransportCostStream> {
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
            resultWidgets.add(
              DataRow(
                cells: [
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package1To36'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package1To36',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package37To72'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package37To72',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package73To120'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package73To120',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package121To150'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package121To150',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package151To200'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package151To200',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package201To250'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package201To250',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['palletFor1'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'palletFor1',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['pallet2To3'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'pallet2To3',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['pallet4To6'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'pallet4To6',
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
                DataColumn(label: Text('1 à 36 cols')),
                DataColumn(label: Text('37 à 72 cols')),
                DataColumn(label: Text('73 à 120 cols')),
                DataColumn(label: Text('121 à 150 cols')),
                DataColumn(label: Text('151 à 200 cols')),
                DataColumn(label: Text('201 à 250 cols')),
                DataColumn(label: Text('1 palette')),
                DataColumn(label: Text('2 à 3 palettes')),
                DataColumn(label: Text('4 à 6 palettes')),
              ],
              rows: resultWidgets,
            ),
          ),
        );
      },
    );
  }
}
