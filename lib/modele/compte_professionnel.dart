import 'package:cloud_firestore/cloud_firestore.dart';

class CompteProfessionnel {
  const CompteProfessionnel({
    this.id,
    required this.nom,
    required this.telephone,
    required this.role,
    this.medecinId,
  });

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('professionals');

  final String? id;
  final String nom;
  final String telephone;
  final String role;
  final String? medecinId;

  factory CompteProfessionnel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return CompteProfessionnel(
      id: (data['id'] ?? doc.id).toString(),
      nom: (data['nom'] ?? '').toString(),
      telephone: (data['telephone'] ?? '').toString(),
      role: (data['role'] ?? 'medecin').toString(),
      medecinId: (data['medecinId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nom': nom,
    'telephone': telephone,
    'role': role,
    'medecinId': medecinId,
  };

  Map<String, dynamic> toFirestore() => toMap();
}
