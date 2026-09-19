import 'package:cloud_firestore/cloud_firestore.dart';

class Produit {
  const Produit({
    this.id,
    required this.nom,
    required this.description,
    required this.details,
    required this.categorie,
    required this.specialite,
    required this.forme,
    required this.prix,
    required this.stock,
    required this.image,
  });

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('products');

  final String? id;
  final String nom;
  final String description;
  final String details;
  final String categorie;
  final String specialite;
  final String forme;
  final double prix;
  final int stock;
  final String image;

  factory Produit.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Produit(
      id: (data['id'] ?? doc.id).toString(),
      nom: (data['nom'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      details: (data['details'] ?? '').toString(),
      categorie: (data['categorie'] ?? '').toString(),
      specialite: (data['specialite'] ?? '').toString(),
      forme: (data['forme'] ?? '').toString(),
      prix: (data['prix'] is num) ? (data['prix'] as num).toDouble() : 0.0,
      stock: (data['stock'] is num) ? (data['stock'] as num).toInt() : 0,
      image: (data['image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nom': nom,
    'description': description,
    'details': details,
    'categorie': categorie,
    'specialite': specialite,
    'forme': forme,
    'prix': prix,
    'stock': stock,
    'image': image,
  };
}
