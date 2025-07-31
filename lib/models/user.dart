class User {
  String email;
  String status;
  String department;
  String telephone;
  String address;
  String postalCode;
  String city;
  String company;
  bool isValidated;

  User(
      {required this.email,
      required this.status,
      required this.department,
      required this.telephone,
      required this.address,
      required this.postalCode,
      required this.city,
      required this.company,
      required this.isValidated});
}
