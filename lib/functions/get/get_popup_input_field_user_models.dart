import 'package:vhn/models/popup_input_field_model.dart';
import 'package:vhn/data/text_editing_controllers.dart';

import 'get_label_user_map.dart';

Map<String, PopupInputFieldModel> getUserPopupInputFieldModels() {
  var labels = getLabelUserMap();

  Map<String, PopupInputFieldModel> popupInputFieldMap = {
    'company': PopupInputFieldModel(
      label: 'Entreprise',
      textEditingController: userEditingControllers['company']!,
      placeHolder: 'Entreprise',
    ),
    'department': PopupInputFieldModel(
      label: 'Département',
      textEditingController: userEditingControllers['department']!,
      placeHolder: 'Département',
    ),
    'telephone': PopupInputFieldModel(
      label: 'Téléphone',
      textEditingController: userEditingControllers['telephone']!,
      placeHolder: 'Téléphone',
    ),
    'address': PopupInputFieldModel(
      label: 'Adresse',
      textEditingController: userEditingControllers['address']!,
      placeHolder: 'Adresse',
    ),
    'postalCode': PopupInputFieldModel(
      label: 'Code postal',
      textEditingController: userEditingControllers['postalCode']!,
      placeHolder: 'Code postal',
    ),
    'city': PopupInputFieldModel(
      label: 'Ville',
      textEditingController: userEditingControllers['city']!,
      placeHolder: 'Ville',
    ),
  };

  return popupInputFieldMap;
}
