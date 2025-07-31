import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/dropdownbutton_model.dart';
import '../../functions/add/add_dropdown_item_popup.dart';

class DropDownButtonMaker extends StatefulWidget {
  final DropDownButtonModel model;
  final String? buttonOption;
  final bool realTimeMode;
  double width;

  DropDownButtonMaker({
    Key? key,
    required this.model,
    this.buttonOption,
    this.realTimeMode = false,
    required this.width,
  }) : super(key: key);

  @override
  _DropDownButtonMakerState createState() => _DropDownButtonMakerState();
}

class _DropDownButtonMakerState extends State<DropDownButtonMaker> {
  late Stream<QuerySnapshot> _dataStream;
  List<DropdownMenuItem<String>> _dropdownItems = [];

  @override
  void initState() {
    super.initState();

    if (widget.realTimeMode) {
      String collectionName = '';
      switch (widget.model.hint) {
        case 'Couleur':
          collectionName = 'couleurs';
          break;
        case 'Format':
          collectionName = 'formats';
          break;
        case 'Conditionnement':
          collectionName = 'conditionnements';
          break;
      }

      CollectionReference collectionReference = FirebaseFirestore.instance.collection('$collectionName');
      _dataStream = collectionReference.snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return !widget.realTimeMode
        ? Row(
            children: [
              SizedBox(
                width: widget.width,
                child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(),
                      labelText: widget.model.initialValue == null ? '' : widget.model.hint,
                      prefixIcon: widget.model.icon,
                    ),
                    isExpanded: true,
                    hint: Text(widget.model.hint!),
                    value: widget.model.initialValue,
                    items: widget.model.items.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: widget.model.onChanged),
              ),
            ],
          )
        : StreamBuilder<QuerySnapshot>(
            stream: _dataStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              List<String> _items = [];
              if (snapshot.hasData) {
                snapshot.data?.docs.forEach((doc) {
                  _items.add(doc['name']);
                });

                _dropdownItems = _items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList();

                return Row(
                  children: [
                    SizedBox(
                      width: widget.width,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                          labelText: widget.model.initialValue == null ? '' : widget.model.hint,
                          prefixIcon: widget.model.icon,
                        ),
                        isExpanded: true,
                        hint: Text(widget.model.hint!),
                        value: widget.model.initialValue,
                        items: _dropdownItems,
                        onChanged: widget.model.onChanged,
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                );
              }
            },
          );
  }
}

//Icon(icon, color: Colors.black54)
