import 'package:vhn/models/popup_input_field_model.dart';
import 'package:vhn/data/text_editing_controllers.dart';
import 'package:vhn/functions/get/get_label_wine_map.dart';
import 'package:vhn/functions/get/get_placeholder_wine_map.dart';

Map<String, PopupInputFieldModel> getWineInputFieldModels([wineToEdit = null]) {
  var placeHolders = getPlaceHolderWineMap(wineToEdit);
  var labels = getLabelWineMap(wineToEdit);

  wineEditingControllers['cuvee']!.clear();
  wineEditingControllers['vintage']!.clear();
  wineEditingControllers['packaging']!.clear();
  wineEditingControllers['format']!.clear();
  wineEditingControllers['priceCHR']!.clear();
  wineEditingControllers['priceCellarMan']!.clear();

  // Si les le vin existe on donne aux champs de saisie les valeurs actuelles par défaut
  if (wineToEdit != null) {
    wineEditingControllers['cuvee']!.text = wineToEdit.cuvee;
    wineEditingControllers['vintage']!.text = wineToEdit.vintage;
    wineEditingControllers['packaging']!.text = wineToEdit.packaging;
    wineEditingControllers['format']!.text = wineToEdit.format;
    wineEditingControllers['priceCHR']!.text = wineToEdit.CHRPrice;
    wineEditingControllers['priceCellarMan']!.text = wineToEdit.cavistPrice;
  }

  Map<String, PopupInputFieldModel> popupInputFieldMap = {
    'cuvee': PopupInputFieldModel(
      label: 'Cuvée',
      textEditingController: wineEditingControllers['cuvee']!,
      placeHolder: 'Cuvée',
    ),
    'vintage': PopupInputFieldModel(
      label: 'Millésime',
      textEditingController: wineEditingControllers['vintage']!,
      placeHolder: 'Millésime',
    ),
    'priceCHR': PopupInputFieldModel(
      label: 'Prix CHR',
      textEditingController: wineEditingControllers['priceCHR']!,
      placeHolder: 'Prix CHR',
    ),
    'priceCellarMan': PopupInputFieldModel(
      label: 'Prix Caviste',
      textEditingController: wineEditingControllers['priceCellarMan']!,
      placeHolder: 'Prix Caviste',
    ),
  };

  if (wineToEdit == null) {
    popupInputFieldMap.putIfAbsent(
        'quantity',
        () => PopupInputFieldModel(
              label: 'Quantité',
              textEditingController: wineEditingControllers['quantity']!,
              placeHolder: 'Quantité',
            ));
  }

  return popupInputFieldMap;
}
