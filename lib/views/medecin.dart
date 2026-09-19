import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../modele/medecin.dart';
import '../services/db_manager.dart';
import '../services/auth_session.dart';
import '../theme/app_colors.dart';
import '../widgets/app_brand.dart';
import '../widgets/app_card.dart';
import '../widgets/message_ordonnance.dart';

class MedecinPage extends StatefulWidget {
  const MedecinPage({super.key});

  @override
  State<MedecinPage> createState() => _MedecinPageState();
}

class _MedecinPageState extends State<MedecinPage> {
  static const _blue = AppColors.blue;
  static const _navy = AppColors.navy;
  static const _muted = AppColors.muted;
  final _db = Dbmanager();
  List<Medecin> _doctors = [];
  bool _loading = true;
  int _selectedDoctorIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final doctors = await _db.getAllMedecins();
    if (!mounted) return;
    setState(() {
      _doctors = doctors;
      _selectedDoctorIndex = doctors.isEmpty
          ? 0
          : doctors.indexWhere((doctor) => doctor.disponible) >= 0
          ? doctors.indexWhere((doctor) => doctor.disponible)
          : 0;
      _loading = false;
    });
  }

  Medecin? get _doctor {
    if (_doctors.isEmpty) return null;
    final index = _selectedDoctorIndex.clamp(0, _doctors.length - 1);
    return _doctors[index];
  }

  @override
  Widget build(BuildContext context) {
    final doctor = _doctor;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _header(),
        const SizedBox(height: 12),
        if (_loading)
          const SizedBox(
            height: 430,
            child: Center(child: CircularProgressIndicator(color: _blue)),
          )
        else if (doctor == null)
          _card(
            const Padding(
              padding: EdgeInsets.all(28),
              child: Text(
                'Aucun médecin n’est encore disponible.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 16),
              ),
            ),
          )
        else ...[
          _doctorSelector(),
          const SizedBox(height: 14),
          _profileCard(doctor),
          const SizedBox(height: 14),
          _availabilityCard(doctor),
          const SizedBox(height: 14),
          _aboutCard(doctor),
        ],
      ],
    );
  }

  Widget _doctorSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Nos médecins',
        style: TextStyle(
          color: _navy,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 178,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _doctors.length,
          separatorBuilder: (_, _) => const SizedBox(width: 22),
          itemBuilder: (_, index) {
            final doctor = _doctors[index];
            final selected = index == _selectedDoctorIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedDoctorIndex = index),
              child: SizedBox(
                width: 142,
                child: Column(
                  children: [
                    _doctorImage(
                      doctor,
                      size: 112,
                      border: selected ? _blue : const Color(0xFFE2ECFA),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      doctor.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? _blue : _navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      doctor.specialite,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _header() => Row(
    children: [
      IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back, color: _blue, size: 28),
      ),
      const Expanded(child: Center(child: AppBrand(height: 60))),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications_none, color: _blue, size: 28),
      ),
    ],
  );

  Widget _profileCard(Medecin doctor) => _card(
    Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Contacter un médecin',
            style: TextStyle(
              color: _navy,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Prenez rendez-vous avec un spécialiste de confiance.',
            style: TextStyle(color: _muted, fontSize: 14),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _doctorImage(doctor, size: 142),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.nom,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _infoLine(
                      doctor.disponible ? Icons.check_circle : Icons.circle,
                      doctor.disponible ? 'Disponible' : 'Indisponible',
                      color: doctor.disponible ? Colors.green : Colors.orange,
                    ),
                    _infoLine(
                      Icons.medical_services_outlined,
                      doctor.specialite,
                    ),
                    _infoLine(
                      Icons.star,
                      '4.9 (128 avis)',
                      color: Colors.orange,
                    ),
                    _infoLine(Icons.school_outlined, '8 ans d’expérience'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: _actionButton(
            Icons.chat_bubble_outline,
            'Discussion',
            onPressed: doctor.disponible ? () => _openChat(doctor) : null,
          ),
        ),
      ],
    ),
  );

  Widget _availabilityCard(Medecin doctor) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          Icons.calendar_month_outlined,
          'Disponibilité aujourd’hui',
        ),
        const SizedBox(height: 14),
        Row(
          children: ['09:00', '10:30', '14:00', '16:30']
              .map(
                (hour) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hour,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _blue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: doctor.disponible
                ? () => _bookAppointment(doctor)
                : null,
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('Prendre rendez-vous'),
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _aboutCard(Medecin doctor) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.person_outline, 'À propos du médecin'),
        const SizedBox(height: 12),
        Text(
          'Le ${doctor.nom} est ${doctor.specialite.toLowerCase()} avec une approche humaine et bienveillante. '
          'Il accompagne chaque patient avec attention et propose un suivi adapté à ses besoins.',
          style: const TextStyle(color: _muted, height: 1.5, fontSize: 15),
        ),
      ],
    ),
  );

  Widget _card(Widget child) => AppCard(child: child);

  Widget _doctorImage(Medecin doctor, {required double size, Color? border}) {
    final image = ClipOval(
      child: Image.asset(
        doctor.photo,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) => CircleAvatar(
          radius: size / 2,
          backgroundColor: const Color(0xFFEAF3FF),
          child: Icon(Icons.person, color: _blue, size: size * .42),
        ),
      ),
    );
    if (border == null) return image;
    return Container(
      width: size + 6,
      height: size + 6,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
      ),
      child: image,
    );
  }

  Widget _sectionTitle(IconData icon, String title) => Row(
    children: [
      Icon(icon, color: _blue, size: 25),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ],
  );

  Widget _infoLine(IconData icon, String text, {Color color = _blue}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          children: [
            Icon(icon, color: color, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color == _blue ? _muted : color,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _actionButton(
    IconData icon,
    String label, {
    required VoidCallback? onPressed,
    bool active = false,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? _blue : Colors.white,
        foregroundColor: active ? Colors.white : _blue,
        side: const BorderSide(color: _blue),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  void _bookAppointment(Medecin doctor) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rendez-vous'),
        content: Text(
          'Votre demande de rendez-vous avec ${doctor.nom} est prête à être confirmée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _openChat(Medecin doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClientChatPage(doctor: doctor)),
    );
  }
}

class ClientChatPage extends StatefulWidget {
  const ClientChatPage({super.key, required this.doctor});
  final Medecin doctor;
  @override
  State<ClientChatPage> createState() => _ClientChatPageState();
}

class _ClientChatPageState extends State<ClientChatPage> {
  final _controller = TextEditingController();
  final _db = Dbmanager();
  String? _discId;

  @override
  void initState() {
    super.initState();
    _loadExistingDiscussion();
  }

  Future<void> _loadExistingDiscussion() async {
    final clientId = _clientId;
    if (clientId.isEmpty || widget.doctor.id == null) return;
    final existing = await FirebaseFirestore.instance
        .collection('discussions')
        .where('clientId', isEqualTo: clientId)
        .where('medecinId', isEqualTo: widget.doctor.id)
        .limit(1)
        .get();
    if (!mounted || existing.docs.isEmpty) return;
    setState(() => _discId = existing.docs.first.id);
  }

  String get _clientId =>
      AuthSession.clientId ?? FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _discussion() async {
    final clientId = _clientId;
    if (clientId.isEmpty || widget.doctor.id == null) {
      throw StateError('Client ou médecin non identifié');
    }
    final existing = await FirebaseFirestore.instance
        .collection('discussions')
        .where('clientId', isEqualTo: clientId)
        .where('medecinId', isEqualTo: widget.doctor.id)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return existing.docs.first.id;
    final ref = await FirebaseFirestore.instance.collection('discussions').add({
      'clientId': clientId,
      'medecinId': widget.doctor.id,
      'medecin': widget.doctor.id,
      'sujet': 'Discussion avec ${widget.doctor.nom}',
      'type': 'texte',
      'lu': false,
      'contenu': '',
      'dernierMessage': '',
      'createAt': FieldValue.serverTimestamp(),
      'date_envoi': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final id = _discId ??= await _discussion();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? _clientId;
    await _db.enregistrerMessage(discId: id, senderId: uid, texte: text);
    await _db.mettreAJourDiscussion(discId: id, dernierMessage: text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Dr. ${widget.doctor.nom}')),
    body: Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _discId == null
                ? null
                : _db.messagesMapStream(discId: _discId!),
            builder: (context, snapshot) {
              if (_discId == null) {
                return const Center(
                  child: Text('Écrivez votre premier message.'),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Impossible de charger les messages.'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final messages = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  final data = messages[index];
                  if (data['type'] == 'ordonnance' &&
                      data['ordonnanceId'] != null) {
                    return MessageOrdonnanceWidget(
                      ordonnanceId: data['ordonnanceId'].toString(),
                    );
                  }
                  final mine =
                      data['senderId'] ==
                      FirebaseAuth.instance.currentUser?.uid;
                  return Align(
                    alignment: mine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: mine ? Colors.blue : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        (data['texte'] ?? data['contenu'] ?? '').toString(),
                        style: TextStyle(
                          color: mine ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Votre message'),
                ),
              ),
              IconButton.filled(onPressed: _send, icon: const Icon(Icons.send)),
            ],
          ),
        ),
      ],
    ),
  );
}
