import 'package:flutter/material.dart';

import '../admin/dashboard.dart';
import 'login.dart';
import '../services/auth_session.dart';
import '../widgets/app_card.dart';
import '../widgets/app_form_field.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  static const _blue = Color(0xFF1769F5);
  static const _navy = Color(0xFF17356F);
  static const _muted = Color(0xFF60769A);
  String _nom = 'Utilisateur AWA';
  String _telephone = '+243 000 000 000';
  bool _notifications = true;
  bool _modeSombre = false;

  @override
  void initState() {
    super.initState();
    _nom = AuthSession.nom ?? _nom;
    _telephone = AuthSession.telephone ?? _telephone;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, color: _blue, size: 28),
            ),
            const Expanded(
              child: Center(
                child: Image(
                  image: AssetImage('assets/images/logo1.png'),
                  height: 100,
                ),
              ),
            ),
            IconButton(
              onPressed: _ouvrirParametres,
              icon: const Icon(
                Icons.notifications_none,
                color: _blue,
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Mon profil',
            style: TextStyle(
              color: _navy,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mon profil',
                style: TextStyle(
                  color: _navy,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/entry.png',
                      width: 142,
                      height: 142,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) => const CircleAvatar(
                        radius: 71,
                        backgroundColor: Color(0xFFEAF3FF),
                        child: Icon(Icons.person, color: _blue, size: 60),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nom,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Icon(Icons.person_outline, color: _blue, size: 19),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Patient AWA',
                                  style: TextStyle(color: _muted, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, color: _blue, size: 19),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _telephone,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _modifierProfil,
                  icon: const Icon(Icons.edit_outlined, size: 19),
                  label: const Text('Modifier'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _blue,
                    side: const BorderSide(color: _blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Mon activité',
          style: TextStyle(
            color: _navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        _option(
          Icons.receipt_long_outlined,
          'Historique des achats',
          'Voir mes commandes de médicaments',
          _ouvrirHistorique,
        ),
        _option(
          Icons.calendar_month_outlined,
          'Mes rendez-vous',
          'Voir mes consultations médicales',
          () => _message('Aucun rendez-vous enregistré.'),
        ),
        _option(
          Icons.location_on_outlined,
          'Adresses de livraison',
          'Gérer mes adresses',
          () => _message('La gestion des adresses sera bientôt disponible.'),
        ),
        const SizedBox(height: 18),
        const Text(
          'Informations',
          style: TextStyle(
            color: _navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        _option(
          Icons.policy_outlined,
          'Politique de confidentialité',
          'Consulter notre politique',
          _ouvrirPolitique,
        ),
        _option(
          Icons.description_outlined,
          'Conditions d’utilisation',
          'Lire les conditions de service',
          _ouvrirConditions,
        ),
        _option(
          Icons.help_outline,
          'Aide et assistance',
          'Nous sommes disponibles 24/7',
          () => _message('Contactez-nous au +243 000 000 000.'),
        ),
        const SizedBox(height: 18),
        if (AuthSession.role == 'admin') ...[
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            ),
            style: FilledButton.styleFrom(backgroundColor: _blue),
            icon: const Icon(Icons.dashboard_outlined),
            label: const Text('Ouvrir le dashboard'),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: _seDeconnecter,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent),
            foregroundColor: Colors.redAccent,
            overlayColor: const Color(0xFF7890B1).withValues(alpha: 0.12),
          ),
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          label: const Text(
            'Se déconnecter',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _option(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    tileColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    leading: CircleAvatar(
      backgroundColor: const Color(0xFFEAF3FF),
      child: Icon(icon, color: _blue),
    ),
    title: Text(
      title,
      style: const TextStyle(color: _navy, fontWeight: FontWeight.w800),
    ),
    subtitle: Text(subtitle, style: const TextStyle(color: _muted)),
    trailing: const Icon(Icons.chevron_right, color: _blue),
  );

  Future<void> _modifierProfil() async {
    final nomController = TextEditingController(text: _nom);
    final telephoneController = TextEditingController(text: _telephone);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modifier mon profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppFormField(controller: nomController, label: 'Nom complet'),
            AppFormField(
              controller: telephoneController,
              keyboardType: TextInputType.phone,
              label: 'Téléphone',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                if (nomController.text.trim().isNotEmpty) {
                  _nom = nomController.text.trim();
                }

                if (telephoneController.text.trim().isNotEmpty) {
                  _telephone = telephoneController.text.trim();
                }
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    nomController.dispose();
    telephoneController.dispose();
  }

  void _ouvrirHistorique() => _ouvrirInfo(
    'Historique des achats',
    'Vos commandes de médicaments apparaîtront ici après votre premier achat.',
    Icons.receipt_long_outlined,
  );
  void _ouvrirPolitique() => _ouvrirInfo(
    'Politique de confidentialité',
    'AWA protège vos données personnelles. Elles sont utilisées uniquement pour gérer votre compte, vos commandes et vos consultations.',
    Icons.policy_outlined,
  );
  void _ouvrirConditions() => _ouvrirInfo(
    'Conditions d’utilisation',
    'Les consultations en ligne sont préliminaires et ne remplacent pas une prise en charge médicale urgente.',
    Icons.description_outlined,
  );

  void _ouvrirInfo(String titre, String contenu, IconData icon) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _blue, size: 34),
              const SizedBox(height: 12),
              Text(
                titre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                contenu,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: FilledButton.styleFrom(backgroundColor: _blue),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _ouvrirParametres() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Paramètres du compte',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              SwitchListTile(
                value: _notifications,
                onChanged: (value) {
                  setState(() => _notifications = value);
                  setModalState(() {});
                },
                activeThumbColor: _blue,
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                subtitle: const Text('Recevoir les rappels et nouveautés'),
              ),
              SwitchListTile(
                value: _modeSombre,
                onChanged: (value) {
                  setState(() => _modeSombre = value);
                  setModalState(() {});
                },
                activeThumbColor: _blue,
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Mode sombre'),
                subtitle: const Text('Préférence enregistrée pour le compte'),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Langue'),
                trailing: const Text('Français'),
                onTap: () {},
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _seDeconnecter() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Vous devrez vous reconnecter pour accéder à votre compte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              await AuthSession.close();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
                (_) => false,
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}
