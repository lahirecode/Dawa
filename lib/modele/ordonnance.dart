import 'package:cloud_firestore/cloud_firestore.dart';

class Ordonnance {
  final String id;
  final String clientId;
  String medecinId;
  String descId;
  List<Map<String, dynamic>> produits;
  String note;
  String statut;
  DateTime? date;

  Ordonnance({
    required this.id,
    required this.clientId,
    required this.medecinId,
    required this.descId,
    required this.produits,
    required this.note,
    required this.statut,
    required this.date,
  });

  factory Ordonnance.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Ordonnance(
      id: doc.id,
      clientId: (data['clientId'] ?? '').toString(),
      medecinId: (data['medecinId'] ?? '').toString(),
      descId: (data['descId'] ?? '').toString(),
      produits: List<Map<String, dynamic>>.from(
        (data['produits'] ?? data['medicaments'] ?? const <dynamic>[]) as List,
      ),
      note: (data['note'] ?? data['noteMedecin'] ?? '').toString(),
      statut: (data['statut'] ?? 'en_cours').toString(),
      date: data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'medecinId': medecinId,
      'descId': descId,
      'produits': produits,
      'medicaments': produits,
      'note': note,
      'noteMedecin': note,
      'statut': statut,
      'date': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'dateCreation': FieldValue.serverTimestamp(),
    };
  }
}
