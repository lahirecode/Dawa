import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../modele/client.dart';
import '../modele/discussions.dart';
import '../modele/medecin.dart';
import '../modele/compte_professionnel.dart';
import '../modele/produit.dart';
import '../services/db_manager.dart';
import '../services/auth_session.dart';
import '../views/login.dart';
import '../widgets/app_form_field.dart';
import 'medecins.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _blue = Color(0xFF0D5BEA);
  static const _navy = Color(0xFF073B91);
  static const _ink = Color(0xFF17356F);
  static const _pale = Color(0xFFF4F8FE);
  final _db = Dbmanager();
  int _tab = 0;
  bool _loading = true;
  List<Produit> _produits = [];
  List<Medecin> _medecins = [];
  List<Client> _clients = [];
  List<Discussion> _discussions = [];
  List<CompteProfessionnel> _comptes = [];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final produitsFuture = FirebaseFirestore.instance
          .collection('products')
          .orderBy('nom')
          .get();
      final medecinsFuture = FirebaseFirestore.instance
          .collection('doctors')
          .orderBy('nom')
          .get();
      final clientsFuture = FirebaseFirestore.instance
          .collection('clients')
          .orderBy('nom')
          .get();
      final discussionsFuture = FirebaseFirestore.instance
          .collection('discussions')
          .orderBy('date_envoi', descending: true)
          .get();
      final comptesFuture = FirebaseFirestore.instance
          .collection('professionals')
          .orderBy('nom')
          .get();

      final produitsSnapshot = await produitsFuture;
      final medecinsSnapshot = await medecinsFuture;
      final clientsSnapshot = await clientsFuture;
      final discussionsSnapshot = await discussionsFuture;
      final comptesSnapshot = await comptesFuture;
      if (!mounted) return;
      setState(() {
        _produits = produitsSnapshot.docs.map(Produit.fromDoc).toList();
        _medecins = medecinsSnapshot.docs.map(Medecin.fromDoc).toList();
        _clients = clientsSnapshot.docs.map(Client.fromDoc).toList();
        _discussions = discussionsSnapshot.docs
            .map(Discussion.fromDoc)
            .toList();
        _comptes = comptesSnapshot.docs
            .map(CompteProfessionnel.fromDoc)
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      allowedRoles: const ['admin'],
      child: Scaffold(
        backgroundColor: _pale,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 900;
                  return Row(
                    children: [
                      if (!compact) _sidebar(),
                      Expanded(
                        child: _tab == 0
                            ? _dashboardHome(compact)
                            : Column(
                                children: [
                                  _topBar(compact),
                                  Expanded(child: _contenu()),
                                ],
                              ),
                      ),
                    ],
                  );
                },
              ),
        floatingActionButton:
            _tab != 0 && (_tab == 1 || _tab == 4 || _tab == 10) && !_loading
            ? FloatingActionButton.extended(
                onPressed: _tab == 1
                    ? _produitDialog
                    : _tab == 10
                    ? _medecinDialog
                    : _compteDialog,
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: Text(
                  _tab == 1
                      ? 'Produit'
                      : _tab == 10
                      ? 'Médecin'
                      : 'Identifiant',
                ),
              )
            : null,
      ),
    );
  }

  Widget _sidebar() => Container(
    width: 198,
    color: _navy,
    padding: const EdgeInsets.fromLTRB(10, 18, 10, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 0, 7),
          child: Image.asset(
            'assets/images/logo.png',
            width: 125,
            height: 48,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.medication, color: _blue, size: 36),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 26),
          child: Text(
            'Votre santé, notre priorité',
            style: TextStyle(color: Colors.white70, fontSize: 8),
          ),
        ),
        const SizedBox(height: 34),
        _navItem(0, Icons.home_rounded, 'Tableau de bord'),
        _navItem(1, Icons.medication_rounded, 'Médicaments'),
        _navItem(5, Icons.shopping_cart_rounded, 'Commandes', badge: '3'),
        _navItem(2, Icons.people_alt_rounded, 'Patients'),
        _navItem(3, Icons.medical_services_rounded, 'Consultations'),
        _navItem(10, Icons.badge_rounded, 'Docteurs'),
        _navItem(6, Icons.calendar_month_rounded, 'Rendez-vous'),
        _navItem(7, Icons.credit_card_rounded, 'Paiements'),
        _navItem(8, Icons.bar_chart_rounded, 'Rapports'),
        _navItem(4, Icons.settings_rounded, 'Paramètres'),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.local_shipping_rounded, color: Colors.white, size: 30),
              SizedBox(height: 12),
              Text(
                'Livraison rapide\nde vos médicaments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'À domicile partout à Kinshasa et dans les grandes villes.',
                style: TextStyle(color: Colors.white70, fontSize: 9),
              ),
              SizedBox(height: 12),
              Text(
                'Voir les détails  →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _navItem(int tab, IconData icon, String label, {String? badge}) {
    final selected = _tab == tab;
    return InkWell(
      onTap: () => setState(() => _tab = tab),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? _blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(bool compact) => Container(
    height: 64,
    padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 28),
    color: Colors.white,
    child: Row(
      children: [
        if (compact) const Icon(Icons.menu, color: _ink),
        if (compact) const SizedBox(width: 14),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            height: 38,
            decoration: BoxDecoration(
              color: _pale,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Color(0xFF7590B9)),
                hintText:
                    'Rechercher un médicament, un patient, une commande...',
                hintStyle: TextStyle(fontSize: 11, color: Color(0xFF7590B9)),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _charger,
          icon: const Icon(Icons.notifications_none, color: _ink),
        ),
        const CircleAvatar(
          radius: 17,
          backgroundColor: Color(0xFFDDE8FA),
          child: Icon(Icons.person, color: _blue),
        ),
        if (!compact)
          const Padding(
            padding: EdgeInsets.only(left: 9),
            child: Text(
              'Dr. Tshibangu\nAdministrateur',
              style: TextStyle(
                fontSize: 10,
                color: _ink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        IconButton(
          onPressed: _deconnexion,
          icon: const Icon(Icons.logout_rounded, color: _ink),
          tooltip: 'Se déconnecter',
        ),
        IconButton(
          onPressed: _deconnexion,
          icon: const Icon(Icons.keyboard_arrow_down, color: _ink),
          tooltip: 'Se déconnecter',
        ),
      ],
    ),
  );

  Widget _dashboardHome(bool compact) => Column(
    children: [
      _topBar(compact),
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bonjour, Dr. Tshibangu 👋',
                      style: TextStyle(
                        fontSize: compact ? 21 : 24,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                  ),
                  const Text(
                    'Mercredi 28 mai 2025',
                    style: TextStyle(fontSize: 10, color: _ink),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Voici un aperçu de l'activité de votre plateforme aujourd'hui.",
                style: TextStyle(fontSize: 11, color: Color(0xFF7890B1)),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _statCard(
                    'Total des médicaments',
                    _produits.isEmpty ? '1 248' : _produits.length.toString(),
                    '+12%',
                    Icons.medication_rounded,
                  ),
                  _statCard(
                    'Commandes en cours',
                    '36',
                    '+8%',
                    Icons.shopping_cart_rounded,
                  ),
                  _statCard(
                    'Patients enregistrés',
                    _clients.isEmpty ? '2 842' : _clients.length.toString(),
                    '+15%',
                    Icons.groups_rounded,
                  ),
                  _statCard(
                    "Consultations aujourd'hui",
                    '18',
                    '+20%',
                    Icons.medical_services_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (compact) ...[
                _salesPanel(),
                const SizedBox(height: 14),
                _ordersPanel(),
                const SizedBox(height: 14),
                _recentOrders(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _salesPanel()),
                              const SizedBox(width: 14),
                              Expanded(child: _ordersPanel()),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _recentOrders(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(width: 245, child: _activityRail()),
                  ],
                ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _statCard(String title, String value, String change, IconData icon) =>
      SizedBox(
        width: 190,
        child: _panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFEAF2FF),
                child: Icon(icon, color: _blue, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6F87AA)),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '↑ $change',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF16A66A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'par rapport à hier',
                style: TextStyle(fontSize: 8, color: Color(0xFF8CA1C0)),
              ),
            ],
          ),
        ),
      );

  Widget _salesPanel() => _panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ventes des médicaments',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Évolution sur les 7 derniers jours',
          style: TextStyle(color: Color(0xFF7890B1), fontSize: 9),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: CustomPaint(
            painter: _SalesPainter(),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    ),
  );

  Widget _ordersPanel() => _panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Répartition des commandes',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            SizedBox(
              width: 116,
              height: 116,
              child: CustomPaint(
                painter: _DonutPainter(),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '36',
                        style: TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Commandes',
                        style: TextStyle(color: Color(0xFF7890B1), fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '●  Médicaments       58%',
                    style: TextStyle(color: _ink, fontSize: 9),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '●  Consultations      22%',
                    style: TextStyle(color: _ink, fontSize: 9),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '●  Accessoires        12%',
                    style: TextStyle(color: _ink, fontSize: 9),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '●  Autres              8%',
                    style: TextStyle(color: _ink, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _recentOrders() => _panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Commandes récentes',
              style: TextStyle(
                color: _ink,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => _tab = 0),
              child: const Text(
                'Voir toutes →',
                style: TextStyle(fontSize: 9, color: _blue),
              ),
            ),
          ],
        ),
        const Divider(height: 8),
        ...[
          'Marie Mulumba',
          'Jean Kabasele',
          'Aicha Banza',
          'Patrick Mbuyi',
          'Sandra Ilunga',
        ].asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    '#CMD-0012${45 - entry.key}',
                    style: const TextStyle(fontSize: 9, color: _blue),
                  ),
                ),
                const CircleAvatar(
                  radius: 10,
                  backgroundColor: Color(0xFFE7EFFB),
                  child: Icon(Icons.person, size: 12, color: _blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 9,
                      color: _ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(
                  '3 articles',
                  style: TextStyle(fontSize: 8, color: Color(0xFF7890B1)),
                ),
                const SizedBox(width: 24),
                Text(
                  entry.key.isEven ? 'Livrée' : 'En cours',
                  style: TextStyle(
                    fontSize: 8,
                    color: entry.key.isEven ? const Color(0xFF16A66A) : _blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 22),
                const Icon(Icons.more_vert, size: 15, color: _ink),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _activityRail() => Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.medical_services_outlined,
              color: Colors.white,
              size: 30,
            ),
            SizedBox(height: 9),
            Text(
              'Nouvelle consultation',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Organisez une consultation en ligne avec un spécialiste.',
              style: TextStyle(color: Colors.white70, fontSize: 9),
            ),
            SizedBox(height: 13),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 7),
                child: Text(
                  'Démarrer  →',
                  style: TextStyle(
                    color: Color(0xFF0D5BEA),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _quickAction(
              Icons.medication_rounded,
              'Ajouter un médicament',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _quickAction(
              Icons.person_add_alt_1_rounded,
              'Nouveau patient',
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _quickAction(
              Icons.calendar_month_rounded,
              'Prendre un rendez-vous',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _quickAction(
              Icons.credit_card_rounded,
              'Voir les paiements',
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _panel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: _blue),
                SizedBox(width: 7),
                Text(
                  'Prochains rendez-vous',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...['Dr. Kanyiki M.', 'Dr. Mukendi S.', 'Dr. NtabaIa F.'].map(
              (name) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFFE1ECFA),
                      child: Icon(Icons.person, size: 15, color: _blue),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '$name\nAujourd’hui · 10:30',
                        style: const TextStyle(fontSize: 8, color: _ink),
                      ),
                    ),
                    const Text(
                      'Rejoindre',
                      style: TextStyle(
                        color: _blue,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _panel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications, size: 14, color: _blue),
                SizedBox(width: 7),
                Text(
                  'Dernières notifications',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            ...[
              'Nouvelle commande #CMD-001245',
              'Consultation terminée avec succès',
              'Un nouveau patient s’est inscrit',
              'Stock de Paracétamol faible',
            ].map(
              (message) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 7, color: _blue),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(fontSize: 8, color: _ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _quickAction(IconData icon, String label) => Container(
    height: 76,
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFE2EBF6)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: _blue, size: 21),
        const SizedBox(height: 7),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _ink,
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _panel(Widget child) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFE2EBF6)),
    ),
    child: child,
  );

  Widget _contenu() {
    if (_tab == 0) return _produitsView();
    if (_tab == 1) return _produitsView();
    if (_tab == 2) return _clientsView();
    if (_tab == 4) return _comptesView();
    if (_tab == 3) return _discussionsView();
    if (_tab == 10) return _medecinsView();
    if (_tab == 5) {
      return _reportView(Icons.shopping_cart_rounded, 'Commandes', [
        'Référence',
        'Client',
        'Montant',
        'Statut',
      ], 'Aucune commande enregistrée.');
    }
    if (_tab == 6) {
      return _reportView(Icons.calendar_month_rounded, 'Rendez-vous', [
        'Médecin',
        'Client',
        'Date',
        'Statut',
      ], 'Aucun rendez-vous enregistré.');
    }
    if (_tab == 7) {
      return _reportView(Icons.credit_card_rounded, 'Paiements', [
        'Référence',
        'Commande',
        'Montant',
        'Mode',
      ], 'Aucun paiement enregistré.');
    }
    if (_tab == 8) {
      return _reportView(
        Icons.bar_chart_rounded,
        'Rapports',
        ['Indicateur', 'Valeur', 'Période'],
        'Aucune donnée de rapport disponible.',
        report: true,
      );
    }
    return _sectionView(
      Icons.settings_rounded,
      'Paramètres',
      'Les paramètres de la plateforme seront disponibles ici.',
    );
  }

  Widget _sectionView(IconData icon, String title, String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: _blue),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(color: Color(0xFF7890B1))),
      ],
    ),
  );

  Widget _reportView(
    IconData icon,
    String title,
    List<String> columns,
    String emptyMessage, {
    bool report = false,
  }) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Row(
        children: [
          Icon(icon, color: _blue, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (report)
            OutlinedButton.icon(
              onPressed: _exporterRapport,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Télécharger'),
            ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: _metric('Entrées', '${_produits.length}')),
          const SizedBox(width: 10),
          Expanded(child: _metric('Clients', '${_clients.length}')),
          const SizedBox(width: 10),
          Expanded(child: _metric('Médecins', '${_medecins.length}')),
        ],
      ),
      const SizedBox(height: 16),
      _panel(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns
                .map((column) => DataColumn(label: Text(column)))
                .toList(),
            rows: const [],
          ),
        ),
      ),
      const SizedBox(height: 18),
      Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Color(0xFF7890B1)),
        ),
      ),
    ],
  );

  Widget _metric(String label, String value) => _panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF7890B1))),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: _ink,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  void _exporterRapport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Le rapport PDF sera généré dès que les commandes et paiements seront enregistrés.',
        ),
      ),
    );
  }

  void _deconnexion() {
    AuthSession.close();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (_) => false,
    );
  }

  Widget _produitsView() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _produits.length,
    itemBuilder: (_, index) {
      final produit = _produits[index];
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFEFF1FF),
            child: Image.asset(
              produit.image,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.medication, color: _blue),
            ),
          ),
          title: Text(
            produit.nom,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${produit.categorie} • ${produit.forme}\nStock: ${produit.stock}  |  Prix: \$${produit.prix.toStringAsFixed(2)}',
          ),
          isThreeLine: true,
          trailing: Wrap(
            children: [
              IconButton(
                onPressed: () => _produitDialog(produit),
                icon: const Icon(Icons.edit_outlined, color: _blue),
              ),
              IconButton(
                onPressed: () => _supprimerProduit(produit),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _medecinsView() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _medecins.length,
    itemBuilder: (_, index) {
      final medecin = _medecins[index];
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFEFF1FF),
            backgroundImage: AssetImage(medecin.photo),
            child: medecin.photo.isEmpty
                ? const Icon(Icons.person, color: _blue)
                : null,
          ),
          title: Text(
            medecin.nom,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text('${medecin.specialite}\n${medecin.telephone}'),
          isThreeLine: true,
          trailing: Wrap(
            children: [
              Switch(
                value: medecin.disponible,
                onChanged: (value) => _changerDisponibilite(medecin, value),
                activeThumbColor: _blue,
              ),
              IconButton(
                onPressed: () => _medecinDialog(medecin),
                icon: const Icon(Icons.edit_outlined, color: _blue),
              ),
              IconButton(
                onPressed: () => _supprimerMedecin(medecin),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _clientsView() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _clients.length,
    itemBuilder: (_, index) {
      final client = _clients[index];
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: (client.photo != null && client.photo!.isNotEmpty)
                ? AssetImage(client.photo!)
                : null,
            child: (client.photo == null || client.photo!.isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(
            client.nom,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${client.telephone}\nInscrit le ${client.date_inscription?.toLocal().toString().split(' ').first ?? '-'}',
          ),
          isThreeLine: true,
          trailing: Wrap(
            children: [
              IconButton(
                onPressed: () => _clientDialog(client),
                icon: const Icon(Icons.edit_outlined, color: _blue),
              ),
              IconButton(
                onPressed: () => _supprimerClient(client),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _discussionsView() => _discussions.isEmpty
      ? const Center(child: Text('Aucune discussion enregistrée.'))
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _discussions.length,
          itemBuilder: (_, index) {
            final discussion = _discussions[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  discussion.type == TypeDiscussion.audio
                      ? Icons.mic
                      : Icons.chat_bubble_outline,
                  color: _blue,
                ),
                title: Text(
                  'Client #${discussion.clientId} • ${discussion.medecin}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(discussion.contenu),
                trailing: discussion.lu
                    ? const Icon(Icons.done_all, color: Colors.green)
                    : IconButton(
                        onPressed: () => _marquerLue(discussion),
                        icon: const Icon(Icons.mark_chat_read_outlined),
                      ),
                onTap: () {
                  final client = _clients.cast<Client?>().firstWhere(
                    (value) => value?.clientId == discussion.clientId,
                    orElse: () => null,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedecinChatPage(
                        discId: discussion.discId!,
                        clientId: discussion.clientId,
                        nomClient: client?.nom ?? 'Patient',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );

  Widget _comptesView() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _comptes.length,
    itemBuilder: (_, index) {
      final compte = _comptes[index];
      return Card(
        child: ListTile(
          leading: Icon(
            compte.role == 'admin'
                ? Icons.admin_panel_settings_outlined
                : Icons.medical_services_outlined,
            color: _blue,
          ),
          title: Text(
            compte.nom,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text('${compte.telephone}\nRôle : ${compte.role}'),
          isThreeLine: true,
          trailing: IconButton(
            onPressed: () async {
              await _db.supprimerCompteProfessionnel(compte.id!);
              await _charger();
            },
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ),
      );
    },
  );

  Future<void> _clientDialog(Client client) async {
    final nom = TextEditingController(text: client.nom);
    final telephone = TextEditingController(text: client.telephone);
    final email = TextEditingController(text: client.email);
    final photo = TextEditingController(text: client.photo);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modifier le client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input(nom, 'Nom'),
            _input(telephone, 'Téléphone'),
            _input(email, 'Email'),
            _input(photo, 'Photo (chemin asset ou URL)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final updated = Client(
                clientId: client.clientId,
                nom: nom.text.trim(),
                telephone: telephone.text.trim(),
                email: email.text.trim(),
                date_inscription: client.date_inscription,
                photo: photo.text.trim().isEmpty
                    ? 'assets/images/entry.png'
                    : photo.text.trim(),
              );
              if (updated.nom.isEmpty || updated.telephone.isEmpty) return;
              await _db.updateClient(updated);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              await _charger();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    nom.dispose();
    telephone.dispose();
    email.dispose();
    photo.dispose();
  }

  Future<void> _compteDialog() async {
    final nom = TextEditingController();
    final telephone = TextEditingController();
    final motDePasse = TextEditingController();
    String role = 'medecin';
    String? medecinId;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Créer un identifiant professionnel'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _input(nom, 'Nom complet'),
                _input(telephone, 'Téléphone / identifiant'),
                _input(motDePasse, 'Mot de passe'),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrateur'),
                    ),
                    DropdownMenuItem(value: 'medecin', child: Text('Médecin')),
                    DropdownMenuItem(
                      value: 'fournisseur',
                      child: Text('Fournisseur'),
                    ),
                  ],
                  onChanged: (value) => setDialogState(() {
                    role = value ?? 'medecin';
                    medecinId = null;
                  }),
                ),
                if (role == 'medecin') ...[
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: medecinId,
                    decoration: const InputDecoration(
                      labelText: 'Profil médecin lié',
                      border: OutlineInputBorder(),
                    ),
                    items: _medecins
                        .map(
                          (medecin) => DropdownMenuItem(
                            value: medecin.id,
                            child: Text(medecin.nom),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => medecinId = value),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (nom.text.trim().isEmpty ||
                    telephone.text.trim().isEmpty ||
                    motDePasse.text.isEmpty) {
                  return;
                }
                await _db.creerCompteProfessionnel(
                  nom: nom.text,
                  telephone: telephone.text,
                  motDePasse: motDePasse.text,
                  role: role,
                  medecinId: medecinId,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                await _charger();
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
    nom.dispose();
    telephone.dispose();
    motDePasse.dispose();
  }

  Future<void> _produitDialog([Produit? produit]) async {
    final nom = TextEditingController(text: produit?.nom ?? '');
    final description = TextEditingController(text: produit?.description ?? '');
    final details = TextEditingController(text: produit?.details ?? '');
    final categorie = TextEditingController(text: produit?.categorie ?? '');
    final specialite = TextEditingController(text: produit?.specialite ?? '');
    final forme = TextEditingController(text: produit?.forme ?? '');
    final prix = TextEditingController(text: produit?.prix.toString() ?? '');
    final stock = TextEditingController(text: produit?.stock.toString() ?? '');
    final image = TextEditingController(
      text: produit?.image ?? 'assets/photos/items1.png',
    );
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          produit == null ? 'Ajouter un produit' : 'Modifier le produit',
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _input(nom, 'Nom'),
              _input(description, 'Description'),
              _input(details, 'Détails'),
              _input(categorie, 'Catégorie'),
              _input(specialite, 'Spécialité'),
              _input(forme, 'Forme'),
              _input(prix, 'Prix', number: true),
              _input(stock, 'Stock', number: true),
              _input(image, 'Image (URL ou chemin asset)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final nouveau = Produit(
                id: produit?.id,
                nom: nom.text,
                description: description.text,
                details: details.text,
                categorie: categorie.text,
                specialite: specialite.text,
                forme: forme.text,
                prix: double.tryParse(prix.text) ?? 0,
                stock: int.tryParse(stock.text) ?? 0,
                image: image.text.trim().isEmpty
                    ? 'assets/photos/items1.png'
                    : image.text.trim(),
              );
              final products = FirebaseFirestore.instance.collection(
                'products',
              );
              if (produit == null) {
                final reference = products.doc();
                await reference.set({...nouveau.toMap(), 'id': reference.id});
              } else if (nouveau.id != null && nouveau.id!.isNotEmpty) {
                await products.doc(nouveau.id).set({
                  ...nouveau.toMap(),
                  'id': nouveau.id,
                }, SetOptions(merge: true));
              }
              if (context.mounted) Navigator.pop(context);
              await _charger();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    for (final controller in [
      nom,
      description,
      details,
      categorie,
      specialite,
      forme,
      prix,
      stock,
      image,
    ]) {
      controller.dispose();
    }
  }

  Future<void> _medecinDialog([Medecin? medecin]) async {
    final nom = TextEditingController(text: medecin?.nom ?? '');
    final specialite = TextEditingController(text: medecin?.specialite ?? '');
    final telephone = TextEditingController(text: medecin?.telephone ?? '');
    final photo = TextEditingController(
      text: medecin?.photo ?? 'assets/images/entry.png',
    );
    bool disponible = medecin?.disponible ?? true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            medecin == null ? 'Ajouter un médecin' : 'Modifier le médecin',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(nom, 'Nom'),
              _input(specialite, 'Spécialité'),
              _input(telephone, 'Téléphone'),
              _input(photo, 'Photo (chemin asset ou URL)'),
              SwitchListTile(
                value: disponible,
                onChanged: (value) => setDialogState(() => disponible = value),
                title: const Text('Disponible'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                final nouveau = Medecin(
                  id: medecin?.id,
                  nom: nom.text,
                  specialite: specialite.text,
                  telephone: telephone.text,
                  disponible: disponible,
                  photo: photo.text.trim().isEmpty
                      ? 'assets/images/entry.png'
                      : photo.text.trim(),
                );
                if (medecin == null) {
                  await _db.insertMedecin(nouveau);
                } else {
                  await _db.updateMedecin(nouveau);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                await _charger();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    nom.dispose();
    specialite.dispose();
    telephone.dispose();
    photo.dispose();
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) => AppFormField(
    controller: controller,
    label: label,
    keyboardType: number ? TextInputType.number : TextInputType.text,
  );

  Future<void> _changerDisponibilite(Medecin medecin, bool disponible) async {
    await _db.updateMedecin(
      Medecin(
        nom: medecin.nom,
        specialite: medecin.specialite,
        telephone: medecin.telephone,
        disponible: disponible,
        photo: medecin.photo,
      ),
    );
    await _charger();
  }

  Future<void> _supprimerProduit(Produit produit) async {
    await _db.deleteProduit(produit.id!);
    await _charger();
  }

  Future<void> _supprimerMedecin(Medecin medecin) async {
    await _db.deleteMedecin(medecin.id!);
    await _charger();
  }

  Future<void> _supprimerClient(Client client) async {
    await _db.deleteClient(client.clientId);
    await _charger();
  }

  Future<void> _marquerLue(Discussion discussion) async {
    await _db.marquerDiscussionLue(discussion.discId!);
    await _charger();
  }
}

class _SalesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFE8EFF8)
      ..strokeWidth = 1;
    final line = Paint()
      ..color = const Color(0xFF1767EA)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = const Color(0x33176AEA)
      ..style = PaintingStyle.fill;
    final points = [
      Offset(18, size.height * .72),
      Offset(size.width * .18, size.height * .55),
      Offset(size.width * .32, size.height * .50),
      Offset(size.width * .46, size.height * .42),
      Offset(size.width * .60, size.height * .44),
      Offset(size.width * .74, size.height * .30),
      Offset(size.width * .90, size.height * .12),
    ];
    for (var index = 0; index < 5; index++) {
      final y = size.height * index / 4;
      canvas.drawLine(
        18 == 0 ? Offset.zero : Offset(18, y),
        Offset(size.width, y),
        grid,
      );
    }
    final area = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    final graph = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      graph.lineTo(point.dx, point.dy);
      area.lineTo(point.dx, point.dy);
    }
    area.lineTo(points.last.dx, size.height);
    area.close();
    canvas.drawPath(area, fill);
    canvas.drawPath(graph, line);
    final dot = Paint()..color = const Color(0xFF1767EA);
    for (final point in points) {
      canvas.drawCircle(point, 3.5, dot);
    }
    const labels = [
      '22/05',
      '23/05',
      '24/05',
      '25/05',
      '26/05',
      '27/05',
      '28/05',
    ];
    for (var index = 0; index < labels.length; index++) {
      final text = TextPainter(
        text: TextSpan(
          text: labels[index],
          style: const TextStyle(color: Color(0xFF7890B1), fontSize: 7),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(points[index].dx - 13, size.height - 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 7;
    final values = [0.58, 0.22, 0.12, 0.08];
    final colors = [
      const Color(0xFF1261E9),
      const Color(0xFF3B8EF5),
      const Color(0xFF21A9E8),
      const Color(0xFF70C8ED),
    ];
    var start = -1.5708;
    for (var index = 0; index < values.length; index++) {
      final paint = Paint()
        ..color = colors[index]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16;
      final sweep = values[index] * 6.28318;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
