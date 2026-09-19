import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  const Client({
    required this.clientId,
    required this.nom,
    required this.telephone,
    this.email = '',
    this.date_inscription,
    this.photo,
  });

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('clients');

  final String clientId;
  final String nom;
  final String telephone;
  final String email;
  // ignore: non_constant_identifier_names
  final DateTime? date_inscription;
  final String? photo;

  factory Client.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Client(
      clientId: (data['uid'] ?? data['id'] ?? doc.id).toString(),
      nom: (data['nom'] ?? '').toString(),
      telephone: (data['telephone'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      date_inscription: data['date_inscription'] is Timestamp
          ? (data['date_inscription'] as Timestamp).toDate()
          : null,
      photo: data['photo']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'clientId': clientId,
    'uid': clientId,
    'role': 'client',
    'nom': nom,
    'telephone': telephone,
    'email': email,
    'date_inscription': date_inscription != null
        ? Timestamp.fromDate(date_inscription!)
        : FieldValue.serverTimestamp(),
    'photo': photo,
  };
}
