import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as universal;
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_sms/flutter_sms.dart';
import 'package:vhn/core/classes/uniques_controllers.dart';

import '../../../../constants/data.dart';
import '../../../../core/classes/spacing.dart';
import '../../../../functions/delete_item_popup.dart';
import '../../../../functions/edit/edit_zone_data.dart';
import '../../unfoldable_data_table/widget/vhn_area_panel.dart'
    hide PopupMenuSMS, PopupMenuItems;

class VhnDomainCard extends StatefulWidget {
  DocumentSnapshot domainSnap;

  VhnDomainCard({Key? key, required this.domainSnap}) : super(key: key);

  @override
  State<VhnDomainCard> createState() => _VhnDomainCardState();
}

class _VhnDomainCardState extends State<VhnDomainCard> {
  final _fStore = FirebaseFirestore.instance;

  String email = '';

  String getDeploy(dynamic deploy) {
    var count = 0;
    for (var entry in deploy.entries) {
      if (entry.value == true) {
        count++;
      }
    }

    return count.toString();
  }

  void sendSms(String message) {
    String encodedMessage = Uri.encodeComponent(message);

    String encodedMessageIOS = Uri.encodeFull(message);

    String userAgent = universal.window.navigator.userAgent.toLowerCase();
    if (userAgent.contains('android')) {
      var smsLinkAndroid = html.AnchorElement(href: 'sms:?body=$encodedMessage')
        ..target = '_blank'
        ..click();
    } else if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
      Uri smsUri = Uri(
        scheme: 'sms',
        path: '',
        query: 'body=$encodedMessageIOS',
      );
      launchUrl(smsUri);
    } else {
      throw 'Platform not supported';
    }
  }

  void getTarifs(String target, bool isSms) {
    if (isSms) {
      try {
        enableLoading(setState);

        String message = "${widget.domainSnap['name']}\n\n";

        _fStore
            .collection("n_wines")
            .where('domainID', isEqualTo: widget.domainSnap.id)
            .get()
            .then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            final data = result.data() as Map<String, dynamic>;

            // Infos principales
            message +=
                "${data['cuvee']} ${data['vintage']} ${data['color']} ${data['format']}\n";

            message +=
                "Quantité : ${data['quantity']} | Conditionnement : ${data['packaging']}\n";

            // Gestion du prix
            if (target == 'ambassade') {
              double chrVal = parseToDouble(data['prices']['chr']);
              double finalPrice;
              switch (data['format']) {
                case 'Magnum':
                  finalPrice = chrVal + 4.0;
                  break;
                case 'Jéroboam':
                  finalPrice = chrVal + 8.0;
                  break;
                default:
                  finalPrice = chrVal + 2.0;
                  break;
              }
              message += "Tarif : ${finalPrice.toStringAsFixed(2)}\n\n";
            } else {
              // On récupère data['prices'][target], qui peut être un num ou un String
              final anyPrice = data['prices'][target];
              double numericPrice = parseToDouble(anyPrice);
              message += "Tarif : ${numericPrice.toStringAsFixed(2)}\n\n";
            }
          }

          sendSms(message);
          disableLoading(setState);
        });
      } catch (error) {
        disableLoading(setState);
      }
    } else {
      // Partie e-mail
      setState(() {
        email = '';
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Envoyer le tarif par email'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Email du destinataire'),
            onChanged: (value) {
              setState(() {
                email = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                if (email.isNotEmpty) {
                  try {
                    enableLoading(setState);

                    String message = "${widget.domainSnap['name']}\n\n";

                    _fStore
                        .collection("n_wines")
                        .where('domainID', isEqualTo: widget.domainSnap.id)
                        .get()
                        .then((querySnapshot) {
                      for (var result in querySnapshot.docs) {
                        final data = result.data() as Map<String, dynamic>;

                        message +=
                            "${data['cuvee']} ${data['vintage']} ${data['color']} ${data['format']}\n";
                        message +=
                            "Quantité : ${data['quantity']} | Conditionnement : ${data['packaging']}\n";

                        if (target == 'ambassade') {
                          double chrVal = parseToDouble(data['prices']['chr']);
                          double finalPrice;
                          switch (data['format']) {
                            case 'Magnum':
                              finalPrice = chrVal + 4.0;
                              break;
                            case 'Jéroboam':
                              finalPrice = chrVal + 8.0;
                              break;
                            default:
                              finalPrice = chrVal + 2.0;
                              break;
                          }
                          message +=
                              "Tarif : ${finalPrice.toStringAsFixed(2)}\n\n";
                        } else {
                          final anyPrice = data['prices'][target];
                          double numericPrice = parseToDouble(anyPrice);
                          message +=
                              "Tarif : ${numericPrice.toStringAsFixed(2)}\n\n";
                        }
                      }

                      sendMail(setState, context, email, 'Tarif VHN', message);
                      disableLoading(setState);
                    });
                  } catch (error) {
                    disableLoading(setState);
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text('Envoyer'),
            ),
          ],
        ),
      );
    }
  }

  /// Convertit la valeur (String / int / double) en double.
  /// Si échec, renvoie 0.0 (ou vous gérez autrement).
  double parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // setState(() {
        //   UniquesControllers().data.currentListId.value = widget.domainSnap.id;
        //   UniquesControllers().data.currentList.value = 'WINES';

        //   UniquesControllers().data.stack.add({
        //     'path': 'WINES',
        //     'id': widget.domainSnap.id,
        //   });
        // });
        UniquesControllers().data.addToStack('WINES', widget.domainSnap.id);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          elevation: baseSpace,
          margin: EdgeInsets.all(baseSpace),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                baseSpace * 4, baseSpace * 4, baseSpace * 2, baseSpace * 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: ReorderableDragStartListener(
                    key: ValueKey(widget.domainSnap['index']),
                    index: widget.domainSnap['index'],
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.domainSnap['name'],
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: baseSpace * 3,
                            ),
                          ),
                          Spacing.height(baseSpace),
                          if (currentUserStatus != 'Ambassade')
                            Text('Facturation : ' +
                                widget.domainSnap['invoice']),
                          if (currentUserStatus == 'VHN')
                            Text('Déploiement : ' +
                                getDeploy(widget.domainSnap['deploy']) +
                                ' département(s)'),
                        ],
                      ),
                    ),
                  ),
                ),
                if (currentUserStatus == 'VHN')
                  Row(
                    children: [
                      PopupMenuButton(
                        tooltip: '',
                        child: Icon(
                          Icons.message,
                          size: baseSpace * 4,
                          color: Colors.blue,
                        ),

                        onSelected: (value) {
                          switch (value) {
                            case PopupMenuSMS.cavisteSMS:
                              getTarifs('caviste', true);
                              break;
                            case PopupMenuSMS.chrSMS:
                              getTarifs('chr', true);
                              break;
                            case PopupMenuSMS.ambassadeSMS:
                              getTarifs('ambassade', true);
                              break;
                            case PopupMenuSMS.cavisteEmail:
                              getTarifs('caviste', false);
                              break;
                            case PopupMenuSMS.chrEmail:
                              getTarifs('chr', false);
                              break;
                            case PopupMenuSMS.ambassadeEmail:
                              getTarifs('ambassade', false);
                              break;
                          }
                        },
                        // Push
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: PopupMenuSMS.cavisteSMS,
                            child: Text('Envoyer le tarif Caviste par SMS'),
                          ),
                          const PopupMenuItem(
                            value: PopupMenuSMS.chrSMS,
                            child: Text('Envoyer le tarif CHR par SMS'),
                          ),
                          const PopupMenuItem(
                            value: PopupMenuSMS.ambassadeSMS,
                            child: Text('Envoyer le tarif Ambassade par SMS'),
                          ),
                          const PopupMenuItem(
                            value: PopupMenuSMS.cavisteEmail,
                            child: Text('Envoyer le tarif Caviste par Email'),
                          ),
                          const PopupMenuItem(
                            value: PopupMenuSMS.chrEmail,
                            child: Text('Envoyer le tarif CHR par Email'),
                          ),
                          const PopupMenuItem(
                            value: PopupMenuSMS.ambassadeEmail,
                            child: Text('Envoyer le tarif Ambassade par Email'),
                          ),
                        ],
                      ),
                      Spacing.width(baseSpace),
                      PopupMenuButton(
                        tooltip: '',
                        child: Icon(
                          Icons.edit,
                          size: baseSpace * 4,
                          color: Colors.blue,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case PopupMenuItems.editItem:
                              editZoneData(
                                context,
                                setState,
                                {
                                  'name': widget.domainSnap['name'],
                                  'invoice': widget.domainSnap['invoice'],
                                  'deploy': widget.domainSnap['deploy'],
                                },
                                'DOMAIN',
                                widget.domainSnap.id,
                              );
                              break;
                            case PopupMenuItems.deleteItem:
                              deleteItemPopup(context, setState, 'DOMAIN', {
                                'id': widget.domainSnap.id,
                                'name': widget.domainSnap['name']
                              });
                          }
                        },
                        // Push
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: PopupMenuItems.editItem,
                            child: Text('Modifier le domaine'),
                          ),
                          const PopupMenuItem(
                            value: PopupMenuItems.deleteItem,
                            child: Text('Supprimer le domaine'),
                          ),
                        ],
                      ),
                    ],
                  ),
                if (currentUserStatus == 'Agent')
                  Row(
                    children: [
                      PopupMenuButton(
                        tooltip: '',
                        child: Icon(
                          Icons.message,
                          size: baseSpace * 4,
                          color: Colors.blue,
                        ),

                        onSelected: (value) {
                          switch (value) {
                            case PopupMenuSMS.cavisteSMS:
                              getTarifs('caviste', true);
                              break;
                            case PopupMenuSMS.chrSMS:
                              getTarifs('chr', true);
                              break;
                            case PopupMenuSMS.ambassadeSMS:
                              getTarifs('ambassade', true);
                              break;
                            case PopupMenuSMS.cavisteEmail:
                              getTarifs('caviste', false);
                              break;
                            case PopupMenuSMS.chrEmail:
                              getTarifs('chr', false);
                              break;
                            case PopupMenuSMS.ambassadeEmail:
                              getTarifs('ambassade', false);
                              break;
                          }
                        },
                        // Push
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: PopupMenuSMS.cavisteSMS,
                            child: Text('Envoyer le tarif Caviste par SMS'),
                          ),
                          const PopupMenuItem(
                            value: PopupMenuSMS.chrSMS,
                            child: Text('Envoyer le tarif CHR par SMS'),
                          ),
                          const PopupMenuItem(
                            value: PopupMenuSMS.ambassadeSMS,
                            child: Text('Envoyer le tarif Ambassade par SMS'),
                          ),
                          const PopupMenuItem(
                            value: PopupMenuSMS.cavisteEmail,
                            child: Text('Envoyer le tarif Caviste par Email'),
                          ),
                          const PopupMenuItem(
                            value: PopupMenuSMS.chrEmail,
                            child: Text('Envoyer le tarif CHR par Email'),
                          ),
                          const PopupMenuItem(
                            value: PopupMenuSMS.ambassadeEmail,
                            child: Text('Envoyer le tarif Ambassade par Email'),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
