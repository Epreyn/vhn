import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vhn/constants/data.dart';
import 'package:vhn/core/classes/uniques_controllers.dart';
import 'package:vhn/functions/show_snack_bar.dart';
import 'package:vhn/screens/reset_password_screen/reset_password_screen.dart';
import 'package:vhn/screens/signup_screen/signup_screen.dart';
import 'package:vhn/widgets/app_bars/vhn_appbar_backtrack.dart';
import 'package:vhn/widgets/buttons/VhnTextButton.dart';
import 'package:vhn/widgets/buttons/vhn_elevated_button.dart';
import 'package:vhn/widgets/design/vhn_title.dart';

import '../../../../core/classes/spacing.dart';
import '../../widgets/buttons/vhn_icon_button.dart';
import '../../widgets/columns/vhn_column.dart';
import '../../widgets/input_fields/vhn_input_field.dart';
import '../navigation/navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscure = true;

  final _auth = FirebaseAuth.instance;
  final _fStore = FirebaseFirestore.instance;
  String? email;
  String? password;
  var emailRemember = TextEditingController();
  var passwordRemember = TextEditingController();

  void getUserPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs != null) {
        setState(() {
          emailRemember.text = prefs.getString('email')!;
          passwordRemember.text = prefs.getString('password')!;
          email = emailRemember.text;
          password = passwordRemember.text;
        });
      }
    } catch (e) {
      print(e);
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (isPasswordReset) {
        isPasswordReset = false;
        showSnackBar(context, 'Mot de passe réinitialisé');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUserPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: VhnAppBar(
          leadingWidget: VhnTextButton(
            padding: baseSpace,
            fontSize: baseSpace * 2,
            text: 's\'inscrire'.toUpperCase(),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    SignUpScreen())), //Navigator.pushNamed(context, '/register'),
          ),
        ),
        body: VhnColumn(
          width: baseWidth,
          widgets: [
            const Center(
              child: VhnTitle(title: 'Vins Hors Normes'),
            ),

            Spacing.height(baseSpace * 4),

            VhnInputField(
              width: 350,
              icon: Icons.mail_outline,
              text: 'Adresse Mail',
              controller: emailRemember,
              onChange: (value) {
                email = value;
              },
            ),
            Spacing.height(baseSpace * 2),
            VhnInputField(
              width: 350,
              icon: Icons.lock_outline,
              text: 'Mot de passe',
              controller: passwordRemember,
              isObscure: isObscure,
              onTapVisibility: () => setState(() => isObscure = !isObscure),
              onChange: (value) {
                password = value;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: VhnTextButton(
                padding: baseSpace,
                fontSize: baseSpace * 2,
                text: 'Mot de passe oublié ?',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ResetPasswordScreen(),
                )), //Navigator.pushNamed(context, '/password'),
              ),
            ),
            Spacing.height(baseSpace * 4),
            Align(
              child: VhnElevatedButton(
                text: 'se connecter',
                onPress: () async {
                  UniquesControllers().data.stack.clear();
                  UniquesControllers().data.stackIsEmpty.value = true;
                  UniquesControllers().data.screenIndex.value = 0;
                  UniquesControllers().data.currentList.value = 'AREAS';

                  try {
                    enableLoading(setState);
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email!, password: password!);
                    final prefs = await SharedPreferences.getInstance();

                    currentUser = user.user;

                    prefs.setString('email', email!);
                    prefs.setString('password', password!);

                    await _fStore
                        .collection('utilisateurs')
                        .doc(user.user!.uid)
                        .get()
                        .then((value) {
                      isValidate = value.data()!['validation'];
                      currentUserStatus = value.data()!['statut'];
                      currentUserEmail = value.data()!['email'];
                      currentUserDepartments =
                          value.data()!['département'].split(',').toList();
                    });

                    if (!isValidate) {
                      disableLoading(setState);
                      showSnackBar(
                          context, 'Votre compte est en cours de validation');
                      return;
                    }

                    disableLoading(setState);
                    //Navigator.pushNamed(context, '/navigation');
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NavigationScreen()));
                  } catch (e) {
                    disableLoading(setState);
                    showSnackBar(context, e.toString());
                  }
                },
              ),
            ),
            Spacing.height(baseSpace * 8),
            // Text(
            //   'Nous travaillons activement à régler différents problèmes sur la région Catalogne Nord. Merci de votre '
            //   'patience et de '
            //   'votre compréhension',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: Colors.redAccent,
            //     fontStyle: FontStyle.italic,
            //   ),
            // ),
            // Spacing.height(baseSpace * 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Contacter le service technique'),
                Spacing.width(baseSpace * 2),
                VhnIconButton(
                  icon: Icons.phone,
                  size: baseSpace * 3,
                  onPressed: () => launchUrlFunction(urlTechnicalServicePhone),
                ),
                Spacing.width(baseSpace * 2),
                VhnIconButton(
                  icon: Icons.email,
                  size: baseSpace * 3,
                  onPressed: () => launchUrlFunction(urlTechnicalServiceEmail),
                ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Version : 2.9.8',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            // VhnElevatedButton(
            //     text: 'ADD 98 Deploy',
            //     onPress: () async {
            //       addDeploy98(setState, _fStore);
            //     }),

            // Align(
            //   child: VhnElevatedButton(
            //     text: 'TARIFS TRANSPORT STEF',
            //     onPress: () async {
            //       importTransportStefCSV(setState, _fStore);
            //       //importTransportCSV(setState, _fStore);
            //       //addTransportB(setState, _fStore);
            //       //addArchive(setState, _fStore);
            //       //crawlerOldToNew(setState, _fStore);
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
