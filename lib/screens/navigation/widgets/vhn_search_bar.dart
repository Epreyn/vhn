// import 'package:flutter/material.dart';
//
// import '../../../constants/data.dart';
// import '../../../widgets/input_fields/vhn_input_field.dart';
//
// class VhnSearchbar extends StatefulWidget {
//   int indexScreen;
//
//   VhnSearchbar({
//     Key? key,
//     required this.indexScreen,
//   }) : super(key: key);
//
//   @override
//   State<VhnSearchbar> createState() => _VhnSearchbarState();
// }
//
// class _VhnSearchbarState extends State<VhnSearchbar> {
//   @override
//   Widget build(BuildContext context) {
//     Widget searchBarWidget = SizedBox();
//
//     switch (widget.indexScreen) {
//       case 0:
//         searchBarWidget = VhnInputField(
//           text: 'Rechercher un vin',
//           onChange: (value) async {
//             setState(() {
//               isWantedInList = value.length > 1;
//             });
//           },
//         );
//         break;
//       case 1:
//         searchBarWidget = VhnInputField(
//           text: 'Rechercher un vin',
//           onChange: (value) async {
//             setState(() {
//               isWantedInUnFoldable = value.length > 1;
//             });
//           },
//         );
//         break;
//       case 2:
//         searchBarWidget = VhnInputField(
//           text: 'Rechercher',
//           onChange: (value) async {
//             setState(() {
//               isWanted = value.length > 1;
//               research = value.toLowerCase();
//             });
//           },
//         );
//         break;
//       case 3:
//         searchBarWidget = VhnInputField(
//           text: 'Rechercher un utilisateur',
//           onChange: (value) async {
//             setState(() {
//               isWantedInUser = value.length > 1;
//             });
//           },
//         );
//         break;
//     }
//
//     return searchBarWidget;
//   }
// }
