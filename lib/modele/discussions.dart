import 'package:cloud_firestore/cloud_firestore.dart';

enum TypeDiscussion { texte, audio }

class Discussion {
  const Discussion({
    this.discId,
    required this.clientId,
    required this.medecinId,
    required this.sujet,
    this.type = TypeDiscussion.texte,
    this.createAt,
    this.dateEnvoi,
    this.lu = false,
    this.contenu = '',
    this.dernierMessage = '',
  });

  final String? discId;
  final String clientId;
  final String medecinId;
  final String sujet;
  final TypeDiscussion type;
  final DateTime? createAt;
  final DateTime? dateEnvoi;
  final bool lu;
  final String contenu;
  final String dernierMessage;

  String? get id => discId;

  String get medecin => medecinId;

  factory Discussion.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createTs = data['createAt'] is Timestamp
        ? data['createAt'] as Timestamp
        : null;
    final sentTs = data['date_envoi'] is Timestamp
        ? data['date_envoi'] as Timestamp
        : createTs;

    return Discussion(
      discId: doc.id,
      clientId: (data['clientId'] ?? '').toString(),
      medecinId: (data['medecinId'] ?? data['medecin'] ?? '').toString(),
      sujet: (data['sujet'] ?? '').toString(),
      type: data['type'] == 'audio'
          ? TypeDiscussion.audio
          : TypeDiscussion.texte,
      createAt: createTs?.toDate(),
      dateEnvoi: sentTs?.toDate(),
      lu: data['lu'] is bool
          ? data['lu'] as bool
          : (data['lu'] as int? ?? 0) == 1,
      contenu: (data['contenu'] ?? data['dernierMessage'] ?? '').toString(),
      dernierMessage: (data['dernierMessage'] ?? data['contenu'] ?? '')
          .toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'discId': discId,
    'clientId': clientId,
    'medecinId': medecinId,
    'medecin': medecinId,
    'sujet': sujet,
    'type': type.name,
    'createAt': createAt != null
        ? Timestamp.fromDate(createAt!)
        : FieldValue.serverTimestamp(),
    'date_envoi': dateEnvoi != null
        ? Timestamp.fromDate(dateEnvoi!)
        : FieldValue.serverTimestamp(),
    'lu': lu,
    'contenu': contenu.isNotEmpty ? contenu : dernierMessage,
    'dernierMessage': dernierMessage.isNotEmpty ? dernierMessage : contenu,
  };
}
