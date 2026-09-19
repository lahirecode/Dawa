import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/db_manager.dart';
import '../widgets/message_ordonnance.dart';
import '../widgets/ordonnance_sheet.dart';

class MedecinsPage extends StatelessWidget {
  const MedecinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Session expirée.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mes patients')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('discussions')
            .where('medecinId', isEqualTo: uid)
            .orderBy('date_envoi', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Impossible de charger les discussions.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final discussions = snapshot.data!.docs;
          if (discussions.isEmpty) {
            return const Center(child: Text('Aucun patient connecté.'));
          }
          return ListView.builder(
            itemCount: discussions.length,
            itemBuilder: (context, index) {
              final doc = discussions[index];
              final data = doc.data();
              final clientId = (data['clientId'] ?? '').toString();
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('clients')
                    .doc(clientId)
                    .get(),
                builder: (context, clientSnapshot) {
                  final clientData = clientSnapshot.data?.data();
                  final name = (clientData?['nom'] ?? 'Patient').toString();
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
                    ),
                    title: Text(name),
                    subtitle: Text(
                      (data['dernierMessage'] ??
                              data['contenu'] ??
                              data['sujet'] ??
                              '')
                          .toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: data['lu'] == false
                        ? const Icon(Icons.circle, size: 10)
                        : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedecinChatPage(
                          discId: doc.id,
                          clientId: clientId,
                          nomClient: name,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class MedecinChatPage extends StatefulWidget {
  const MedecinChatPage({
    super.key,
    required this.discId,
    required this.clientId,
    required this.nomClient,
  });
  final String discId;
  final String clientId;
  final String nomClient;

  @override
  State<MedecinChatPage> createState() => _MedecinChatPageState();
}

class _MedecinChatPageState extends State<MedecinChatPage> {
  final _controller = TextEditingController();
  final _db = Dbmanager();
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final uid = _uid;
    if (text.isEmpty || uid == null) return;
    await _db.enregistrerMessage(
      discId: widget.discId,
      senderId: uid,
      texte: text,
    );
    await _db.mettreAJourDiscussion(
      discId: widget.discId,
      dernierMessage: text,
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomClient),
        actions: [
          IconButton(
            tooltip: 'Prescrire',
            icon: const Icon(Icons.receipt_long),
            onPressed: () =>
                showOrdonnanceSheet(context, widget.clientId, widget.discId),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _db.messagesMapStream(discId: widget.discId),
              builder: (context, snapshot) {
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
                        isMedecin: true,
                      );
                    }
                    final mine = data['senderId'] == uid;
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
                    decoration: const InputDecoration(
                      hintText: 'Votre message',
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
