import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/db_manager.dart';

void showOrdonnanceSheet(BuildContext context, String clientId, String discId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => CreerOrdonnanceSheet(clientId: clientId, discId: discId),
  );
}

class CreerOrdonnanceSheet extends StatefulWidget {
  const CreerOrdonnanceSheet({
    super.key,
    required this.clientId,
    required this.discId,
  });
  final String clientId;
  final String discId;
  @override
  State<CreerOrdonnanceSheet> createState() => _CreerOrdonnanceSheetState();
}

class _CreerOrdonnanceSheetState extends State<CreerOrdonnanceSheet> {
  final _search = TextEditingController();
  final _note = TextEditingController();
  final _posology = TextEditingController();
  final _selected = <Map<String, dynamic>>[];
  final _db = Dbmanager();
  String _query = '';
  bool _sending = false;

  @override
  void dispose() {
    _search.dispose();
    _note.dispose();
    _posology.dispose();
    super.dispose();
  }

  Future<void> _add(QueryDocumentSnapshot<Map<String, dynamic>> product) async {
    _posology.clear();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.data()['nom']?.toString() ?? 'Médicament'),
        content: TextField(
          controller: _posology,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ex : 1 comprimé, 2 fois par jour',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _posology.text.trim()),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (!mounted || value == null || value.isEmpty) return;
    final data = product.data();
    setState(
      () => _selected.add({
        'productId': product.id,
        'nom': data['nom'] ?? '',
        'prix': data['prix'] ?? 0,
        'posologie': value,
        'duree': '',
        'image': data['image'] ?? '',
      }),
    );
  }

  Future<void> _send() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _selected.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final ordonnanceId = await _db.creerordonnance(
        clientId: widget.clientId,
        descId: widget.discId,
        produits: _selected,
        note: _note.text,
      );
      final text = 'Ordonnance de ${_selected.length} médicament(s)';
      await _db.enregistrerMessage(
        discId: widget.discId,
        senderId: uid,
        texte: text,
        type: 'ordonnance',
        ordonnanceId: ordonnanceId,
      );
      await _db.mettreAJourDiscussion(
        discId: widget.discId,
        dernierMessage: 'Nouvelle ordonnance',
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * .85,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          children: [
            const Text(
              'Nouvelle ordonnance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Chercher un médicament',
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
            if (_query.length > 1)
              Expanded(
                flex: 2,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .orderBy('nom')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final docs =
                        snapshot.data?.docs
                            .where(
                              (doc) =>
                                  (doc.data()['stock'] as num? ?? 0) > 0 &&
                                  (doc.data()['nom'] ?? '')
                                      .toString()
                                      .toLowerCase()
                                      .contains(_query),
                            )
                            .toList() ??
                        [];
                    return ListView(
                      children: docs
                          .map(
                            (doc) => ListTile(
                              title: Text(doc.data()['nom']?.toString() ?? ''),
                              subtitle: Text('${doc.data()['prix'] ?? 0}'),
                              trailing: const Icon(Icons.add_circle),
                              onTap: () => _add(doc),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
            const Divider(),
            Text('Médicaments sélectionnés (${_selected.length})'),
            Expanded(
              child: ListView.builder(
                itemCount: _selected.length,
                itemBuilder: (_, index) => ListTile(
                  title: Text(_selected[index]['nom'].toString()),
                  subtitle: Text(_selected[index]['posologie'].toString()),
                  trailing: IconButton(
                    onPressed: () => setState(() => _selected.removeAt(index)),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                hintText: 'Note pour le patient',
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _sending ? null : _send,
                child: Text(_sending ? 'Envoi...' : 'Envoyer l’ordonnance'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
