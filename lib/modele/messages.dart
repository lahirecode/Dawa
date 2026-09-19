import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  const Message({
    this.msgId,
    required this.senderId,
    required this.texte,
    required this.createdAt,
    this.discId = '',
    this.type = 'texte',
  });

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('messages');

  final String? msgId;
  final String senderId;
  final String texte;
  final DateTime createdAt;
  final String discId;
  final String type;

  factory Message.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAtValue = data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : (data['date_envoi'] is Timestamp
              ? (data['date_envoi'] as Timestamp).toDate()
              : DateTime.now());

    return Message(
      msgId: doc.id,
      senderId: (data['senderId'] ?? data['sender_id'] ?? '').toString(),
      texte: (data['texte'] ?? '').toString(),
      createdAt: createdAtValue,
      discId: (data['descId'] ?? '').toString(),
      type: (data['type'] ?? 'texte').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'sender_id': senderId,
    'texte': texte,
    'createdAt': Timestamp.fromDate(createdAt),
    'date_envoi': Timestamp.fromDate(createdAt),
    'descId': discId,
    'type': type,
  };
}
