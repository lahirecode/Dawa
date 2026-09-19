import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../modele/client.dart';
import '../modele/compte_professionnel.dart';
import '../modele/discussions.dart';
import '../modele/medecin.dart';
import '../modele/messages.dart';
import '../modele/ordonnance.dart';
import '../modele/produit.dart';

class Dbmanager {
  Dbmanager({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  static String normalizeTelephone(
    String telephone, [
    String defaultPrefix = '+243',
  ]) {
    final rawText = telephone.trim();
    if (rawText.isEmpty) return '';

    final digitsWithPlus = rawText.replaceAll(RegExp(r'[^0-9+]'), '').trim();
    if (digitsWithPlus.isEmpty) return '';

    final defaultCountryDigits = defaultPrefix.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (defaultCountryDigits.isEmpty) {
      return '+${digitsWithPlus.replaceAll('+', '').replaceAll(RegExp(r'[^0-9]'), '')}';
    }

    final numericDigits = digitsWithPlus
        .replaceAll('+', '')
        .replaceAll(RegExp(r'[^0-9]'), '');
    if (numericDigits.isEmpty) return '';

    if (digitsWithPlus.startsWith('+')) {
      return '+$numericDigits';
    }

    if (numericDigits.startsWith('00')) {
      return '+${numericDigits.substring(2)}';
    }

    if (numericDigits.startsWith(defaultCountryDigits)) {
      return '+$numericDigits';
    }

    if (numericDigits.startsWith('0')) {
      return '+$defaultCountryDigits${numericDigits.substring(1)}';
    }

    return '+$defaultCountryDigits$numericDigits';
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      _firestore.collection(name);

  int _idFor(String value) {
    var hash = 0x811C9DC5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  String _emailForTelephone(String telephone) {
    final normalized = telephone.trim().replaceAll(RegExp(r'[^0-9]'), '');
    return '$normalized@dawa.app';
  }

  Map<String, dynamic> _data(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final result = Map<String, dynamic>.from(data);
    result['id'] ??= _idFor(snapshot.id);
    result['date_inscription'] = _dateString(result['date_inscription']);
    result['date_envoi'] = _dateString(result['date_envoi']);
    return result;
  }

  String? _dateString(dynamic value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    return value as String?;
  }

  Future<String> insertProduit(Produit produit) async {
    final collection = _collection('products');
    final reference = produit.id == null || produit.id!.isEmpty
        ? collection.doc()
        : collection.doc(produit.id);
    await reference.set({...produit.toMap(), 'id': reference.id});
    return reference.id;
  }

  Future<void> addProduit(Produit produit) async {
    await _collection('products').add(produit.toMap());
  }

  Future<int> updateProduit(Produit produit) async {
    final id = produit.id;
    if (id == null || id.isEmpty) return 0;
    final reference = _collection('products').doc(id);
    final document = await reference.get();
    if (document.exists) {
      await reference.update({...produit.toMap(), 'id': id});
      return 1;
    }
    final snapshot = await _collection('products')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return 0;
    await snapshot.docs.first.reference.update({...produit.toMap(), 'id': id});
    return 1;
  }

  Future<int> deleteProduit(String id) async {
    final snapshot = await _collection('products')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return 0;
    await snapshot.docs.first.reference.delete();
    return 1;
  }

  Future<String> inscrireUtilisateur({
    required String nom,
    required String telephone,
    required String email,
    required String motDePasse,
  }) async {
    final normalizedTelephone = telephone.trim();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: motDePasse,
    );
    final uid = credential.user!.uid;
    final data = {
      'uid': uid,
      'nom': nom.trim(),
      'telephone': normalizedTelephone,
      'role': 'client',
      'email': credential.user!.email,
      'date_inscription': FieldValue.serverTimestamp(),
      'photo': null,
    };
    await _collection('users').doc(uid).set(data);
    await _collection('clients').doc(uid).set({...data, 'id': uid});
    await credential.user!.updateDisplayName(nom.trim());
    await _auth.signOut();
    return uid;
  }

  Future<Client?> getClientByTelephone(String telephone) async {
    final result = await _collection('clients')
        .where('telephone', isEqualTo: telephone.trim())
        .limit(1)
        .get();
    return result.docs.isEmpty ? null : Client.fromDoc(result.docs.first);
  }

  Future<String> enregistrerDiscussion(Discussion discussion) async {
    final payload = {
      ...discussion.toMap(),
      'clientId': discussion.clientId,
      'medecinId': discussion.medecinId,
      'medecin': discussion.medecinId,
      'date_envoi': discussion.dateEnvoi == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(discussion.dateEnvoi!),
      'lu': discussion.lu,
      'contenu': discussion.contenu.isNotEmpty
          ? discussion.contenu
          : discussion.dernierMessage,
      'dernierMessage': discussion.dernierMessage.isNotEmpty
          ? discussion.dernierMessage
          : discussion.contenu,
    };
    final reference = await _collection('discussions').add(payload);
    await reference.update({'id': reference.id});
    return reference.id;
  }

  Future<List<Discussion>> getDiscussions({
    required String clientId,
    String? medecin,
  }) async {
    Query<Map<String, dynamic>> query = _collection('discussions')
        .where('clientId', isEqualTo: clientId);
    if (medecin != null) query = query.where('medecinId', isEqualTo: medecin);
    final result = await query.orderBy('date_envoi').get();
    return result.docs.map((doc) => Discussion.fromDoc(doc)).toList();
  }

  Stream<List<Discussion>> discussionsStream({String? uid, String? clientId}) {
    Query<Map<String, dynamic>> query = _collection('discussions');
    if (clientId != null && clientId.isNotEmpty) {
      query = query.where('clientId', isEqualTo: clientId);
    }
    if (uid != null && uid.isNotEmpty) {
      query = query.where('medecinId', isEqualTo: uid);
    }
    return query
        .orderBy('date_envoi')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Discussion.fromDoc(doc)).toList(),
        );
  }

  Stream<List<Message>> messagesStream({required String discId}) {
    return _collection('messages')
        .where('descId', isEqualTo: discId)
        .orderBy('date_envoi')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromDoc(doc)).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> messagesMapStream({
    required String discId,
  }) {
    return _collection('messages')
        .where('descId', isEqualTo: discId)
        .orderBy('date_envoi')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['senderId'] ??= data['sender_id'];
            data['texte'] ??= data['contenu'];
            return data;
          }).toList(),
        );
  }

  Future<String> enregistrerMessage({
    required String discId,
    required String senderId,
    required String texte,
    String type = 'texte',
    String? ordonnanceId,
  }) async {
    final value = texte.trim();
    if (discId.isEmpty || senderId.isEmpty || value.isEmpty) {
      throw ArgumentError(
        'Un message doit avoir une discussion, un expéditeur et un contenu.',
      );
    }
    final data = <String, dynamic>{
      'senderId': senderId,
      'sender_id': senderId,
      'texte': value,
      'contenu': value,
      'descId': discId,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'date_envoi': FieldValue.serverTimestamp(),
    };
    if (ordonnanceId != null && ordonnanceId.isNotEmpty) {
      data['ordonnanceId'] = ordonnanceId;
    }
    final reference = await _collection('messages').add(data);
    return reference.id;
  }

  Future<void> mettreAJourDiscussion({
    required String discId,
    required String dernierMessage,
    bool lu = false,
  }) async {
    if (discId.isEmpty) return;
    await _collection('discussions').doc(discId).update({
      'dernierMessage': dernierMessage,
      'contenu': dernierMessage,
      'date_envoi': FieldValue.serverTimestamp(),
      'lu': lu,
    });
  }

  Future<List<Produit>> getAllProduits() async {
    final result = await _collection('products').orderBy('nom').get();
    return result.docs.map(Produit.fromDoc).toList();
  }

  Future<List<Medecin>> getAllMedecins() async {
    final result = await _collection('doctors').orderBy('nom').get();
    return result.docs.map(Medecin.fromDoc).toList();
  }

  Future<List<Client>> getClientsConnectes(String medecin) async {
    final discussions = await _collection('discussions')
        .where('medecinId', isEqualTo: medecin)
        .get();
    final ids = discussions.docs
        .map((doc) => (_data(doc)['clientId'] ?? '').toString())
        .where((value) => value.isNotEmpty)
        .toSet();
    if (ids.isEmpty) return [];
    final clients = await getAllClients();
    return clients.where((client) => ids.contains(client.clientId)).toList();
  }

  Future<List<Client>> getAllClients() async {
    final result = await _collection('clients').orderBy('nom').get();
    return result.docs.map((doc) => Client.fromDoc(doc)).toList();
  }

  Future<int> deleteClient(String id) async {
    var clientReference = _collection('clients').doc(id);
    var clientSnapshot = await clientReference.get();
    if (!clientSnapshot.exists) {
      final clients = await _collection('clients')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();
      if (clients.docs.isEmpty) return 0;
      clientReference = clients.docs.first.reference;
      clientSnapshot = clients.docs.first;
    }
    final discussions = await _collection('discussions')
        .where('clientId', isEqualTo: id)
        .get();
    final batch = _firestore.batch();
    for (final discussion in discussions.docs) {
      batch.delete(discussion.reference);
    }
    batch.delete(clientReference);
    await batch.commit();
    return 1;
  }

  Future<int> updateClient(Client client) async {
    if (client.clientId.isEmpty) return 0;
    final reference = _collection('clients').doc(client.clientId);
    final snapshot = await reference.get();
    if (!snapshot.exists) return 0;
    final data = client.toMap();
    data.remove('clientId');
    data.remove('uid');
    await reference.update(data);
    return 1;
  }

  Future<List<Discussion>> getAllDiscussions() async {
    final result = await _collection('discussions')
        .orderBy('date_envoi', descending: true)
        .get();
    return result.docs.map((doc) => Discussion.fromDoc(doc)).toList();
  }

  Future<String> insertMedecin(Medecin medecin) async {
    final uid = medecin.id;
    if (uid == null || uid.isEmpty) {
      throw ArgumentError('Un UID est requis pour enregistrer un médecin.');
    }
    final reference = _collection('doctors').doc(uid);
    await reference.set({...medecin.toMap(), 'medecinId': uid, 'uid': uid});
    return reference.id;
  }

  Future<int> updateMedecin(Medecin medecin) async {
    if (medecin.id == null || medecin.id!.isEmpty) return 0;
    final reference = _collection('doctors').doc(medecin.id);
    final snapshot = await reference.get();
    if (!snapshot.exists) return 0;
    await reference.update({
      ...medecin.toMap(),
      'medecinId': medecin.id,
      'uid': medecin.id,
    });
    return 1;
  }

  Future<int> deleteMedecin(String id) async {
    final reference = _collection('doctors').doc(id);
    final snapshot = await reference.get();
    if (!snapshot.exists) return 0;
    await reference.delete();
    return 1;
  }

  Future<int> marquerDiscussionLue(String id) async {
    final result = await _collection('discussions')
        .where('medecinId', isEqualTo: id)
        .limit(1)
        .get();
    if (result.docs.isEmpty) return 0;
    await result.docs.first.reference.update({'lu': true});
    return 1;
  }

  Future<Map<String, dynamic>?> authentifierUtilisateur({
    required String telephone,
    required String motDePasse,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _emailForTelephone(telephone),
        password: motDePasse,
      );
      final result = await _collection('users').doc(credential.user!.uid).get();
      if (!result.exists) return null;
      return {..._data(result), 'id': credential.user!.uid};
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> authentifierProfessionnel({
    required String telephone,
    required String motDePasse,
  }) async {
    final normalizedTelephone = telephone.trim();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _emailForTelephone(normalizedTelephone),
        password: motDePasse,
      );
      final result = await _collection('professionals')
          .doc(credential.user!.uid)
          .get();
      if (!result.exists) return null;
      final data = _data(result);
      return {
        ...data,
        'role': data['role'] ?? 'medecin',
        'id': (data['medecinId'] ?? credential.user!.uid).toString(),
      };
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<List<CompteProfessionnel>> getAllComptesProfessionnels() async {
    final result = await _collection('professionals').orderBy('nom').get();
    return result.docs.map((doc) => CompteProfessionnel.fromDoc(doc)).toList();
  }

  Future<String> creerCompteProfessionnel({
    required String nom,
    required String telephone,
    required String motDePasse,
    required String role,
    String? medecinId,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: _emailForTelephone(telephone),
      password: motDePasse,
    );
    final uid = credential.user!.uid;
    await _collection('professionals').doc(uid).set({
      'id': uid,
      'uid': uid,
      'nom': nom.trim(),
      'telephone': telephone.trim(),
      'role': role,
      'medecinId': medecinId,
    });
    await _auth.signOut();
    return uid;
  }

  Future<int> supprimerCompteProfessionnel(String id) async {
    final reference = _collection('professionals').doc(id);
    final snapshot = await reference.get();
    if (!snapshot.exists) return 0;
    await reference.delete();
    return 1;
  }

  Future<bool> telephoneExiste(String telephone) async {
    final normalized = telephone.trim();
    final users = await _collection('users')
        .where('telephone', isEqualTo: normalized)
        .limit(1)
        .get();
    if (users.docs.isNotEmpty) return true;
    final professionals = await _collection('professionals')
        .where('telephone', isEqualTo: normalized)
        .limit(1)
        .get();
    return professionals.docs.isNotEmpty;
  }

  Future<void> envoyerEmailReinitialisation(String identifiant) async {
    final value = identifiant.trim();
    final email = value.contains('@') ? value : _emailForTelephone(value);
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<int> reinitialiserMotDePasse({
    required String telephone,
    required String nouveauMotDePasse,
  }) async {
    final email = _emailForTelephone(telephone);
    await _auth.sendPasswordResetEmail(email: email);
    return 1;
  }

  Future<String> creerordonnance({
    required String clientId,
    required String descId,
    required List<Map<String, dynamic>> produits,
    String note = '',
    String statut = 'disponible',
  }) async {
    final medecinId = _auth.currentUser?.uid;
    if (medecinId == null || medecinId.isEmpty) {
      throw StateError('Aucun médecin connecté.');
    }
    if (clientId.isEmpty || descId.isEmpty || produits.isEmpty) {
      throw ArgumentError(
        'Une ordonnance doit avoir un client, une discussion et un médicament.',
      );
    }

    final ordonnance = Ordonnance(
      id: '',
      clientId: clientId,
      medecinId: medecinId,
      descId: descId,
      produits: produits,
      note: note.trim(),
      statut: statut,
      date: null,
    );
    final reference = await _collection('ordonnances').add(ordonnance.toMap());
    return reference.id;
  }

  Future<Map<String, dynamic>?> getUtilisateurConnecte() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final result = await _collection('users').doc(user.uid).get();
    if (!result.exists) return null;
    return {..._data(result), 'id': user.uid};
  }
}
