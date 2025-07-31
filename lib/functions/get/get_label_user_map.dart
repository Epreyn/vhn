import 'package:flutter/material.dart';
import 'package:vhn/widgets/hybrid_widgets/text_sizedbox.dart';


Map<String, TextSizedBox> getLabelUserMap () {

  // Si l'élément à éditer existe, alors on defini les label au dessus de chaque champs de saisie
  TextSizedBox companyLabel = TextSizedBox(widget: Text('Entreprise', style: TextStyle(fontWeight: FontWeight.bold),),);
  TextSizedBox departmentLabel =  TextSizedBox(widget: Text('Département', style: TextStyle(fontWeight: FontWeight.bold),),);
  TextSizedBox telephoneLabel =  TextSizedBox(widget: Text('Téléphone', style: TextStyle(fontWeight: FontWeight.bold),),);
  TextSizedBox addressLabel =  TextSizedBox(widget: Text('Adresse', style: TextStyle(fontWeight: FontWeight.bold),),);
  TextSizedBox postalCodeLabel =  TextSizedBox(widget: Text('Code Postal', style: TextStyle(fontWeight: FontWeight.bold),),);
  TextSizedBox cityLabel = TextSizedBox(widget: Text('Ville', style: TextStyle(fontWeight: FontWeight.bold),),);
  TextSizedBox statusLabel = TextSizedBox(widget: Text('Statut', style: TextStyle(fontWeight: FontWeight.bold),),);



  Map<String, TextSizedBox> labelUserMap = {
    'company': companyLabel,
    'department': departmentLabel,
    'telephone': telephoneLabel,
    'address': addressLabel,
    'postalCode': postalCodeLabel,
    'city': cityLabel,
    'status': statusLabel,

  };


  return labelUserMap;

}
