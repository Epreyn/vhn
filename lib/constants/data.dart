import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vhn/functions/show_snack_bar.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _fStore = FirebaseFirestore.instance;

double baseSpace = 8.0;
double baseWidth = 500.0;

String appBarTitle = 'Liste des Vins';

// TODO SEARCH BAR
String placeholder = 'Rechercher';
bool isWanted = false;
String research = '';

// Controllers de recherche globaux
// Ces variables doivent être initialisées dans le main() ou au démarrage de l'app
late TextEditingController textCurrentController;
late TextEditingController textListController;
late TextEditingController textTableController;
late TextEditingController textTransportController;
late TextEditingController textUserController;

// NOUVEAUX CONTROLLERS POUR LA RECHERCHE GLOBALE
late TextEditingController wineSearchController;
late TextEditingController userSearchController;

// Variable globale pour forcer la mise à jour des listes
final searchUpdateNotifier = ValueNotifier<int>(0);

// Variable pour savoir quel type de recherche on fait
enum SearchType { wines, users }

SearchType currentSearchType = SearchType.wines;

// TextEditingController textListController = TextEditingController();
// TextEditingController textTableController = TextEditingController();
// TextEditingController textTransportController = TextEditingController();
// TextEditingController textUserController = TextEditingController();
// TextEditingController textCurrentController = TextEditingController();

// bool isWantedInUser = false;
// bool isWantedInList = false;
// bool isWantedInDomain = false;
// bool isWantedInArea = false;
// bool isWantedInUnFoldable = false;
// bool isWantedInTransport = false;
// TODO SEARCH BAR END

bool isPasswordReset = false;

bool isLoading = false;

bool isValidate = false;
String currentUserStatus = '';
String currentUserEmail = '';
List<String> currentUserDepartments = [];

User? currentUser;

// Enums pour les menus
enum PopupMenuItems { editItem, deleteItem }

enum PopupMenuSMS {
  cavisteSMS,
  chrSMS,
  ambassadeSMS,
  cavisteEmail,
  chrEmail,
  ambassadeEmail
}

// Fonction d'initialisation à appeler au démarrage
void initializeGlobalData() {
  // Initialiser les controllers existants
  textListController = TextEditingController();
  textTableController = TextEditingController();
  textTransportController = TextEditingController();
  textUserController = TextEditingController();

  // Initialiser les nouveaux controllers pour la recherche globale
  wineSearchController = TextEditingController();
  userSearchController = TextEditingController();

  // Par défaut, on utilise le controller de recherche de vins
  textCurrentController = wineSearchController;

  // NE PAS ajouter de listeners ici - ils seront ajoutés dans navigation_screen
}

// Fonction pour nettoyer les controllers
void disposeGlobalControllers() {
  textListController.dispose();
  textTableController.dispose();
  textTransportController.dispose();
  textUserController.dispose();
  wineSearchController.dispose();
  userSearchController.dispose();
}

// Fonctions utilitaires pour le loading
void enableLoading(Function setState) {
  setState(() {
    isLoading = true;
  });
}

void disableLoading(Function setState) {
  setState(() {
    isLoading = false;
  });
}

final Uri urlVhnEmail = Uri.parse('mailto:ponsalexandre@vinshorsnormes.com');
final Uri urlVhnPhone = Uri.parse('tel:+33-6-08-49-73-90');

final Uri urlTechnicalServiceEmail = Uri.parse('mailto:pierre@epreyn.com');
final Uri urlTechnicalServicePhone = Uri.parse('tel:+33-6-11-72-94-06');

void launchUrlFunction(url) async {
  if (!await launchUrl(url)) throw 'Could not launch $url';
}

void sendMail(setState, BuildContext context, String to, String subject,
    String body) async {
  enableLoading(setState);
  await _fStore.collection('mail').add(
    {
      'to': '$to',
      'message': {
        'subject': '$subject',
        'text': '$body',
      },
    },
  ).then((value) => disableLoading(setState));
  showSnackBar(context, 'Email envoyé');
}

const List<String> kUserStatus = [
  'Agent',
  'Caviste',
  'CHR',
  'VHN',
  'Ambassade',
  'Vigneron'
];

const List<String> kWineFormats = [
  '37,5 CL',
  '50 CL',
  '75 CL',
  '1 L',
  'Magnum',
  'Jéroboam',
];

const List<String> kWinepackaging = [
  'À l\'unité',
  'Par 3',
  'Par 3 et 6',
  'Par 6',
  'Par 6 et 12',
  'Par 8',
  'Par 12',
  'Par 24',
];

const List<String> kWineColors = [
  'Rouge',
  'Rosé',
  'Blanc',
  'Bulles',
  'Alcool',
  'Oxidatif',
  'Moelleux',
  'Vermouth',
  'Cidre'
];

final Map<String, bool> kDeploy = {
  '01': false,
  '02': false,
  '03': false,
  '04': false,
  '05': false,
  '06': false,
  '07': false,
  '08': false,
  '09': false,
  '10': false,
  '11': false,
  '12': false,
  '13': false,
  '14': false,
  '15': false,
  '16': false,
  '17': false,
  '18': false,
  '19': false,
  '2A': false,
  '2B': false,
  '21': false,
  '22': false,
  '23': false,
  '24': false,
  '25': false,
  '26': false,
  '27': false,
  '28': false,
  '29': false,
  '30': false,
  '31': false,
  '32': false,
  '33': false,
  '34': false,
  '35': false,
  '36': false,
  '37': false,
  '38': false,
  '39': false,
  '40': false,
  '41': false,
  '42': false,
  '43': false,
  '44': false,
  '45': false,
  '46': false,
  '47': false,
  '48': false,
  '49': false,
  '50': false,
  '51': false,
  '52': false,
  '53': false,
  '54': false,
  '55': false,
  '56': false,
  '57': false,
  '58': false,
  '59': false,
  '60': false,
  '61': false,
  '62': false,
  '63': false,
  '64': false,
  '65': false,
  '66': false,
  '67': false,
  '68': false,
  '69': false,
  '70': false,
  '71': false,
  '72': false,
  '73': false,
  '74': false,
  '75': false,
  '76': false,
  '77': false,
  '78': false,
  '79': false,
  '80': false,
  '81': false,
  '82': false,
  '83': false,
  '84': false,
  '85': false,
  '86': false,
  '87': false,
  '88': false,
  '89': false,
  '90': false,
  '91': false,
  '92': false,
  '93': false,
  '94': false,
  '95': false,
  '98': false,
};
