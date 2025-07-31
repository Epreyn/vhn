import 'package:flutter/material.dart';
import 'package:vhn/widgets/hybrid_widgets/text_sizedbox.dart';

Map<String, TextSizedBox> getLabelWineMap([wineToEdit = null]) {
  // Si l'élément à éditer existe, alors on defini les label au dessus de chaque champs de saisie
  TextSizedBox cuveeLabel = wineToEdit != null
      ? TextSizedBox(
          widget: Text(
          'Cuvée',
          style: TextStyle(fontWeight: FontWeight.bold),
        ))
      : TextSizedBox(
          widget: null,
        );

  TextSizedBox vintageLabel = wineToEdit != null
      ? TextSizedBox(
          widget: Text(
          'Millésime',
          style: TextStyle(fontWeight: FontWeight.bold),
        ))
      : TextSizedBox(
          widget: null,
        );

  TextSizedBox packagingLabel = wineToEdit != null
      ? TextSizedBox(
          widget: Text(
          'Conditionnement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ))
      : TextSizedBox(
          widget: null,
        );

  TextSizedBox formatLabel = wineToEdit != null
      ? TextSizedBox(
          widget: Text(
          'Format',
          style: TextStyle(fontWeight: FontWeight.bold),
        ))
      : TextSizedBox(
          widget: null,
        );

  TextSizedBox CHRPriceLabel = wineToEdit != null
      ? TextSizedBox(
          widget: Text(
          'Prix CHR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ))
      : TextSizedBox(
          widget: null,
        );

  TextSizedBox cavistPriceLabel = wineToEdit != null
      ? TextSizedBox(
          widget: Text(
          'Prix Caviste',
          style: TextStyle(fontWeight: FontWeight.bold),
        ))
      : TextSizedBox(
          widget: null,
        );

  TextSizedBox quantityLabel = TextSizedBox(
    widget: null,
  );

  Map<String, TextSizedBox> labelWineMap = {
    'cuvee': cuveeLabel,
    'vintage': vintageLabel,
    'packaging': packagingLabel,
    'format': formatLabel,
    'priceCHR': CHRPriceLabel,
    'priceCellarMan': cavistPriceLabel,
    'quantity': quantityLabel,
  };

  return labelWineMap;
}
