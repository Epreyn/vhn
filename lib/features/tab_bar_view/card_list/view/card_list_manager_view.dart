import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vhn/core/classes/uniques_controllers.dart';
import 'package:vhn/features/tab_bar_view/card_list/widget/area_list.dart';
import 'package:vhn/features/tab_bar_view/card_list/widget/domain_list.dart';
import 'package:vhn/features/tab_bar_view/card_list/widget/wine_list.dart';

class CardListManagerView extends StatelessWidget {
  const CardListManagerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final currentList = UniquesControllers().data.currentList.value;
          final currentId = UniquesControllers().data.currentListId.value;

          Widget content;

          switch (currentList) {
            case 'REGIONS':
              content = AreaList();
              break;
            case 'DOMAINS':
              content = DomainList(regionID: currentId);
              break;
            case 'WINES':
              content = WineList(domainID: currentId);
              break;
            default:
              content = AreaList();
          }

          // Utiliser LayoutBuilder pour gérer les contraintes proprement
          return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: content,
              );
            },
          );
        }),
      ),
    );
  }
}
