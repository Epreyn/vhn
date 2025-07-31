import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vhn/widgets/app_bars/vhn_appbar_backtrack.dart';
import 'package:vhn/widgets/buttons/vhn_elevated_button.dart';
import 'package:vhn/widgets/design/vhn_title.dart';

import '../../../../core/classes/spacing.dart';
import '../../constants/data.dart';
import '../../functions/show_snack_bar.dart';
import '../../widgets/buttons/VhnTextButton.dart';
import '../../widgets/columns/vhn_column.dart';
import '../../widgets/input_fields/vhn_input_field.dart';
import '../login_screen/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _auth = FirebaseAuth.instance;

  String? email;
  var emailRemember = TextEditingController();

  void getUserPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs != null) {
        setState(() {
          emailRemember.text = prefs.getString('email')!;

          email = emailRemember.text;
        });
      }
    } catch (e) {
      print(e);
    }
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
            Center(child: const VhnTitle(title: 'Mot de Passe Oublié ?')),
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
            Spacing.height(baseSpace * 8),
            Align(
              child: VhnElevatedButton(
                text: 'réinitialiser',
                onPress: () async {
                  try {
                    enableLoading(setState);
                    await _auth.sendPasswordResetEmail(email: email!);

                    setState(() {
                      isPasswordReset = true;
                    });

                    disableLoading(setState);
                    //Navigator.pushNamed(context, '/login_screen');
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen()));
                  } catch (e) {
                    disableLoading(setState);
                    showSnackBar(context, e.toString());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
