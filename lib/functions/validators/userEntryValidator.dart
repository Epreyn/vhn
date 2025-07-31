import '../../models/user.dart';
import '../../data/text_editing_controllers.dart';
import 'string_value_checker.dart';

User userEntryValidator(user) {
  user.telephone = stringValueChecker(userEditingControllers['telephone']!.text, user.telephone);
  user.city = stringValueChecker(userEditingControllers['city']!.text, user.city);
  user.company = stringValueChecker(userEditingControllers['company']!.text, user.company);
  user.postalCode = stringValueChecker(userEditingControllers['postalCode']!.text, user.postalCode);
  user.address = stringValueChecker(userEditingControllers['address']!.text, user.address);

  return user;
}
