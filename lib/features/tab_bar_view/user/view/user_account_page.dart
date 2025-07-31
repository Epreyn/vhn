import 'package:flutter/material.dart';
import 'package:vhn/constants/data.dart';
import 'package:vhn/widgets/buttons/vhn_icon_button.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({Key? key}) : super(key: key);

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Row(
            children: [
              const Text('Contacter Vins Hors Normes'),
              VhnIconButton(
                size: baseSpace * 3,
                icon: Icons.phone,
                onPressed: () => launchUrlFunction(urlVhnPhone),
              ),
              VhnIconButton(
                size: baseSpace * 3,
                icon: Icons.email,
                onPressed: () => launchUrlFunction(urlVhnEmail),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Contacter notre service technique'),
              VhnIconButton(
                size: baseSpace * 3,
                icon: Icons.phone,
                onPressed: () => launchUrlFunction(urlTechnicalServicePhone),
              ),
              VhnIconButton(
                size: baseSpace * 3,
                icon: Icons.email,
                onPressed: () => launchUrlFunction(urlTechnicalServiceEmail),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
