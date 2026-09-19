import 'package:cloud_firestore/cloud_firestore.dart';

class Medecin {
  const Medecin({
    this.id,
    required this.nom,
    required this.specialite,
    required this.telephone,
    required this.disponible,
    required this.photo,
  });

  final String? id;
  final String nom;
  final String specialite;
  final String telephone;
  final bool disponible;
  final String photo;

  factory Medecin.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Medecin(
      id: (data['id'] ?? doc.id).toString(),
      nom: (data['nom'] ?? '').toString(),
      specialite: (data['specialite'] ?? '').toString(),
      telephone: (data['telephone'] ?? '').toString(),
      disponible: data['disponible'] is bool
          ? data['disponible'] as bool
          : (data['disponible'] as int? ?? 0) == 1,
      photo: (data['photo'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nom': nom,
    'specialite': specialite,
    'telephone': telephone,
    'disponible': disponible,
    'photo': photo,
  };
}
