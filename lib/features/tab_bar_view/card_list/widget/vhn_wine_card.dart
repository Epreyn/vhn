import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../constants/data.dart';
import '../../../../core/classes/spacing.dart';
import '../../../../functions/delete_item_popup.dart';
import '../../../../functions/edit/edit_wine_popup.dart';
import '../../../../functions/show_snack_bar.dart';
import '../../../../widgets/buttons/vhn_icon_button.dart';
import '../../../../widgets/rows/card_row.dart';

class VhnWineCard extends StatefulWidget {
  final dynamic wineSnap;

  VhnWineCard({Key? key, required this.wineSnap}) : super(key: key);

  @override
  State<VhnWineCard> createState() => _VhnWineCardState();
}

class _VhnWineCardState extends State<VhnWineCard> {
  final FirebaseFirestore _fStore = FirebaseFirestore.instance;
  final TextEditingController quantityController = TextEditingController();
  late String currentQuantity;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;
  bool _isUpdating =
      false; // Nouveau flag pour éviter les mises à jour multiples

  @override
  void initState() {
    super.initState();
    quantityController.text = widget.wineSnap['quantity'];
    currentQuantity = widget.wineSnap['quantity'];

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing && !_isUpdating) {
      // Délai pour iOS Safari
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _validateAndUpdate();
        }
      });
    } else if (_focusNode.hasFocus) {
      setState(() {
        _isEditing = true;
      });
    }
  }

  Future<void> _validateAndUpdate() async {
    if (_isUpdating) return; // Éviter les mises à jour multiples

    setState(() {
      _isUpdating = true;
      _isEditing = false;
    });

    final newValue = quantityController.text.trim();

    if (newValue.isEmpty) {
      setState(() {
        quantityController.text = currentQuantity;
        _isUpdating = false;
      });
      return;
    }

    if (newValue != currentQuantity) {
      try {
        // Mettre à jour Firestore
        await _fStore.collection('n_wines').doc(widget.wineSnap['id']).set({
          'quantity': newValue,
        }, SetOptions(merge: true));

        // Mise à jour réussie
        setState(() {
          currentQuantity = newValue;
        });

        if (newValue.startsWith('-')) {
          sendMail(
              setState,
              context,
              'ponsalexandre@vinshorsnormes.com',
              'Alerte VHN App : Réapprovisionnement',
              'Besoin de réapprovisionnement pour le vin ${widget.wineSnap['cuvee']} ${widget.wineSnap['color']} ${widget.wineSnap['vintage']} ${widget.wineSnap['format']}.');
        }
      } catch (e) {
        // En cas d'erreur, restaurer l'ancienne valeur
        setState(() {
          quantityController.text = currentQuantity;
        });
        showSnackBar(context, e.toString());
      }
    }

    setState(() {
      _isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si c'est une Map (depuis la recherche), utiliser directement
    if (widget.wineSnap is Map<String, dynamic>) {
      return _buildCardFromData(widget.wineSnap);
    }

    // Sinon, c'est un DocumentSnapshot, utiliser StreamBuilder
    return StreamBuilder<DocumentSnapshot>(
      stream: _fStore.collection('n_wines').doc(widget.wineSnap.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var wineSnap = snapshot.data!;
        final data = wineSnap.data() as Map<String, dynamic>;
        data['id'] = wineSnap.id;

        // Mettre à jour le controller seulement si pas en édition
        if (!_isEditing && !_isUpdating) {
          quantityController.text = data['quantity'] ?? '0';
          currentQuantity = data['quantity'] ?? '0';
        }

        return _buildCardFromData(data);
      },
    );
  }

  Widget _buildCardFromData(Map<String, dynamic> wineData) {
    Widget getPrices() {
      Widget? priceWidget;
      if (currentUserStatus == 'VHN' ||
          currentUserStatus == 'Agent' ||
          currentUserStatus == 'Vigneron') {
        priceWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardRow(
              label: 'Tarif Caviste : ',
              text: wineData['prices']?['caviste'] ?? '',
              sigle: '€',
            ),
            CardRow(
              label: 'Tarif CHR : ',
              text: wineData['prices']?['chr'] ?? '',
              sigle: '€',
            ),
          ],
        );
      }
      if (currentUserStatus == 'Caviste') {
        priceWidget = CardRow(
          label: 'Tarif : ',
          text: wineData['prices']?['caviste'] ?? '',
          sigle: '€',
        );
      }
      if (currentUserStatus == 'CHR') {
        priceWidget = CardRow(
          label: 'Tarif : ',
          text: wineData['prices']?['chr'] ?? '',
          sigle: '€',
        );
      }
      if (currentUserStatus == 'Ambassade') {
        var finalPrice = 0.0;
        final chrPrice = wineData['prices']?['chr'] ?? '0';
        final chrValue = double.tryParse(chrPrice.toString()) ?? 0.0;

        switch (wineData['format']) {
          case 'Magnum':
            finalPrice = chrValue + 4;
            break;
          case 'Jéroboam':
            finalPrice = chrValue + 8;
            break;
          default:
            finalPrice = chrValue + 2;
            break;
        }

        priceWidget = CardRow(
          label: 'Tarif : ',
          text: finalPrice.toString(),
          sigle: '€',
        );
      }
      return priceWidget ?? SizedBox();
    }

    Widget getQuantity() {
      Widget quantityWidget = SizedBox();

      if (currentUserStatus != 'VHN') {
        final qty = int.tryParse(wineData['quantity'] ?? '0') ?? 0;
        if (qty < 0) {
          quantityWidget = Text('Réapprovisionnement en cours');
        } else {
          quantityWidget =
              CardRow(label: 'Quantité : ', text: wineData['quantity'] ?? '0');
        }
      }

      return quantityWidget;
    }

    Widget getTextWidgets() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              wineData['cuvee'] ?? '',
              style: TextStyle(
                fontSize: baseSpace * 3,
              ),
            ),
          ),
          Spacing.height(baseSpace * 1.5),
          getQuantity(),
          Spacing.height(baseSpace * 1.5),
          getPrices(),
          Spacing.height(baseSpace * 1.5),
          CardRow(
            label: 'Format : ',
            text: wineData['format'] ?? '',
          ),
          CardRow(label: 'Couleur : ', text: wineData['color'] ?? ''),
          CardRow(label: 'Millésime : ', text: wineData['vintage'] ?? ''),
          CardRow(
              label: 'Conditionnement : ', text: wineData['packaging'] ?? ''),
        ],
      );
    }

    Widget getButtonWidgets() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (currentUserStatus == 'VHN')
            Text(
              "Quantité",
              style: TextStyle(
                fontSize: baseSpace * 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (currentUserStatus == 'VHN') Spacing.height(baseSpace),
          if (currentUserStatus == 'VHN')
            SizedBox(
              width: 80,
              child: TextFormField(
                focusNode: _focusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  // Ajout d'un bouton de validation pour iOS
                  // suffixIcon: _isEditing
                  //     ? IconButton(
                  //         icon:
                  //             Icon(Icons.check, size: 16, color: Colors.green),
                  //         onPressed: () {
                  //           _focusNode.unfocus();
                  //           _validateAndUpdate();
                  //         },
                  //         padding: EdgeInsets.zero,
                  //         constraints: BoxConstraints(maxWidth: 30),
                  //       )
                  //     : null,
                ),
                controller: quantityController,
                keyboardType: TextInputType.numberWithOptions(
                  signed: true,
                  decimal: false,
                ),
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                // Forcer le clavier numérique sur iOS
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                ],
                onTap: () {
                  // Sélectionner tout le texte sur iOS
                  if (quantityController.text == "0") {
                    quantityController.clear();
                  } else {
                    quantityController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: quantityController.text.length,
                    );
                  }
                },
                onChanged: (value) {
                  if (!_isEditing) {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
                onFieldSubmitted: (value) {
                  _validateAndUpdate();
                },
                // Gestion spécifique pour iOS
                onEditingComplete: () {
                  // Ne pas unfocus automatiquement sur iOS
                  if (Theme.of(context).platform != TargetPlatform.iOS) {
                    _validateAndUpdate();
                  }
                },
              ),
            ),
          if (currentUserStatus == 'VHN') Spacing.height(baseSpace * 2),
          if (currentUserStatus == 'VHN')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VhnIconButton(
                  size: baseSpace * 4,
                  icon: Icons.edit,
                  color: Colors.blue,
                  onPressed: () {
                    editWinePopup(
                      context,
                      setState,
                      {
                        'id': wineData['id'],
                        'cuvee': wineData['cuvee'],
                        'vintage': wineData['vintage'],
                        'color': wineData['color'],
                        'packaging': wineData['packaging'],
                        'format': wineData['format'],
                        'quantity': wineData['quantity'],
                        'chr': wineData['prices']?['chr'] ?? '',
                        'caviste': wineData['prices']?['caviste'] ?? '',
                      },
                      wineData['domainID'],
                    );
                  },
                ),
                VhnIconButton(
                  size: baseSpace * 4,
                  icon: Icons.delete,
                  color: Colors.red,
                  onPressed: () {
                    deleteItemPopup(context, setState, 'WINE',
                        {'id': wineData['id'], 'cuvee': wineData['cuvee']});
                  },
                ),
              ],
            )
        ],
      );
    }

    return Card(
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.all(baseSpace * 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 75,
              child: getTextWidgets(),
            ),
            Expanded(
              flex: 25,
              child: getButtonWidgets(),
            ),
          ],
        ),
      ),
    );
  }
}
