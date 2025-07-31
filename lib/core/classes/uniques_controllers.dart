import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import 'custom_data.dart';



class UniquesControllers extends GetxController {
  static final UniquesControllers _instance = UniquesControllers._();
  factory UniquesControllers() => _instance;
  UniquesControllers._();

  CustomData data = Get.put(CustomData());

}
