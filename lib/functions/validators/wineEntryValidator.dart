import '../../models/wine.dart';
import '../../data/text_editing_controllers.dart';
import 'string_value_checker.dart';

Wine wineEntryValidator(wine, color, format, packaging) {
  wine.cuvee = stringValueChecker(wineEditingControllers['cuvee']!.text, wine.cuvee);
  wine.vintage = stringValueChecker(wineEditingControllers['vintage']!.text, wine.vintage);
  wine.format = stringValueChecker(format, wine.format);
  wine.packaging = stringValueChecker(packaging, wine.packaging);
  wine.CHRPrice = stringValueChecker(wineEditingControllers['priceCHR']!.text, wine.CHRPrice);
  wine.cavistPrice = stringValueChecker(wineEditingControllers['priceCellarMan']!.text, wine.cavistPrice);
  wine.color = stringValueChecker(color, wine.color);

  return wine;
}
