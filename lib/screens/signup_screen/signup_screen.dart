import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vhn/constants/data.dart';
import 'package:vhn/models/dropdownbutton_model.dart';
import 'package:vhn/widgets/app_bars/vhn_appbar_backtrack.dart';
import 'package:vhn/widgets/buttons/dropdown_button_maker.dart';
import 'package:vhn/widgets/design/vhn_title.dart';

import '../../../../core/classes/spacing.dart';
import '../../functions/show_snack_bar.dart';
import '../../widgets/buttons/VhnTextButton.dart';
import '../../widgets/buttons/vhn_elevated_button.dart';
import '../../widgets/columns/vhn_column.dart';
import '../../widgets/input_fields/vhn_input_field.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _fStore = FirebaseFirestore.instance;

  String? initialValue;
  List<String> items = [
    'Ambassade',
    'Agent',
    'CHR',
    'Caviste',
    'Vigneron',
  ];

  bool isObscure = true;

  String _status = '',
      _department = '',
      _email = '',
      _password = '',
      _business = '',
      _address = '',
      _zipCode = '',
      _city = '',
      _phone = '';

  List<String> getDepartments() {
    List<String> departments = [];
    kDeploy.forEach((key, value) {
      departments.add(key);
    });
    return departments;
  }

  @override
  Widget build(BuildContext context) {
    List<String> departments = getDepartments();

    departments.insert(0, 'Numéro de Département');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: VhnAppBar(
        leadingWidget: VhnTextButton(
          icon: Icons.arrow_back,
          padding: baseSpace,
          fontSize: baseSpace * 2,
          text: 'retour'.toUpperCase(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: VhnColumn(
        width: baseWidth,
        widgets: [
          const VhnTitle(title: 'Créer un compte'),
          Spacing.height(32),
          DropDownButtonMaker(
            model: DropDownButtonModel(
              icon: const Icon(Icons.person_outlined),
              hint: 'Je suis un',
              initialValue: initialValue,
              items: items,
              onChanged: (String? value) {
                setState(() {
                  initialValue = value!;
                  _status = value;
                });
              },
            ),
            width: 200,
          ),
          Spacing.height(baseSpace * 2),
          // VhnInputField(
          //   icon: Icons.map_outlined,
          //   text: 'Numéro de Département',
          //   onChange: (value) {
          //     setState(() {
          //       _department = value;
          //     });
          //   },
          // ),
          DropDownButtonMaker(
            model: DropDownButtonModel(
              icon: Icon(Icons.map_outlined),
              hint: '',
              items: departments,
              initialValue: departments.first,
              onChanged: (String? value) {
                if (value == departments.first) {
                  _department = '';
                } else {
                  _department = value!;
                }
              },
            ),
            width: 200,
          ),
          Spacing.height(baseSpace * 2),
          VhnInputField(
            icon: Icons.mail_outline,
            text: 'Adresse Mail',
            onChange: (value) {
              setState(() {
                _email = value;
              });
            },
          ),
          Spacing.height(baseSpace * 2),
          VhnInputField(
            icon: Icons.lock_outline,
            text: 'Mot de Passe',
            isObscure: isObscure,
            onTapVisibility: () => setState(() => isObscure = !isObscure),
            onChange: (value) {
              setState(() {
                _password = value;
              });
            },
          ),
          Spacing.height(baseSpace * 2),
          VhnInputField(
            icon: Icons.phone_outlined,
            text: 'Numéro de Téléphone',
            onChange: (value) {
              setState(() {
                _phone = value;
              });
            },
          ),
          Spacing.height(baseSpace * 2),
          VhnInputField(
            icon: Icons.business_outlined,
            text: 'Nom de l\'Entreprise',
            onChange: (value) {
              setState(() {
                _business = value;
              });
            },
          ),
          Spacing.height(baseSpace * 2),
          VhnInputField(
            icon: Icons.push_pin_outlined,
            text: 'Adresse Postale',
            onChange: (value) {
              setState(() {
                _address = value;
              });
            },
          ),
          Spacing.height(baseSpace * 2),
          VhnInputField(
            icon: Icons.pin_outlined,
            text: 'Code Postal',
            onChange: (value) {
              setState(() {
                _zipCode = value;
              });
            },
          ),
          Spacing.height(baseSpace * 2),
          VhnInputField(
            icon: Icons.location_city_outlined,
            text: 'Ville',
            onChange: (value) {
              setState(() {
                _city = value;
              });
            },
          ),
          Spacing.height(baseSpace * 4),
          Align(
            child: VhnElevatedButton(
              text: 'inscription',
              onPress: () async {
                if (_status != '' &&
                    _department != '' &&
                    _email != '' &&
                    _password != '' &&
                    _phone != '' &&
                    _business != '' &&
                    _address != '' &&
                    _zipCode != '' &&
                    _city != '') {
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                      email: _email,
                      password: _password,
                    );

                    _fStore
                        .collection('utilisateurs')
                        .doc(newUser.user!.uid)
                        .set({
                      'statut': _status.toString(),
                      'email': _email.toString(),
                      'département': _department.toString(),
                      'entreprise': _business.toString(),
                      'adresse': _address.toString(),
                      'code postal': _zipCode.toString(),
                      'ville': _city.toString(),
                      'téléphone': _phone.toString(),
                      'validation': false,
                      'archive': false,
                    });

                    showSnackBar(context,
                        'Votre inscription a été prise en compte elle est en cours de validation');
                    Navigator.pop(context);
                    // final prefs = await SharedPreferences.getInstance();
                    // prefs.setString('email', _email);
                    //  prefs.setString('password', _password);
                  } catch (e) {
                    showSnackBar(context, e.toString());
                  }
                } else {
                  showSnackBar(context, 'Veuillez remplir tous les champs');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
