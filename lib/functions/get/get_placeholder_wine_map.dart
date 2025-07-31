Map<String, String> getPlaceHolderWineMap([wineToEdit = null]) {
  // Variables pour le placeHolder des champs de saisie de text
  String cuveePlaceHolder = wineToEdit != null ? wineToEdit.cuvee : 'Cuvée';
  String vintagePlaceHolder = wineToEdit != null ? wineToEdit.vintage : 'Millésime';
  String packagingPlaceHolder = wineToEdit != null ? wineToEdit.packaging : 'Conditionnement';
  String formatPlaceHolder = wineToEdit != null ? wineToEdit.format : 'Format';
  String CHRPricePlaceHolder = wineToEdit != null ? wineToEdit.CHRPrice : 'Prix CHR';
  String cellarManPricePlaceHolder = wineToEdit != null ? wineToEdit.cavistPrice : 'Prix Caviste';
  String quantityPlaceHolder = wineToEdit != null ? wineToEdit.cavistPrice : 'Quantité';

  Map<String, String> placeHolderWineMap = {
    'cuvee': cuveePlaceHolder,
    'vintage': vintagePlaceHolder,
    'packaging': packagingPlaceHolder,
    'format': formatPlaceHolder,
    'priceCHR': CHRPricePlaceHolder,
    'priceCellarMan': cellarManPricePlaceHolder,
    'quantity': quantityPlaceHolder,
  };

  return placeHolderWineMap;
}
