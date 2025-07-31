import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants/data.dart';

class VhnFocusInputField extends StatefulWidget {
  final fStore;
  final transportCost;
  String fStoreFieldName;
  String currentQuantity;

  VhnFocusInputField(
      {Key? key,
      required this.fStore,
      required this.fStoreFieldName,
      required this.transportCost,
      required this.currentQuantity})
      : super(key: key);

  @override
  State<VhnFocusInputField> createState() => _VhnFocusInputFieldState();
}

class _VhnFocusInputFieldState extends State<VhnFocusInputField> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.currentQuantity;
  }

  @override
  Widget build(BuildContext context) {
    controller.text = widget.currentQuantity;

    return SizedBox(
      width: 100,
      child: Focus(
        child: TextFormField(
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
          onChanged: (value) async {},
          controller: controller,
        ),
        onFocusChange: (isFocus) async {
          if (!isFocus) {
            if (controller.text != widget.currentQuantity) {
              enableLoading(setState);
              await widget.fStore.collection('transport_costs').doc(widget.transportCost.id).set({
                widget.fStoreFieldName: controller.text,
              }, SetOptions(merge: true));
              disableLoading(setState);
            }
          } else {
            widget.currentQuantity = controller.text;
          }
        },
      ),
    );
  }
}
