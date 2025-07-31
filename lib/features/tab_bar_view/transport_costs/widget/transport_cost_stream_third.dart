import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/input_fields/vhn_focus_input_field.dart';

class TransportCostStreamThird extends StatefulWidget {
  final fStore;
  String queryParam;
  bool descending;

  TransportCostStreamThird({
    Key? key,
    required this.fStore,
    required this.queryParam,
    required this.descending,
  }) : super(key: key);

  @override
  State<TransportCostStreamThird> createState() => _TransportCostStreamThirdState();
}

class _TransportCostStreamThirdState extends State<TransportCostStreamThird> {
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
                      currentQuantity: transportCoast['package1To6_C'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package1To6_C',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package7To12_C'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package7To12_C',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package13To24_C'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package13To24_C',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package25To36_C'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package25To36_C',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package37To48_C'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package37To48_C',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package49To72_C'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package49To72_C',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package73To96_C'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package73To96_C',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['package97To300_C'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'package97To300_C',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['palletFor1_C'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'palletFor1_C',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['palletFor2_C'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'palletFor2_C',
                    ),
                  ),
                  DataCell(
                    VhnFocusInputField(
                      currentQuantity: transportCoast['palletFor3_C'],
                      transportCost: transportCoast,
                      fStore: widget.fStore,
                      fStoreFieldName: 'palletFor3_C',
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
                DataColumn(
                  label: Text('1 à 6 cols'),
                ),
                DataColumn(
                  label: Text('7 à 12 cols'),
                ),
                DataColumn(
                  label: Text('13 à 24 cols'),
                ),
                DataColumn(
                  label: Text('25 à 36 cols'),
                ),
                DataColumn(
                  label: Text('37 à 48 cols'),
                ),
                DataColumn(
                  label: Text('49 à 72 cols'),
                ),
                DataColumn(
                  label: Text('73 à 96 cols'),
                ),
                DataColumn(
                  label: Text('97 à 300 cols'),
                ),
                DataColumn(
                  label: Text('Pallette 1 cols'),
                ),
                DataColumn(
                  label: Text('Pallette 2 cols'),
                ),
                DataColumn(
                  label: Text('Pallette 3 cols'),
                ),
              ],
              rows: resultWidgets,
            ),
          ),
        );
      },
    );
  }
}
